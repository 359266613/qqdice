#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AxsQQDiceSettingItemType) {
    AxsQQDiceSettingItemTypeNormal,
    AxsQQDiceSettingItemTypeAction,
    AxsQQDiceSettingItemTypeSwitch,
};

// One row inside a card. Rows are plain data; the cell decides how to draw them.
@interface AxsQQDiceSettingItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *iconName;
@property (nonatomic, strong, nullable) UIColor *iconColor;
@property (nonatomic, copy, nullable) NSString *detail;
@property (nonatomic, assign, readonly) AxsQQDiceSettingItemType itemType;
@property (nonatomic, assign) BOOL switchValue;
@property (nonatomic, copy, nullable) void (^switchValueChanged)(BOOL isOn);
@property (nonatomic, copy, nullable) void (^actionBlock)(void);
// Runs after the cell is configured; modules use it to colour the detail text
// or attach a trailing control (slider, colour swatch).
@property (nonatomic, copy, nullable) void (^cellConfigurationBlock)(UITableViewCell *cell);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(nullable NSString *)iconName
                    iconColor:(nullable UIColor *)iconColor
                       detail:(nullable NSString *)detail;
+ (instancetype)actionItemWithTitle:(NSString *)title
                           iconName:(nullable NSString *)iconName
                          iconColor:(nullable UIColor *)iconColor;
+ (instancetype)switchItemWithTitle:(NSString *)title
                           iconName:(nullable NSString *)iconName
                          iconColor:(nullable UIColor *)iconColor
                        switchValue:(BOOL)switchValue
                  valueChangedBlock:(nullable void (^)(BOOL isOn))valueChanged;

@end

@interface AxsQQDiceSettingSection : NSObject

@property (nonatomic, copy, nullable) NSString *header;
@property (nonatomic, copy) NSArray<AxsQQDiceSettingItem *> *items;

+ (instancetype)sectionWithHeader:(nullable NSString *)header
                            items:(NSArray<AxsQQDiceSettingItem *> *)items;

@end

NS_ASSUME_NONNULL_END
