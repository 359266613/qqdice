#import <Foundation/Foundation.h>
#import <objc/message.h>

// QQ 9.2.75 classdump: QQMsgService.h.
@interface QQMsgService : NSObject
- (void)sendAniStickerMsg:(id)contact faceContent:(id)content additionalMsg:(id)additional callBack:(id)callback;
- (void)sendMarketFaceMsg:(id)contact marketFaceInfo:(id)info additionalMsg:(id)additional callBack:(id)callback;
@end

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
        NSLog(@"[AxsQQDice] %@: nil", source);
        return;
    }
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    for (NSString *name in @[@"packId", @"stickerId", @"resultId", @"surpriseId",
                              @"faceName", @"emojiId", @"magicFaceContent"]) {
        id value = axs_qqdice_readObject(object, NSSelectorFromString(name));
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            fields[name] = value;
        }
    }
    NSLog(@"[AxsQQDice] %@ class=%@ fields=%@", source, NSStringFromClass([object class]), fields);
    id nested = axs_qqdice_readObject(object, @selector(aniStickerInfo));
    if (nested && nested != object) {
        NSMutableDictionary *nestedFields = [NSMutableDictionary dictionary];
        for (NSString *name in @[@"packId", @"stickerId", @"resultId"]) {
            id value = axs_qqdice_readObject(nested, NSSelectorFromString(name));
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                nestedFields[name] = value;
            }
        }
        NSLog(@"[AxsQQDice] nested class=%@ fields=%@", NSStringFromClass([nested class]), nestedFields);
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

%end

%ctor {
    @autoreleasepool {
        Class service = NSClassFromString(@"QQMsgService");
        NSLog(@"[AxsQQDice] loaded; QQMsgService=%@ ani=%d market=%d",
              service ? @"present" : @"missing",
              service && [service instancesRespondToSelector:@selector(sendAniStickerMsg:faceContent:additionalMsg:callBack:)],
              service && [service instancesRespondToSelector:@selector(sendMarketFaceMsg:marketFaceInfo:additionalMsg:callBack:)]);
    }
}
