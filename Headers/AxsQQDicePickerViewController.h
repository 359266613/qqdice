#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 骰子点数选择弹窗。选点数回调 points（1-6），取消回调 0。
@interface AxsQQDicePickerViewController : UIViewController

+ (void)showFrom:(UIViewController *)host completion:(nullable void (^)(NSInteger points))completion;

@end

NS_ASSUME_NONNULL_END
