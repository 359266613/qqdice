#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 面板与弹窗都需要一个可用的宿主控制器；QQ 的窗口层级随版本变化，
// 这里统一按活动 scene -> keyWindow -> 顶层控制器取。
UIWindow * _Nullable axs_qqdice_keyWindow(void);
UIViewController * _Nullable axs_qqdice_topMostViewController(void);
void axs_qqdice_presentPanel(UIViewController * _Nullable host);

NS_ASSUME_NONNULL_END
