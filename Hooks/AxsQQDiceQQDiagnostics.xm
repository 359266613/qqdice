#import <Foundation/Foundation.h>
#import <objc/message.h>

// QQ 9.2.75 classdump: QQMsgService.h.
@interface QQMsgService : NSObject
- (void)sendAniStickerMsg:(id)contact faceContent:(id)content additionalMsg:(id)additional callBack:(id)callback;
- (void)sendMarketFaceMsg:(id)contact marketFaceInfo:(id)info additionalMsg:(id)additional callBack:(id)callback;
- (void)sendMsgWithOCContactAndOCMsgElements:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback;
- (void)sendMsgWithOCContact:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback;
- (unsigned long long)sendMsgAndGetMsgIDWithOCContactAndOCMsgElements:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback;
@end

static void axs_qqdice_log(NSString *message) {
    NSLog(@"[AxsQQDice] %@", message);
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.axs.qqdice.diagnostics", DISPATCH_QUEUE_SERIAL);
    });
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [NSDate date], message];
    dispatch_async(queue, ^{
        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        if (!documents) {
            NSLog(@"[AxsQQDice] Documents directory unavailable");
            return;
        }
        NSString *path = [documents stringByAppendingPathComponent:@"AxsQQDice.log"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:path] &&
            ![manager createFileAtPath:path contents:nil attributes:nil]) {
            NSLog(@"[AxsQQDice] Cannot create log at %@", path);
            return;
        }
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
        if (!handle) {
            NSLog(@"[AxsQQDice] Cannot open log at %@", path);
            return;
        }
        @try {
            [handle seekToEndOfFile];
            [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        } @catch (NSException *exception) {
            NSLog(@"[AxsQQDice] Log write failed: %@", exception.reason);
        } @finally {
            [handle closeFile];
        }
    });
}

static id axs_qqdice_readObject(id object, SEL selector) {
    if (!object || ![object respondsToSelector:selector]) {
        return nil;
    }
    NSMethodSignature *signature = [object methodSignatureForSelector:selector];
    if (!signature || signature.numberOfArguments != 2 || signature.methodReturnType[0] != '@') {
        return nil;
    }
    return ((id (*)(id, SEL))objc_msgSend)(object, selector);
}

static void axs_qqdice_logSticker(id object, NSString *source) {
    if (!object) {
        axs_qqdice_log([NSString stringWithFormat:@"%@: nil", source]);
        return;
    }
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    for (NSString *name in @[@"packId", @"stickerId", @"resultId", @"surpriseId",
                              @"faceName", @"emojiId", @"magicFaceContent",
                              @"sourceType", @"stickerType", @"randomType"]) {
        id value = axs_qqdice_readObject(object, NSSelectorFromString(name));
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            fields[name] = value;
        }
    }
    if ([NSStringFromClass([object class]) isEqualToString:@"OCFaceElement"]) {
        for (NSString *name in @[@"faceIndex", @"faceType"]) {
            SEL selector = NSSelectorFromString(name);
            NSMethodSignature *signature = [object methodSignatureForSelector:selector];
            if (signature && signature.numberOfArguments == 2 &&
                (signature.methodReturnType[0] == 'I' || signature.methodReturnType[0] == 'i')) {
                fields[name] = @(((unsigned int (*)(id, SEL))objc_msgSend)(object, selector));
            }
        }
    }
    axs_qqdice_log([NSString stringWithFormat:@"%@ class=%@ fields=%@", source, NSStringFromClass([object class]), fields]);
    id nested = axs_qqdice_readObject(object, @selector(aniStickerInfo));
    if (nested && nested != object) {
        NSMutableDictionary *nestedFields = [NSMutableDictionary dictionary];
        for (NSString *name in @[@"packId", @"stickerId", @"resultId"]) {
            id value = axs_qqdice_readObject(nested, NSSelectorFromString(name));
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                nestedFields[name] = value;
            }
        }
        axs_qqdice_log([NSString stringWithFormat:@"nested class=%@ fields=%@", NSStringFromClass([nested class]), nestedFields]);
    }
}

static void axs_qqdice_logElements(id elements, NSString *source) {
    if (![elements isKindOfClass:[NSArray class]]) {
        return;
    }
    for (id element in (NSArray *)elements) {
        if (![NSStringFromClass([element class]) isEqualToString:@"OCMsgElement"]) {
            continue;
        }
        id face = axs_qqdice_readObject(element, @selector(faceElement));
        id market = axs_qqdice_readObject(element, @selector(marketFaceElement));
        if (face) {
            axs_qqdice_logSticker(face, [source stringByAppendingString:@".faceElement"]);
        }
        if (market) {
            axs_qqdice_logSticker(market, [source stringByAppendingString:@".marketFaceElement"]);
        }
    }
}

%hook QQMsgService

- (void)sendAniStickerMsg:(id)contact faceContent:(id)content additionalMsg:(id)additional callBack:(id)callback {
    axs_qqdice_logSticker(content, @"sendAniStickerMsg");
    %orig;
}

- (void)sendMarketFaceMsg:(id)contact marketFaceInfo:(id)info additionalMsg:(id)additional callBack:(id)callback {
    axs_qqdice_logSticker(info, @"sendMarketFaceMsg");
    %orig;
}

- (void)sendMsgWithOCContactAndOCMsgElements:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback {
    axs_qqdice_logElements(elements, @"sendMsgWithOCContactAndOCMsgElements");
    %orig;
}

- (void)sendMsgWithOCContact:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback {
    axs_qqdice_logElements(elements, @"sendMsgWithOCContact");
    %orig;
}

- (unsigned long long)sendMsgAndGetMsgIDWithOCContactAndOCMsgElements:(id)contact msgElems:(id)elements msgAttributeInfos:(id)attributes callBack:(id)callback {
    axs_qqdice_logElements(elements, @"sendMsgAndGetMsgIDWithOCContactAndOCMsgElements");
    return %orig;
}

%end

%ctor {
    @autoreleasepool {
        Class service = NSClassFromString(@"QQMsgService");
        axs_qqdice_log([NSString stringWithFormat:@"loaded; QQMsgService=%@ ani=%d market=%d",
              service ? @"present" : @"missing",
              service && [service instancesRespondToSelector:@selector(sendAniStickerMsg:faceContent:additionalMsg:callBack:)],
              service && [service instancesRespondToSelector:@selector(sendMarketFaceMsg:marketFaceInfo:additionalMsg:callBack:)]]);
    }
}
