> **当前进度**：悬浮球和选点面板尚需真机验证。点击 QQ 表情图标弹窗选择骰子或猜拳结果、
> 以及实际发送指定结果，均尚未实现。QQ 9.2.75 的 classdump 中可见
> `OCFaceElement` 的 `packId`、`stickerId`、`resultId` 和 `randomType`，
> 但头文件没有说明骰子和猜拳的标识及结果编码，不能仅凭字段名确定发送行为。
> 现有 JSON 诊断不一定能观察到 QQ 的二进制消息。

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

## 已实现，待真机验证

- 悬浮球入口不依赖任何 QQ 私有类：设计上可拖动、点一下开面板，长按直接选点。
- 选点弹窗按 1-6 渲染点阵，写入配置键 `points`。
- 资源识别：在 App 包内查找 `.../dice/1.png` … `6.png`，面板“资源探测”显示命中档数。

## 待真机验证

1. 确认骰子和猜拳点击时实际经过的发送方法，以及 `packId`、`stickerId` 和 `resultId` 的取值。
2. 对照发送端和接收端，确认每个结果的编码及修改后是否被服务器接受。
3. `Hooks/AxsQQDiceProtocol.xm` 仅是未经验证的 JSON 实验，不能证明适配此版本；
   没有 JSON 日志也不能单独证明消息采用了何种编码。

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
3. “强制骰子点数”使用的是未经验证的 JSON 实验，建议保持关闭。
4. 要关闭悬浮球：面板 → 悬浮球入口 关闭。
5. 诊断日志：面板 → 诊断 → 记录骰子协议；日志在
   `Documents/AxsQQDice.log`（App 沙盒，可用 Filza 查看）。
