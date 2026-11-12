#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AxsQQDiceConfig.h"
#import "AxsQQDiceDiceResources.h"
#import "AxsQQDiceHost.h"
#import "AxsQQDicePickerViewController.h"

// 入口：可拖动的小球。QQ 的菜单/设置页类名随版本变化，依赖它们会在升级后静默失效，
// 所以这里不 Hook QQ 的任何界面，只在 key window 上挂一个自己的按钮。
// 点一下打开插件面板，长按直接弹选点框；位置会记住。面板里可以关掉它。

static char AxsQQDiceBallKey;
static NSString * const AxsQQDiceBallXKey = @"ballX";
static NSString * const AxsQQDiceBallYKey = @"ballY";

@interface AxsQQDiceBall : UIView <UIGestureRecognizerDelegate>
@end

@implementation AxsQQDiceBall

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.72];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.25;
        self.layer.shadowRadius = 6;
        self.layer.shadowOffset = CGSizeMake(0, 2);

        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"die.face.3"]];
        icon.tintColor = UIColor.whiteColor;
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.translatesAutoresizingMaskIntoConstraints = NO;
        icon.userInteractionEnabled = NO;
        [self addSubview:icon];
        [NSLayoutConstraint activateConstraints:@[
            [icon.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [icon.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:22],
            [icon.heightAnchor constraintEqualToConstant:22],
        ]];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(axs_qqdice_tap:)];
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(axs_qqdice_press:)];
        press.minimumPressDuration = 0.6;
        [self addGestureRecognizer:press];
    }
    return self;
}

- (void)axs_qqdice_tap:(UITapGestureRecognizer *)gesture {
    axs_qqdice_presentPanel(axs_qqdice_topMostViewController());
}

- (void)axs_qqdice_press:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    [AxsQQDicePickerViewController showFrom:axs_qqdice_topMostViewController() completion:^(NSInteger points) {
        if (points >= 1 && points <= 6) {
            [[AxsQQDiceConfig axs_qqdice_shared] axs_qqdice_setValue:@(points) forKey:@"points"];
        }
    }];
}

- (void)axs_qqdice_drag:(UIPanGestureRecognizer *)gesture {
    UIWindow *window = self.superview;
    if (!window) {
        return;
    }
    CGPoint translation = [gesture translationInView:window];
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;
    CGFloat inset = self.bounds.size.width / 2 + 8;
    center.x = MIN(MAX(center.x, inset), window.bounds.size.width - inset);
    center.y = MIN(MAX(center.y, inset + window.safeAreaInsets.top),
                   window.bounds.size.height - inset - window.safeAreaInsets.bottom);
    self.center = center;
    [gesture setTranslation:CGPointZero inView:window];

    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        AxsQQDiceConfig *config = [AxsQQDiceConfig axs_qqdice_shared];
        [config axs_qqdice_setValue:@(center.x) forKey:AxsQQDiceBallXKey];
        [config axs_qqdice_setValue:@(center.y) forKey:AxsQQDiceBallYKey];
    }
}

@end

static void axs_qqdice_installBall(UIWindow *window) {
    if (!window || objc_getAssociatedObject(window, &AxsQQDiceBallKey)) {
        return;
    }
    AxsQQDiceConfig *config = [AxsQQDiceConfig axs_qqdice_shared];
    if (![config axs_qqdice_boolForKey:@"showBall" defaultValue:YES]) {
        return;
    }
    CGFloat side = 46;
    CGFloat x = [config axs_qqdice_doubleForKey:AxsQQDiceBallXKey defaultValue:0];
    CGFloat y = [config axs_qqdice_doubleForKey:AxsQQDiceBallYKey defaultValue:0];
    if (x <= 0 || y <= 0) {
        x = window.bounds.size.width - side - 10;
        y = window.bounds.size.height * 0.62;
    }
    AxsQQDiceBall *ball = [[AxsQQDiceBall alloc] initWithFrame:CGRectMake(x - side / 2, y - side / 2, side, side)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:ball action:@selector(axs_qqdice_drag:)];
    [ball addGestureRecognizer:pan];
    [window addSubview:ball];
    objc_setAssociatedObject(window, &AxsQQDiceBallKey, ball, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void axs_qqdice_removeBalls(void) {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            UIView *ball = objc_getAssociatedObject(window, &AxsQQDiceBallKey);
            [ball removeFromSuperview];
            objc_setAssociatedObject(window, &AxsQQDiceBallKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

static void axs_qqdice_syncBall(void) {
    AxsQQDiceConfig *config = [AxsQQDiceConfig axs_qqdice_shared];
    if ([config axs_qqdice_boolForKey:@"showBall" defaultValue:YES]) {
        axs_qqdice_installBall(UIApplication.sharedApplication.keyWindow ?: axs_qqdice_topMostViewController().view.window);
        return;
    }
    axs_qqdice_removeBalls();
}

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    axs_qqdice_installBall(self);
}

- (void)didMoveToWindow {
    %orig;
    if (self.window == nil) {
        // 根窗口自己 didMoveToWindow 时 window 为 nil，这里按 windowLevel 判断。
        if (self.windowLevel >= UIWindowLevelNormal) {
            axs_qqdice_installBall(self);
        }
    }
}

%end

%ctor {
    @autoreleasepool {
        [AxsQQDiceConfig axs_qqdice_shared];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            axs_qqdice_scanDiceResources();
        });
        [[NSNotificationCenter defaultCenter] addObserverForName:AxsQQDiceConfigDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            axs_qqdice_syncBall();
        }];
    }
}
