#import "AxsQQDiceRootViewController.h"
#import "AxsQQDiceConfig.h"
#import "AxsQQDiceDiceResources.h"
#import "AxsQQDicePickerViewController.h"

@implementation AxsQQDiceRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAppearanceWithTitle:@"QQ骰子控点"];
    [self axs_qqdice_rebuild];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self axs_qqdice_rebuild];
}

- (void)axs_qqdice_rebuild {
    AxsQQDiceConfig *config = [AxsQQDiceConfig axs_qqdice_shared];
    NSMutableArray<AxsQQDiceSettingSection *> *sections = [NSMutableArray array];

    // 功能卡片
    NSMutableArray<AxsQQDiceSettingItem *> *featureItems = [NSMutableArray array];
    [featureItems addObject:
        [AxsQQDiceSettingItem switchItemWithTitle:@"启用插件"
                                          iconName:@"power"
                                         iconColor:[UIColor systemGreenColor]
                                       switchValue:[config axs_qqdice_isEnabled]
                                 valueChangedBlock:^(BOOL isOn) {
            [config axs_qqdice_setEnabled:isOn];
        }]];

    NSInteger stored = axs_qqdice_storedPoints();
    AxsQQDiceSettingItem *pick = [AxsQQDiceSettingItem actionItemWithTitle:@"立即选点"
                                                                   iconName:@"die.face.5"
                                                                  iconColor:[UIColor systemBlueColor]];
    pick.detail = [NSString stringWithFormat:@"当前 %ld 点", (long)stored];
    __weak __typeof(self) weakSelf = self;
    pick.actionBlock = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [AxsQQDicePickerViewController showFrom:self completion:^(NSInteger points) {
            if (points >= 1 && points <= 6) {
                [[AxsQQDiceConfig axs_qqdice_shared] axs_qqdice_setValue:@(points) forKey:@"points"];
                [self axs_qqdice_rebuild];
            }
        }];
    };
    [featureItems addObject:pick];

    [featureItems addObject:
        [AxsQQDiceSettingItem switchItemWithTitle:@"悬浮球入口"
                                          iconName:@"circle.circle"
                                         iconColor:[UIColor systemTealColor]
                                       switchValue:[config axs_qqdice_boolForKey:@"showBall" defaultValue:YES]
                                 valueChangedBlock:^(BOOL isOn) {
            [config axs_qqdice_setValue:@(isOn) forKey:@"showBall"];
        }]];
    [sections addObject:[AxsQQDiceSettingSection sectionWithHeader:@"功能面板" items:featureItems]];

    // 资源探测状态
    NSInteger points = axs_qqdice_scannedPoints();
    NSString *detail = points > 0
        ? [NSString stringWithFormat:@"已识别 %ld 档骰子图片", (long)points]
        : @"未找到骰子图片，请确认 QQ 版本";
    AxsQQDiceSettingItem *status = [AxsQQDiceSettingItem itemWithTitle:@"资源探测"
                                                              iconName:@"magnifyingglass"
                                                             iconColor:[UIColor systemOrangeColor]
                                                                detail:detail];
    status.cellConfigurationBlock = ^(UITableViewCell *cell) {
        cell.detailTextLabel.textColor = points > 0 ? [UIColor systemGreenColor] : [UIColor systemRedColor];
    };
    [sections addObject:[AxsQQDiceSettingSection sectionWithHeader:@"状态" items:@[status]]];

    // 强制点数：改写发送链路里的骰子结果字段
    NSMutableArray<AxsQQDiceSettingItem *> *forceItems = [NSMutableArray array];
    [forceItems addObject:
        [AxsQQDiceSettingItem switchItemWithTitle:@"强制骰子点数"
                                          iconName:@"lock.fill"
                                         iconColor:[UIColor systemRedColor]
                                       switchValue:[config axs_qqdice_boolForKey:@"forcePoints" defaultValue:NO]
                                 valueChangedBlock:^(BOOL isOn) {
            [config axs_qqdice_setValue:@(isOn) forKey:@"forcePoints"];
        }]];
    [sections addObject:[AxsQQDiceSettingSection sectionWithHeader:@"点数控制" items:forceItems]];

    // 诊断开关
    NSMutableArray<AxsQQDiceSettingItem *> *debugItems = [NSMutableArray array];
    [debugItems addObject:
        [AxsQQDiceSettingItem switchItemWithTitle:@"记录骰子协议"
                                          iconName:@"ladybug"
                                         iconColor:[UIColor systemPurpleColor]
                                       switchValue:[config axs_qqdice_boolForKey:@"diagnostics" defaultValue:NO]
                                 valueChangedBlock:^(BOOL isOn) {
            [config axs_qqdice_setValue:@(isOn) forKey:@"diagnostics"];
        }]];
    [sections addObject:[AxsQQDiceSettingSection sectionWithHeader:@"诊断" items:debugItems]];

    self.sections = sections;
    [self.tableView reloadData];
}

@end
