#import "AxsQQDiceConfig.h"

NSString * const AxsQQDiceConfigDidChangeNotification = @"com.axs.qqdice.config-changed";

static NSString * const AxsQQDiceEnabledKey = @"enabled";

@interface AxsQQDiceConfig ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation AxsQQDiceConfig

+ (instancetype)axs_qqdice_shared {
    static AxsQQDiceConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.axs.qqdice"];
    }
    return self;
}

- (id)axs_qqdice_valueForKey:(NSString *)key defaultValue:(id)defaultValue {
    return [self.defaults objectForKey:key] ?: defaultValue;
}

- (BOOL)axs_qqdice_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id value = [self axs_qqdice_valueForKey:key defaultValue:nil];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : defaultValue;
}

- (double)axs_qqdice_doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    id value = [self axs_qqdice_valueForKey:key defaultValue:nil];
    return [value isKindOfClass:[NSNumber class]] ? [value doubleValue] : defaultValue;
}

- (NSString *)axs_qqdice_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = [self axs_qqdice_valueForKey:key defaultValue:nil];
    return [value isKindOfClass:[NSString class]] ? value : defaultValue;
}

- (BOOL)axs_qqdice_isEnabled {
    return [self axs_qqdice_boolForKey:AxsQQDiceEnabledKey defaultValue:YES];
}

- (void)axs_qqdice_setEnabled:(BOOL)enabled {
    [self axs_qqdice_setValue:@(enabled) forKey:AxsQQDiceEnabledKey];
}

// Only the panel calls this; hooks never write defaults.
- (void)axs_qqdice_setValue:(id)value forKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    if (value) {
        [self.defaults setObject:value forKey:key];
    } else {
        [self.defaults removeObjectForKey:key];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AxsQQDiceConfigDidChangeNotification object:self];
    });
}

@end
