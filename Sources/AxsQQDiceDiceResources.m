#import "AxsQQDiceDiceResources.h"
#import "AxsQQDiceConfig.h"

// 已识别路径缓存：path -> 点数。识别一次就记住，避免重复读文件系统。
static NSMutableDictionary<NSString *, NSNumber *> *axs_qqdice_pathCache(void) {
    static NSMutableDictionary *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    return cache;
}

static NSArray<NSString *> *gAxsQQDiceScanned = nil;

static BOOL axs_qqdice_isDiceImagePath(NSString *path) {
    NSString *lower = path.lowercaseString;
    if (![lower hasSuffix:@".png"] && ![lower hasSuffix:@".jpg"] &&
        ![lower hasSuffix:@".jpeg"] && ![lower hasSuffix:@".webp"]) {
        return NO;
    }
    // 只认 dice 目录，避免误判聊天里的骰子插画。
    return [lower rangeOfString:@"/dice/"].location != NSNotFound;
}

NSInteger axs_qqdice_pointsForPath(NSString *path) {
    if (path.length == 0 || !axs_qqdice_isDiceImagePath(path)) {
        return 0;
    }
    NSNumber *cached = axs_qqdice_pathCache()[path];
    if (cached) {
        return cached.integerValue;
    }
    NSString *stem = path.lastPathComponent.stringByDeletingPathExtension;
    if (stem.length == 0) {
        return 0;
    }
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    if ([stem rangeOfCharacterFromSet:[digits invertedSet]].location != NSNotFound) {
        return 0;
    }
    NSInteger points = stem.integerValue;
    if (points < 1 || points > 6) {
        return 0;
    }
    axs_qqdice_pathCache()[path] = @(points);
    return points;
}

NSString *axs_qqdice_switchPoints(NSString *path, NSInteger points) {
    if (path.length == 0 || points < 1 || points > 6) {
        return path;
    }
    NSString *directory = path.stringByDeletingLastPathComponent;
    NSString *ext = path.pathExtension;
    NSString *suffix = ext.length ? [@"." stringByAppendingString:ext] : @"";
    NSString *candidate = [directory stringByAppendingPathComponent:
        [NSString stringWithFormat:@"%ld%@", (long)points, suffix]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:candidate]) {
        return candidate;
    }
    // 当前设备只解出部分图片时，用扫描结果兜底。
    for (NSString *scanned in gAxsQQDiceScanned) {
        if ([scanned.stringByDeletingLastPathComponent isEqualToString:directory] &&
            axs_qqdice_pointsForPath(scanned) == points) {
            return scanned;
        }
    }
    return path;
}

NSInteger axs_qqdice_storedPoints(void) {
    NSInteger points = (NSInteger)[[AxsQQDiceConfig axs_qqdice_shared] axs_qqdice_doubleForKey:@"points"
                                                                                   defaultValue:1];
    return (points >= 1 && points <= 6) ? points : 1;
}

NSArray<NSString *> *axs_qqdice_scannedDicePaths(void) {
    return gAxsQQDiceScanned ?: @[];
}

NSInteger axs_qqdice_scannedPoints(void) {
    NSMutableSet<NSNumber *> *points = [NSMutableSet set];
    for (NSString *path in axs_qqdice_scannedDicePaths()) {
        NSInteger value = axs_qqdice_pointsForPath(path);
        if (value > 0) {
            [points addObject:@(value)];
        }
    }
    return points.count;
}

void axs_qqdice_scanDiceResources(void) {
    NSString *root = NSBundle.mainBundle.bundlePath;
    NSMutableArray<NSString *> *found = [NSMutableArray array];
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:root];
    for (NSString *relative in enumerator) {
        NSString *full = [root stringByAppendingPathComponent:relative];
        // 用带斜杠的目录片段匹配，根目录下的散图不算。
        if (axs_qqdice_pointsForPath(full) > 0) {
            [found addObject:full];
        }
    }
    // 只按图片名判定点数，不看图片内容，所以整包扫描一次即可。
    dispatch_async(dispatch_get_main_queue(), ^{
        gAxsQQDiceScanned = found;
    });
}
