#import "AxsQQDiceHost.h"
#import <objc/runtime.h>

UIWindow *axs_qqdice_keyWindow(void) {
    UIWindow *keyWindow = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]] ||
            scene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (keyWindow) {
            break;
        }
    }
    if (!keyWindow) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        keyWindow = UIApplication.sharedApplication.keyWindow;
#pragma clang diagnostic pop
    }
    return keyWindow;
}

UIViewController *axs_qqdice_topMostViewController(void) {
    UIViewController *top = axs_qqdice_keyWindow().rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    if ([top isKindOfClass:[UINavigationController class]]) {
        top = [(UINavigationController *)top topViewController];
    } else if ([top isKindOfClass:[UITabBarController class]]) {
        top = [(UITabBarController *)top selectedViewController];
    }
    return top;
}

void axs_qqdice_presentPanel(UIViewController *host) {
    Class panelClass = NSClassFromString(@"AxsQQDiceRootViewController");
    if (!panelClass) {
        return;
    }
    UIViewController *panel = [[panelClass alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:panel];
    navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    UIViewController *presenter = host ?: axs_qqdice_topMostViewController();
    [presenter presentViewController:navigation animated:YES completion:nil];
}
