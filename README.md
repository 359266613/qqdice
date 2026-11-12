> **当前进度**：入口、面板、选点界面、资源识别均已完成并通过静态检查；
> 真正让 QQ 服务器接受指定点数的那一步需要先在你的 QQ 版本上抓一次真实骰子消息
> （面板 → 诊断 → 记录骰子协议，然后发一个骰子，日志在 App 沙盒 `Documents/AxsQQDice.log`）。
> 把日志内容发我，我来收敛 `Hooks/AxsQQDiceProtocol.xm` 的字段规则。

# AxsQQDice（QQ 骰子控点）

越狱插件，目标 `com.tencent.mqq`。包名 `com.axs.qqdice`，类前缀 `AxsQQDice`，
函数前缀 `axs_qqdice_`。

## 结构

```text
Hooks/
  AxsQQDiceMain.xm        悬浮球入口（打开面板 / 长按直接选点）
  AxsQQDiceProtocol.xm    JSON 序列化处改写骰子结果字段 + 诊断日志
Sources/
  AxsQQDiceConfig.h/.m    NSUserDefaults 配置（suite com.axs.qqdice）
  AxsQQDiceDiceResources  骰子图片识别、同目录点数映射、整包扫描
  AxsQQDiceHost.h/.m      取顶层控制器、呈现面板
Controllers/
  AxsQQDicePickerViewController  1-6 点选点弹窗（Core Graphics 画点阵）
  AxsQQDiceRootViewController    面板：启用、立即选点、悬浮球、强制点数、状态、诊断
  AxsQQDiceCard* / Setting*      卡片列表样式（来自技能模板）
Headers/
  AxsQQDicePrivate.h      私有类型说明，不含写死的 QQ 类名
  AxsQQDicePickerViewController.h
```

## 已确认可用

- 悬浮球入口不依赖任何 QQ 私有类：拖动会记住位置，点一下开面板，长按直接选点。
- 选点弹窗按 1-6 渲染点阵，写入配置键 `points`。
- 资源识别：在 App 包内查找 `.../dice/1.png` … `6.png`，面板“资源探测”显示命中档数。

## 待真机验证

1. `Hooks/AxsQQDiceProtocol.xm` 的字段名规则（`result`/`value`/`points`/`random`/`diceResult`/`num`）。
   若日志里出现骰子 JSON 但点数没变，说明字段名或层级不同，按日志改 `axs_qqdice_resultKeys()`。
2. 若日志里**没有**骰子 JSON，说明该版本走的是二进制 protobuf 或本地随机数，
   需要改用 Hook 随机数来源或 protobuf 构造，届时按实际链路再实现。
3. 石头剪刀布：协议里同样是自定义表情，结果字段通常也是 1-3，规则一并覆盖；
   没有抓到样本前不做额外假设。

## 构建

```sh
cd /var/minis/workspace/qqtouzi
sh build.sh rootless        # 或 rootful / roothide / all
```

需要可用的 Theos 与 iOS 16.5 SDK；本工作区没有 Theos，未执行编译。
产物在 `packages/`，`dpkg-deb -I` / `-c` 核对包名、依赖（仅 mobilesubstrate）、
注入过滤器（com.tencent.mqq）与 dylib。

## 使用

1. 安装并注销，打开 QQ，出现骰子悬浮球。
2. 点球进面板 → 启用插件 → 立即选点，或长按球直接选。
3. 打开“强制骰子点数”后发送骰子才会按所选点数尝试改写。
4. 要关闭悬浮球：面板 → 悬浮球入口 关闭。
5. 诊断日志：面板 → 诊断 → 记录骰子协议；日志在
   `Documents/AxsQQDice.log`（App 沙盒，可用 Filza 查看）。
