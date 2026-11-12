#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AxsQQDiceConfig.h"
#import "AxsQQDiceDiceResources.h"
#import "AxsQQDiceHost.h"

// 骰子结果最终以 JSON 形式进入发送链路（自定义表情消息带 result/value 字段）。
// 这里在序列化前改写该字段，并把原始 JSON 落进日志，便于核对真实字段名。
// 匹配不到就完全放行，不改变其它任何消息。

static NSString *axs_qqdice_logPath(void) {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        path = [documents stringByAppendingPathComponent:@"AxsQQDice.log"];
    });
    return path;
}

static void axs_qqdice_appendLog(NSString *text) {
    if (text.length == 0) {
        return;
    }
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [NSDate date].description, text];
    if (![[NSFileManager defaultManager] fileExistsAtPath:axs_qqdice_logPath()]) {
        [line writeToFile:axs_qqdice_logPath() atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        return;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:axs_qqdice_logPath()];
    @try {
        [handle seekToEndOfFile];
        [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    } @finally {
        [handle closeFile];
    }
}

static BOOL axs_qqdice_containsDiceKey(id object) {
    if ([object isKindOfClass:[NSString class]]) {
        return [[(NSString *)object lowercaseString] containsString:@"dice"];
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        for (id key in (NSDictionary *)object) {
            if (axs_qqdice_containsDiceKey(key) ||
                axs_qqdice_containsDiceKey([(NSDictionary *)object objectForKey:key])) {
                return YES;
            }
        }
    }
    if ([object isKindOfClass:[NSArray class]]) {
        for (id item in (NSArray *)object) {
            if (axs_qqdice_containsDiceKey(item)) {
                return YES;
            }
        }
    }
    return NO;
}

static NSArray<NSString *> *axs_qqdice_resultKeys(void) {
    static NSArray<NSString *> *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[@"result", @"value", @"points", @"random", @"diceResult", @"num"];
    });
    return keys;
}

// 只改 1-6 的数值字段；字段名大小写不敏感。
static BOOL axs_qqdice_patchDictionary(NSMutableDictionary *dictionary, NSInteger points) {
    BOOL changed = NO;
    for (NSString *key in dictionary.allKeys.copy) {
        id value = dictionary[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutable = [value mutableCopy];
            if (axs_qqdice_patchDictionary(mutable, points)) {
                dictionary[key] = mutable;
                changed = YES;
            }
            continue;
        }
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *items = [NSMutableArray arrayWithArray:value];
            BOOL arrayChanged = NO;
            for (NSUInteger index = 0; index < items.count; index++) {
                if (![items[index] isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSMutableDictionary *mutable = [items[index] mutableCopy];
                if (axs_qqdice_patchDictionary(mutable, points)) {
                    items[index] = mutable;
                    arrayChanged = YES;
                }
            }
            if (arrayChanged) {
                dictionary[key] = items;
                changed = YES;
            }
            continue;
        }
        if (![axs_qqdice_resultKeys() containsObject:key.lowercaseString]) {
            continue;
        }
        if (![value isKindOfClass:[NSNumber class]] && ![value isKindOfClass:[NSString class]]) {
            continue;
        }
        NSInteger current = [value integerValue];
        if (current < 1 || current > 6) {
            continue;
        }
        dictionary[key] = [value isKindOfClass:[NSString class]]
            ? [NSString stringWithFormat:@"%ld", (long)points] : @(points);
        changed = YES;
    }
    return changed;
}

%hook NSJSONSerialization

+ (NSData *)dataWithJSONObject:(id)object options:(NSJSONWritingOptions)options error:(NSError **)error {
    AxsQQDiceConfig *config = [AxsQQDiceConfig axs_qqdice_shared];
    BOOL logging = [config axs_qqdice_boolForKey:@"diagnostics" defaultValue:NO];
    BOOL forced = [config axs_qqdice_isEnabled] &&
                  [config axs_qqdice_boolForKey:@"forcePoints" defaultValue:NO];
    if ((!logging && !forced) || ![object isKindOfClass:[NSDictionary class]] ||
        !axs_qqdice_containsDiceKey(object)) {
        return %orig;
    }

    if (logging) {
        NSData *snapshot = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
        if (snapshot) {
            axs_qqdice_appendLog([[NSString alloc] initWithData:snapshot encoding:NSUTF8StringEncoding]);
        }
    }
    if (!forced) {
        return %orig;
    }

    NSMutableDictionary *patched = [object mutableCopy];
    NSInteger points = axs_qqdice_storedPoints();
    if (!axs_qqdice_patchDictionary(patched, points)) {
        return %orig;
    }
    axs_qqdice_appendLog([NSString stringWithFormat:@"patched dice result -> %ld", (long)points]);
    return [NSJSONSerialization dataWithJSONObject:patched options:options error:error];
}

%end

%ctor {
    @autoreleasepool {
        [AxsQQDiceConfig axs_qqdice_shared];
    }
}
