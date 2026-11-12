# AxsQQDice

QQ 9.2.75 骰子与猜拳插件，当前处于发送链路诊断阶段。

## 当前状态

- 已停止构建旧悬浮球入口及全局 JSON 改写 Hook；旧源码仍保留，方便对照。
- 根据 QQ 9.2.75 的 `QQMsgService.h`，监听 `sendAniStickerMsg:faceContent:additionalMsg:callBack:` 和 `sendMarketFaceMsg:marketFaceInfo:additionalMsg:callBack:`。
- 这两个方法是候选路径，尚未证实普通聊天里的骰子和猜拳会经过它们。
- Hook 保留 QQ 原发送行为，不修改消息，也不会弹出选择界面。
- 暂未实现指定点数或猜拳结果。classdump 没有提供具体表情标识、结果编码或方法实现，必须先通过真实设备确认。

## 测试

使用 Theos 构建、注入 QQ 9.2.75 并完全重启后，在自己的测试会话分别发送骰子、石头剪刀布和普通表情。用 Filza 在 QQ 应用数据容器的 `Documents/AxsQQDice.log` 查看日志，或通过设备系统日志筛选 `AxsQQDice`。启动日志中的 `loaded` 可帮助确认插件已加载，`ani` 和 `market` 表示候选方法是否存在。

日志仅包含候选表情对象的类名和表情标识字段，不主动读取联系人、聊天内容或额外消息。但表情字段仍可能包含 QQ 返回的任意字符串；分享日志前请检查并删除敏感信息。

若所有操作均没有对应发送日志，说明尚未验证到调用路径；若连启动日志也没有，请检查注入。若只有普通表情产生日志，需继续定位随机动画表情的发送路径。

拿到骰子和猜拳的字段后，才能分别确认表情识别、结果映射及服务端接收情况，再实现点击表情后选择结果的界面。

## 构建

需要 Theos 和 iOS 16.5 SDK，可通过 `sh build.sh rootless` 构建。Windows 工作区未配置 Theos，构建和真机行为均待验证。
