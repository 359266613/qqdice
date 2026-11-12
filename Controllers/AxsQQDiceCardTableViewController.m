#import "AxsQQDiceCardTableViewController.h"
#import "AxsQQDiceCardCell.h"

static const CGFloat AxsQQDiceCardSpacing = 10.0f;

@implementation AxsQQDiceCardTableViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)configureAppearanceWithTitle:(NSString *)title {
    self.title = title;
    UIColor *background = [UIColor systemBackgroundColor];
    self.view.backgroundColor = background;
    self.tableView.backgroundColor = background;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // sectionHeaderTopPadding exists from iOS 15; the plugin supports iOS 14.
    if ([self.tableView respondsToSelector:@selector(setSectionHeaderTopPadding:)]) {
        [self.tableView setValue:@(0.0f) forKey:@"sectionHeaderTopPadding"];
    }
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (UIView *)rightViewForSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count > 0 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AxsQQDiceSettingSection *section = self.sections[indexPath.section];
    return [AxsQQDiceCardCell cellForTableView:tableView
                                          title:section.header
                                          items:section.items
                                      rightView:[self rightViewForSection:indexPath.section]];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AxsQQDiceCardCell heightForItemCount:self.sections[indexPath.section].items.count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section < (NSInteger)self.sections.count - 1 ? AxsQQDiceCardSpacing : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return section < (NSInteger)self.sections.count - 1 ? [[UIView alloc] init] : nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *card = [cell.contentView viewWithTag:1001];
    card.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? 0.4 : 0.15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
