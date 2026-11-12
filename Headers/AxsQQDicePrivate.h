#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AxsQQDiceConfig.h"
#import "AxsQQDiceHost.h"
#import "AxsQQDiceDiceResources.h"

// QQ 私有类只做探测式使用：骰子消息属于"自定义表情"富媒体，协议字段没有公开文档，
// 所以结果改写放在 Hooks/AxsQQDiceProtocol.xm 的 JSON 序列化处，面板里可开关诊断日志，
// 先抓到真实字段名再决定是否细化匹配规则。
