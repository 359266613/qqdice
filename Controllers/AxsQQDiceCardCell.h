#import <UIKit/UIKit.h>
#import "AxsQQDiceSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

// Draws one rounded, blurred card that holds a titled list of rows.
@interface AxsQQDiceCardCell : NSObject

+ (UITableViewCell *)cellForTableView:(UITableView *)tableView
                                title:(nullable NSString *)title
                                items:(NSArray<AxsQQDiceSettingItem *> *)items
                            rightView:(nullable UIView *)rightView;

+ (CGFloat)heightForItemCount:(NSInteger)itemCount;

@end

NS_ASSUME_NONNULL_END
