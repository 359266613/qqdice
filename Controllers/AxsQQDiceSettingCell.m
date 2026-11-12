#import "AxsQQDiceSettingCell.h"

@interface AxsQQDiceSettingCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;
@property (nonatomic, strong) UISwitch *settingSwitch;
@property (nonatomic, strong) NSLayoutConstraint *titleLeadingWithIcon;
@property (nonatomic, strong) NSLayoutConstraint *titleLeadingWithoutIcon;
@property (nonatomic, strong, readwrite) AxsQQDiceSettingItem *item;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *trailingViewConstraints;
@end

@implementation AxsQQDiceSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self axs_qqdice_commonInit];
    }
    return self;
}

- (void)axs_qqdice_commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImageView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightSemibold];
    _titleLabel.textColor = [UIColor labelColor];
    [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_titleLabel];

    _detailLabel = [[UILabel alloc] init];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.font = [UIFont systemFontOfSize:13.0f];
    _detailLabel.textColor = [UIColor secondaryLabelColor];
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_detailLabel];

    UIImageSymbolConfiguration *symbolConfig =
        [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightSemibold];
    _chevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"
                                                                   withConfiguration:symbolConfig]];
    _chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _chevronImageView.tintColor = [UIColor tertiaryLabelColor];
    [self.contentView addSubview:_chevronImageView];

    _settingSwitch = [[UISwitch alloc] init];
    _settingSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [_settingSwitch addTarget:self action:@selector(axs_qqdice_switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_settingSwitch];

    self.titleLeadingWithIcon = [_titleLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12.0f];
    self.titleLeadingWithoutIcon = [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20.0f];

    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20.0f],
        [_iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:20.0f],
        [_iconImageView.heightAnchor constraintEqualToConstant:20.0f],
        self.titleLeadingWithIcon,
        [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_chevronImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0f],
        [_chevronImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_chevronImageView.widthAnchor constraintEqualToConstant:10.0f],
        [_chevronImageView.heightAnchor constraintEqualToConstant:16.0f],
        [_settingSwitch.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0f],
        [_settingSwitch.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_detailLabel.trailingAnchor constraintEqualToAnchor:_chevronImageView.leadingAnchor constant:-8.0f],
        [_detailLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_detailLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:_titleLabel.trailingAnchor constant:8.0f],
    ]];
    self.titleLeadingWithoutIcon.active = NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
    self.detailTextColor = nil;
    self.customTrailingView = nil;
}

- (void)setDetailTextColor:(UIColor *)detailTextColor {
    _detailTextColor = detailTextColor;
    self.detailLabel.textColor = detailTextColor ?: [UIColor secondaryLabelColor];
}

- (void)setCustomTrailingView:(UIView *)customTrailingView {
    [NSLayoutConstraint deactivateConstraints:self.trailingViewConstraints ?: @[]];
    self.trailingViewConstraints = nil;
    [_customTrailingView removeFromSuperview];
    _customTrailingView = customTrailingView;
    BOOL custom = customTrailingView != nil;
    if (custom) {
        customTrailingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:customTrailingView];
        CGSize size = customTrailingView.bounds.size;
        self.trailingViewConstraints = @[
            [customTrailingView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0f],
            [customTrailingView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [customTrailingView.widthAnchor constraintEqualToConstant:MAX(size.width, 1.0f)],
            [customTrailingView.heightAnchor constraintEqualToConstant:MAX(size.height, 1.0f)],
        ];
        [NSLayoutConstraint activateConstraints:self.trailingViewConstraints];
        self.detailLabel.hidden = YES;
        self.chevronImageView.hidden = YES;
    }
}

- (void)configureWithItem:(AxsQQDiceSettingItem *)item {
    self.item = item;
    self.titleLabel.text = item.title;
    self.detailLabel.text = item.detail;
    self.detailLabel.hidden = item.detail.length == 0;
    self.detailLabel.textColor = [UIColor secondaryLabelColor];
    self.customTrailingView = nil;

    UIImage *icon = item.iconName.length > 0 ? [UIImage systemImageNamed:item.iconName] : nil;
    self.iconImageView.image = icon;
    self.iconImageView.tintColor = item.iconColor ?: [UIColor systemBlueColor];
    self.iconImageView.hidden = icon == nil;
    self.titleLeadingWithIcon.active = icon != nil;
    self.titleLeadingWithoutIcon.active = icon == nil;

    BOOL isSwitch = item.itemType == AxsQQDiceSettingItemTypeSwitch;
    self.settingSwitch.hidden = !isSwitch;
    self.chevronImageView.hidden = item.itemType != AxsQQDiceSettingItemTypeAction;
    if (isSwitch) {
        [self.settingSwitch setOn:item.switchValue animated:NO];
        self.detailLabel.hidden = YES;
    }
    if (item.cellConfigurationBlock) {
        item.cellConfigurationBlock(self);
    }
}

- (void)axs_qqdice_switchChanged:(UISwitch *)sender {
    self.item.switchValue = sender.isOn;
    if (self.item.switchValueChanged) {
        self.item.switchValueChanged(sender.isOn);
    }
}

@end
