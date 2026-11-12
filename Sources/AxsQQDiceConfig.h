#pragma once

#import <Foundation/Foundation.h>

// Posted on the main queue after any value changes. Hooks that read a value on
// a hot path should cache it and refresh the cache when this arrives.
extern NSString * const AxsQQDiceConfigDidChangeNotification;

// Settings live inside the host app's sandbox (suite "com.axs.qqdice"). The tweak and
// its in-app panel run in the same process, so one store serves both.
@interface AxsQQDiceConfig : NSObject
+ (instancetype)axs_qqdice_shared;
- (BOOL)axs_qqdice_isEnabled;
- (void)axs_qqdice_setEnabled:(BOOL)enabled;
- (id)axs_qqdice_valueForKey:(NSString *)key defaultValue:(id)defaultValue;
- (BOOL)axs_qqdice_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (double)axs_qqdice_doubleForKey:(NSString *)key defaultValue:(double)defaultValue;
- (NSString *)axs_qqdice_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (void)axs_qqdice_setValue:(id)value forKey:(NSString *)key;
@end
