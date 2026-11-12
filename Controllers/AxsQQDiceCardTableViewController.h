#import <UIKit/UIKit.h>
#import "AxsQQDiceSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

// Base controller for card-style settings pages: one card per section.
@interface AxsQQDiceCardTableViewController : UITableViewController

@property (nonatomic, copy) NSArray<AxsQQDiceSettingSection *> *sections;

- (void)configureAppearanceWithTitle:(NSString *)title;

// Subclasses may put a view (button, status label) at the right of a card title.
- (nullable UIView *)rightViewForSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
