#import "AxsQQDiceCardCell.h"
#import "AxsQQDiceSettingCell.h"
#import <objc/runtime.h>

static const CGFloat AxsQQDiceCardItemHeight = 46.0f;
static const CGFloat AxsQQDiceCardHeaderHeight = 54.0f;
static const CGFloat AxsQQDiceCardPadding = 18.0f;
static const CGFloat AxsQQDiceCardInset = 20.0f;
static const CGFloat AxsQQDiceCardCornerRadius = 25.0f;
static NSInteger const AxsQQDiceCardContainerTag = 1001;
static char AxsQQDiceCardItemKey;

static UIColor *axs_qqdice_dynamicColor(UIColor *light, UIColor *dark) {
    return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light;
    }];
}

@implementation AxsQQDiceCardCell

+ (CGFloat)heightForItemCount:(NSInteger)itemCount {
    return AxsQQDiceCardHeaderHeight + itemCount * AxsQQDiceCardItemHeight + AxsQQDiceCardPadding;
}

+ (UITableViewCell *)cellForTableView:(UITableView *)tableView
                                title:(NSString *)title
                                items:(NSArray<AxsQQDiceSettingItem *> *)items
                            rightView:(UIView *)rightView {
    static NSString *identifier = @"AxsQQDiceCardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    // Cards are rebuilt on every dequeue so row blocks always match the current data.
    for (UIView *subview in [cell.contentView.subviews copy]) {
        [subview removeFromSuperview];
    }

    CGFloat tableWidth = tableView.bounds.size.width > 0 ? tableView.bounds.size.width : 375.0f;
    CGFloat cardWidth = tableWidth - AxsQQDiceCardInset * 2;
    CGFloat cardHeight = [self heightForItemCount:items.count];

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(AxsQQDiceCardInset, 0, cardWidth, cardHeight)];
    card.tag = AxsQQDiceCardContainerTag;
    card.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    card.layer.cornerRadius = AxsQQDiceCardCornerRadius;
    card.backgroundColor = axs_qqdice_dynamicColor([UIColor colorWithWhite:1.0 alpha:0.95],
                                                   [UIColor colorWithWhite:0.15 alpha:0.95]);
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowRadius = 8;
    card.layer.shadowOpacity = tableView.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? 0.4 : 0.15;
    [cell.contentView addSubview:card];

    UIVisualEffectView *blur = [[UIVisualEffectView alloc]
        initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
    blur.frame = card.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blur.layer.cornerRadius = AxsQQDiceCardCornerRadius;
    blur.layer.masksToBounds = YES;
    blur.alpha = 0.6;
    [card addSubview:blur];

    UIView *content = [[UIView alloc] initWithFrame:card.bounds];
    content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [card addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, cardWidth - 40, 22)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [content addSubview:titleLabel];

    if (rightView) {
        CGSize size = rightView.bounds.size;
        CGFloat width = MIN(size.width > 0 ? size.width : 30, cardWidth - 140);
        CGFloat height = size.height > 0 ? size.height : 24;
        rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightView.frame = CGRectMake(cardWidth - 20 - width, 20 + (24.0f - height) / 2.0f, width, height);
        [content addSubview:rightView];
        titleLabel.frame = CGRectMake(20, 18, cardWidth - 40 - width - 12.0f, 22);
    }

    CGFloat y = CGRectGetMaxY(titleLabel.frame) + 14.0f;
    for (NSInteger i = 0; i < (NSInteger)items.count; i++) {
        AxsQQDiceSettingItem *item = items[i];
        AxsQQDiceSettingCell *row = [[AxsQQDiceSettingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                   reuseIdentifier:nil];
        row.frame = CGRectMake(0, y + i * AxsQQDiceCardItemHeight, cardWidth, AxsQQDiceCardItemHeight);
        row.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [row configureWithItem:item];
        if (item.actionBlock) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(axs_qqdice_rowTapped:)];
            tap.cancelsTouchesInView = NO;
            objc_setAssociatedObject(tap, &AxsQQDiceCardItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [row addGestureRecognizer:tap];
        }
        [content addSubview:row];
    }
    return cell;
}

+ (void)axs_qqdice_rowTapped:(UITapGestureRecognizer *)gesture {
    AxsQQDiceSettingItem *item = objc_getAssociatedObject(gesture, &AxsQQDiceCardItemKey);
    if (item.actionBlock) {
        item.actionBlock();
    }
}

@end
