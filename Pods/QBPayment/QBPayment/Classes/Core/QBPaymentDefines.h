//
//  QBPaymentDefines.h
//  Pods
//
//  Created by Sean Yue on 16/9/13.
//
//

#ifndef QBPaymentDefines_h
#define QBPaymentDefines_h

typedef NS_ENUM(NSUInteger, QBPayType) {
    QBPayTypeNone,
    QBPayTypeAlipay = 1001,
    QBPayTypeWeChatPay = 1008,
    QBPayTypeIAppPay = 1009, //爱贝支付
    QBPayTypeVIAPay = 1010, //首游时空
    QBPayTypeSPay = 1012, //威富通
    QBPayTypeHTPay = 1015, //海豚支付
    QBPayTypeMTDLPay = 1017, //明天动力
    QBPayTypeMingPay = 1018, //明鹏支付
    QBPayTypeDXTXPay = 1019, //盾行天下
    QBPayTypeWJPay = 1020, // 无极支付
    QBPayTypeWeiYingPay = 1022, //微赢支付
    QBPayTypeXLTXPay = 1023, //星罗天下
    QBPayTypeJSPay = 1028, //杰莘
    QBPayTypeHeePay = 1029,     //汇付宝
    QBPayTypeMLYPay = 1030, // 萌乐游
    QBPayTypeLSPay = 1031, // 雷胜app支付
    QBPayTypeRMPay = 1032, // 融梦支付
    QBPayTypeZRPay = 1033, // 中润付(甬润支付)
    QBPayTypeYiPay = 1034, // 易支付
    QBPayTypeLSScanPay = 1035, //雷胜扫码支付
    QBPayTypeDXTXScanPay = 1036, //盾行天下扫码支付
    QBPayTypeLePay = 1037,    //乐Pay
    QBPayTypeUnknown = 9999
};

typedef NSUInteger QBPayPointType;

//typedef NS_ENUM(NSUInteger, QBPayPointType) {
//    QBPayPointTypeNone,
//    QBPayPointTypeVIP,
//    QBPayPointTypeSVIP
//};

typedef NS_ENUM(NSUInteger, QBPaySubType) {
    QBPaySubTypeNone = 0,
    QBPaySubTypeWeChat = 1 << 0,
    QBPaySubTypeAlipay = 1 << 1,
    QBPaySubTypeUPPay = 1 << 2,
    QBPaySubTypeQQ = 1 << 3
};

typedef NS_ENUM(NSInteger, QBPayResult)
{
    QBPayResultSuccess   = 0,
    QBPayResultFailure   = 1,
    QBPayResultCancelled = 2,
    QBPayResultUnknown   = 3
};

typedef NS_ENUM(NSUInteger, QBPayStatus) {
    QBPayStatusUnknown,
    QBPayStatusPaying,
    QBPayStatusNotProcessed,
    QBPayStatusProcessed
};

@class QBPaymentInfo;
typedef void (^QBPaymentCompletionHandler)(QBPayResult payResult, QBPaymentInfo *paymentInfo);

#define QBPDEPRECATED(desc) __attribute__((unavailable(desc)))

#define QBP_STRING_IS_EMPTY(str) (str.length==0)

#endif /* QBPaymentDefines_h */
