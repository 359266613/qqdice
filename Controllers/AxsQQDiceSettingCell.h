#import <UIKit/UIKit.h>
#import "AxsQQDiceSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

// A single row drawn inside a card: icon, title, detail, chevron or switch.
@interface AxsQQDiceSettingCell : UITableViewCell

@property (nonatomic, strong, readonly, nullable) AxsQQDiceSettingItem *item;
@property (nonatomic, strong, nullable) UIColor *detailTextColor;
// Replaces the detail text and chevron. Give the view an explicit frame size.
@property (nonatomic, strong, nullable) UIView *customTrailingView;

- (void)configureWithItem:(AxsQQDiceSettingItem *)item;

@end

NS_ASSUME_NONNULL_END
