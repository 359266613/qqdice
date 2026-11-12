#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

// 骰子图片识别：QQ 的骰子在本地是 .../dice/1.png ... 6.png 这样的资源，
// 这里只做路径识别与同目录映射，不涉及协议字段。
NSInteger axs_qqdice_pointsForPath(NSString * _Nullable path);
NSString * _Nullable axs_qqdice_switchPoints(NSString * _Nullable path, NSInteger points);
NSInteger axs_qqdice_storedPoints(void);
NSArray<NSString *> *axs_qqdice_scannedDicePaths(void);
NSInteger axs_qqdice_scannedPoints(void);
void axs_qqdice_scanDiceResources(void);

// 选点界面（由面板/Hook 共用，同一份实现）。
void axs_qqdice_showDicePicker(UIViewController *host, void (^ _Nullable completion)(NSInteger points));

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
