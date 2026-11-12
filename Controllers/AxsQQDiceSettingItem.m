#import "AxsQQDiceSettingItem.h"

@interface AxsQQDiceSettingItem ()
@property (nonatomic, assign, readwrite) AxsQQDiceSettingItemType itemType;
@end

@implementation AxsQQDiceSettingItem

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    iconColor:(UIColor *)iconColor
                       detail:(NSString *)detail
                         type:(AxsQQDiceSettingItemType)type {
    self = [super init];
    if (self) {
        _title = [title copy] ?: @"";
        _iconName = [iconName copy];
        _iconColor = iconColor;
        _detail = [detail copy];
        _itemType = type;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    iconColor:(UIColor *)iconColor
                       detail:(NSString *)detail {
    return [[self alloc] initWithTitle:title iconName:iconName iconColor:iconColor
                                detail:detail type:AxsQQDiceSettingItemTypeNormal];
}

+ (instancetype)actionItemWithTitle:(NSString *)title
                           iconName:(NSString *)iconName
                          iconColor:(UIColor *)iconColor {
    return [[self alloc] initWithTitle:title iconName:iconName iconColor:iconColor
                                detail:nil type:AxsQQDiceSettingItemTypeAction];
}

+ (instancetype)switchItemWithTitle:(NSString *)title
                           iconName:(NSString *)iconName
                          iconColor:(UIColor *)iconColor
                        switchValue:(BOOL)switchValue
                  valueChangedBlock:(void (^)(BOOL))valueChanged {
    AxsQQDiceSettingItem *item = [[self alloc] initWithTitle:title iconName:iconName iconColor:iconColor
                                                       detail:nil type:AxsQQDiceSettingItemTypeSwitch];
    item.switchValue = switchValue;
    item.switchValueChanged = valueChanged;
    return item;
}

@end

@implementation AxsQQDiceSettingSection

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray<AxsQQDiceSettingItem *> *)items {
    AxsQQDiceSettingSection *section = [[self alloc] init];
    section.header = header;
    section.items = items ?: @[];
    return section;
}

@end
