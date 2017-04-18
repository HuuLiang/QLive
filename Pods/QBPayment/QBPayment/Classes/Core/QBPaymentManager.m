//
//  QBPaymentManager.m
//  QBPayment
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "QBPaymentManager.h"
#import "QBPaymentNetworkingConfiguration.h"
#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "NSString+md5.h"
#import "RACEXTScope.h"
#import "QBPaymentConfig.h"
#import "Aspects.h"
#import <MBProgressHUD.h>

//#import "QBSystemConfigModel.h"
#import "QBPaymentConfigModel.h"
#import "QBPaymentCommitModel.h"
#import "QBOrderQueryModel.h"
#import "QBPaymentPlugins.h"
#import "QBPaymentUtil.h"

typedef NS_ENUM(NSUInteger, QBVIAPayType) {
    QBVIAPayTypeNone,
    QBVIAPayTypeWeChat = 2,
    QBVIAPayTypeQQ = 3,
    QBVIAPayTypeUPPay = 4,
    QBVIAPayTypeShenZhou = 5
};

NSString *const kQBPaymentFetchConfigNotification = @"com.qbpayment.app.config";

@interface QBPaymentManager ()
<NSObject
#ifdef QBPAYMENT_VIAPAY_ENABLED
,stringDelegate
#endif
#ifdef QBPAYMENT_MTDLPAY_ENABLED
,QJPayManagerDelegate
#endif
>
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) QBPaymentConfigModel *configModel;
@property (nonatomic,retain) QBPaymentCommitModel *commitModel;
@property (nonatomic,retain) QBOrderQueryModel *orderQueryModel;
@property (nonatomic) NSString *urlScheme;
@property (nonatomic) BOOL shouldCommitPayment;
@property (nonatomic) BOOL everFetchedConfig;

@end

@implementation QBPaymentManager

QBDefineLazyPropertyInitialization(QBPaymentConfigModel, configModel)
QBDefineLazyPropertyInitialization(QBPaymentCommitModel, commitModel)
QBDefineLazyPropertyInitialization(QBOrderQueryModel, orderQueryModel)

+ (instancetype)sharedManager {
    static QBPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldCommitPayment = YES;
        
#ifdef QBPAYMENT_VIAPAY_ENABLED
        Class class = NSClassFromString(@"VIASZFViewController");
        if (class) {
            [class aspect_hookSelector:NSSelectorFromString(@"viewWillAppear:")
                           withOptions:AspectPositionAfter
                            usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated)
            {
                UIViewController *thisVC = [aspectInfo instance];
                if ([thisVC respondsToSelector:NSSelectorFromString(@"buy")]) {
                    UIViewController *buyVC = [thisVC valueForKey:@"buy"];
                    [buyVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[UIButton class]]) {
                            UIButton *buyButton = (UIButton *)obj;
                            if ([[buyButton titleForState:UIControlStateNormal] isEqualToString:@"购卡支付"]) {
                                [buyButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                            }
                        }
                    }];
                }
            } error:nil];
        }
#endif
        
//#ifdef QBPAYMENT_DXTXPAY_ENABLED
//        @weakify(self);
//        [PayuPlugin aspect_hookSelector:@selector(applicationWillEnterForeground:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIApplication *application)
//        {
//            @strongify(self);
//            [MBProgressHUD showHUDAddedTo:application.keyWindow animated:YES];
//            [self activatePaymentInfos:@[self.paymentInfo] withRetryTimes:3 completionHandler:^(BOOL success, id obj) {
//                [[MBProgressHUD HUDForView:application.keyWindow] hide:YES];
//                
//                @strongify(self);
//                QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
//                self.completionHandler = nil;
//                self.paymentInfo = nil;
//            }];
//        } error:nil];
//#endif
    }
    return self;
}

#pragma mark - Register payment

- (void)registerPaymentWithAppId:(NSString *)appId
                       paymentPv:(NSNumber *)pv
                       channelNo:(NSString *)channelNo
                       urlScheme:(NSString *)urlScheme
                   defaultConfig:(QBPaymentConfig *)defaultConfig
             shouldCommitPayment:(BOOL)shouldCommitPayment
                  defaultTimeOut:(NSTimeInterval)defaultTimeOut
{
    [QBPaymentNetworkingConfiguration defaultConfiguration].RESTAppId = appId;
    [QBPaymentNetworkingConfiguration defaultConfiguration].RESTpV = pv;
    [QBPaymentNetworkingConfiguration defaultConfiguration].channelNo = channelNo;
    [QBPaymentNetworkingConfiguration defaultConfiguration].paymentTimeOut = defaultTimeOut;
    
    self.urlScheme = urlScheme;
    self.shouldCommitPayment = shouldCommitPayment;
    
    [defaultConfig setAsCurrentConfig];
    
#ifdef QBPAYMENT_VIAPAY_ENABLED
    [[PayUitls getIntents] initSdk];
    [paySender getIntents].delegate = self;
#endif
    
#ifdef QBPAYMENT_IAPPPAY_ENABLED
    [IappPayMananger sharedMananger].alipayURLScheme = urlScheme;
#endif
    
    [self refreshAvailablePaymentTypesWithCompletionHandler:nil];
    
    if (self.shouldCommitPayment) {
        [self.commitModel startRetryingToCommitUnprocessedOrders];
    }
}

- (void)registerPaymentWithAppId:(NSString *)appId
                       paymentPv:(NSNumber *)pv
                       channelNo:(NSString *)channelNo
                       urlScheme:(NSString *)urlScheme
                   defaultConfig:(QBPaymentConfig *)defaultConfig
             shouldCommitPayment:(BOOL)shouldCommitPayment {
    [self registerPaymentWithAppId:appId paymentPv:pv channelNo:channelNo urlScheme:urlScheme defaultConfig:defaultConfig shouldCommitPayment:shouldCommitPayment defaultTimeOut:0];
}

- (void)registerPaymentWithAppId:(NSString *)appId
                       paymentPv:(NSNumber *)pv
                       channelNo:(NSString *)channelNo
                       urlScheme:(NSString *)urlScheme
{
    [self registerPaymentWithAppId:appId paymentPv:pv channelNo:channelNo urlScheme:urlScheme defaultConfig:nil shouldCommitPayment:YES];
}

- (void)registerPaymentWithAppId:(NSString *)appId
                       paymentPv:(NSNumber *)pv
                       channelNo:(NSString *)channelNo
                       urlScheme:(NSString *)urlScheme
                   defaultConfig:(QBPaymentConfig *)defaultConfig {
    [self registerPaymentWithAppId:appId paymentPv:pv channelNo:channelNo urlScheme:urlScheme defaultConfig:defaultConfig shouldCommitPayment:YES];
}

- (void)registerPaymentWithAppId:(NSString *)appId
                       paymentPv:(NSNumber *)pv
                       channelNo:(NSString *)channelNo
                       urlScheme:(NSString *)urlScheme
                   defaultConfig:(QBPaymentConfig *)defaultConfig
                  defaultTimeOut:(NSTimeInterval)defaultTimeOut {
    [self registerPaymentWithAppId:appId paymentPv:pv channelNo:channelNo urlScheme:urlScheme defaultConfig:defaultConfig shouldCommitPayment:YES defaultTimeOut:defaultTimeOut];
}

- (void)refreshAvailablePaymentTypesWithCompletionHandler:(void (^)(void))completionHandler {
    [self.configModel fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        //        if ([QBPaymentConfig sharedConfig].configDetails.mingPayConfig) {
        //            [MingPayManager sharedManager].mch = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.mch;
        //            [MingPayManager sharedManager].payUrl = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.payUrl;
        //            [MingPayManager sharedManager].queryOrderUrl = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig.queryOrderUrl;
        //        }
        //
        
        if (success) {
            self.everFetchedConfig = YES;
        }
        
#ifdef QBPAYMENT_HTPAY_ENABLED
        QBHTPayConfig *htPayConfig = [QBPaymentConfig sharedConfig].configDetails.htpayConfig;
        if (htPayConfig) {
            [HTPayManager sharedManager].mchId = htPayConfig.mchId;
            [HTPayManager sharedManager].key = htPayConfig.key;
            [HTPayManager sharedManager].notifyUrl = htPayConfig.notifyUrl;
//            [HTPayManager sharedManager].appid = htPayConfig.appid;
            [HTPayManager sharedManager].payType = htPayConfig.payType;
            [[HTPayManager sharedManager] setup];
        }
#endif
        
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        QBDXTXPayConfig *dxtxPayConfig = [QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig;
        if (dxtxPayConfig) {
            [[PayuPlugin defaultPlugin] registWithAppKey:dxtxPayConfig.appKey
                                             application:[UIApplication sharedApplication]
                                           launchOptions:nil];
        }
#endif
        
#ifdef QBPAYMENT_WFTPAY_ENABLED
        QBSPayConfig *spayConfig = [QBPaymentConfig sharedConfig].configDetails.spayConfig;
        if (spayConfig) {
            [SPayUtil sharedInstance].appId = spayConfig.appId;
            [SPayUtil sharedInstance].mchId = spayConfig.mchId;
            [SPayUtil sharedInstance].signKey = spayConfig.signKey;
            [SPayUtil sharedInstance].notifyUrl = spayConfig.notifyUrl;
            [[SPayUtil sharedInstance] setup];
        }

#endif
        
#ifdef QBPAYMENT_MLYPAY_ENABLED
        QBMLYPayConfig *mlyPayConfig = [QBPaymentConfig sharedConfig].configDetails.mlyPayConfig;
        if (mlyPayConfig) {
            [MLYPayManager sharedManager].appid = mlyPayConfig.appid;
            [MLYPayManager sharedManager].key = mlyPayConfig.key;
            [MLYPayManager sharedManager].mchId = mlyPayConfig.mchId;
            [MLYPayManager sharedManager].channelId = mlyPayConfig.channelId;
            [MLYPayManager sharedManager].notifyUrl = mlyPayConfig.notifyUrl;
        }
#endif
        
#ifdef QBPAYMENT_HEEPAY_ENABLED
        QBHeePayConfig *heePayConfig = [QBPaymentConfig sharedConfig].configDetails.heePayConfig;
        if (heePayConfig) {
            [HeePayManager sharedManager].mchId = heePayConfig.mchId;
            [HeePayManager sharedManager].key = heePayConfig.key;
            [HeePayManager sharedManager].notifyUrl = heePayConfig.notifyUrl;
        }
#endif
        
#ifdef QBPAYMENT_XLTXPAY_ENABLED
        QBXLTXPayConfig *xltxPayConfig = [QBPaymentConfig sharedConfig].configDetails.xltxPayConfig;
        if (xltxPayConfig) {
            [XLTXPayManager sharedManager].appid = xltxPayConfig.appid;
            [XLTXPayManager sharedManager].key = xltxPayConfig.key;
            [XLTXPayManager sharedManager].urlScheme = self.urlScheme;
        }
        
#endif
        
#ifdef QBPAYMENT_MINGPAY_ENABLED
        QBMingPayConfig *mingPayConfig = [QBPaymentConfig sharedConfig].configDetails.mingPayConfig;
        if (mingPayConfig) {
            [MingPayManager sharedManager].mch = mingPayConfig.mch;
            [MingPayManager sharedManager].notifyUrl = mingPayConfig.notifyUrl;
        }
#endif
        
#ifdef QBPAYMENT_WJPAY_ENABLED
        QBWJPayConfig *wjPayConfig = [QBPaymentConfig sharedConfig].configDetails.wjPayConfig;
        if (wjPayConfig) {
            [WJPayManager sharedManager].mchId = wjPayConfig.mchId;
            [WJPayManager sharedManager].signKey = wjPayConfig.signKey;
            [WJPayManager sharedManager].notifyUrl = wjPayConfig.notifyUrl;
            [[WJPayManager sharedManager] setup];
        }
#endif
        
#ifdef QBPAYMENT_JSPAY_ENABLED
        QBJSPayConfig *jsPayConfig = [QBPaymentConfig sharedConfig].configDetails.jsPayConfig;
        if (jsPayConfig) {
            [JsAppPay wechatpPayConfigWithApplication:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil appId:jsPayConfig.productId];
        }
#endif
        
#ifdef QBPAYMENT_LSPAY_ENABLED
        QBLSPayConfig *lsPayConfig = [QBPaymentConfig sharedConfig].configDetails.lsPayConfig;
        if (lsPayConfig) {
            [LSPayManager sharedManager].mchId = lsPayConfig.mchId;
            [LSPayManager sharedManager].key = lsPayConfig.key;
            [LSPayManager sharedManager].notifyUrl = lsPayConfig.notifyUrl;
            [LSPayManager sharedManager].urlScheme = self.urlScheme;
            [[LSPayManager sharedManager] setup];
        }
#endif
        
#ifdef QBPAYMENT_RMPAY_ENABLED
        QBRMPayConfig *rmPayConfig = [QBPaymentConfig sharedConfig].configDetails.rmPayConfig;
        if (rmPayConfig) {
            [QBRMPayManager sharedManager].appId = rmPayConfig.appId;
            [QBRMPayManager sharedManager].mchId = rmPayConfig.mchId;
            [QBRMPayManager sharedManager].key = rmPayConfig.key;
            [QBRMPayManager sharedManager].notifyUrl = rmPayConfig.notifyUrl;
        }
#endif 
        
#ifdef QBPAYMENT_ZRPAY_ENABLED
        QBZRPayConfig *zrPayConfig = [QBPaymentConfig sharedConfig].configDetails.zrPayConfig;
        if (zrPayConfig) {
            [ZRPayManager sharedManager].appId = zrPayConfig.appId;
            [ZRPayManager sharedManager].key = zrPayConfig.key;
        }
#endif
        
#ifdef QBPAYMENT_YIPAY_ENABLED
        QBYiPayConfig *yiPayConfig = [QBPaymentConfig sharedConfig].configDetails.yiPayConfig;
        if (yiPayConfig) {
            [YiPayManager sharedManager].appId = yiPayConfig.appId;
            [YiPayManager sharedManager].mchId = yiPayConfig.mchId;
            [YiPayManager sharedManager].key = yiPayConfig.key;
            [YiPayManager sharedManager].urlScheme = self.urlScheme;
        }
#endif
        
        QBSafelyCallBlock(completionHandler);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kQBPaymentFetchConfigNotification object:nil];
    }];
}

- (BOOL)isOrderPayTypeAvailable:(QBOrderPayType)orderPayType {
    return [self paymentTypeForOrderPayType:orderPayType] != QBPayTypeNone;
}

- (QBPayType)paymentTypeForOrderPayType:(QBOrderPayType)orderPayType {
    if (orderPayType == QBOrderPayTypeWeChatPay) {
        return [QBPaymentConfig sharedConfig].wechatPaymentType;
    } else if (orderPayType == QBOrderPayTypeAlipay) {
        return [QBPaymentConfig sharedConfig].alipayPaymentType;
    } else if (orderPayType == QBOrderPayTypeQQPay) {
        return [QBPaymentConfig sharedConfig].qqPaymentType;
    } else {
        return QBPayTypeNone;
    }
}

- (BOOL)IsSDKIntegratedForPayType:(QBPayType)payType {

    if (payType == QBPayTypeIAppPay) {
#ifdef QBPAYMENT_IAPPPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeVIAPay) {
#ifdef QBPAYMENT_VIAPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeSPay) {
#ifdef QBPAYMENT_WFTPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeHTPay) {
#ifdef QBPAYMENT_HTPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeMingPay) {
#ifdef QBPAYMENT_MINGPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeDXTXPay) {
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeWeiYingPay) {
#ifdef QBPAYMENT_WEIYINGPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeMTDLPay) {
#ifdef QBPAYMENT_MTDLPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeJSPay) {
#ifdef QBPAYMENT_JSPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeHeePay) {
#ifdef QBPAYMENT_HEEPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeXLTXPay) {
#ifdef QBPAYMENT_XLTXPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeWJPay) {
#ifdef QBPAYMENT_WJPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeMLYPay) {
#ifdef QBPAYMENT_MLYPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeLSPay) {
#ifdef QBPAYMENT_LSPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeRMPay) {
#ifdef QBPAYMENT_RMPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeZRPay) {
#ifdef QBPAYMENT_ZRPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    } else if (payType == QBPayTypeYiPay) {
#ifdef QBPAYMENT_YIPAY_ENABLED
        return YES;
#else
        return NO;
#endif
    }
    return NO;
}

#pragma mark - Start payment

- (BOOL)startPaymentWithOrderInfo:(QBOrderInfo *)orderInfo
                      contentInfo:(QBContentInfo *)contentInfo
                      beginAction:(QBAction)beginAction
                completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    QBPaymentInfo *paymentInfo = [[QBPaymentInfo alloc] initWithOrderInfo:orderInfo contentInfo:contentInfo];
    paymentInfo.paymentType = [self paymentTypeForOrderPayType:orderInfo.payType];
    
    if (paymentInfo.paymentType == QBPayTypeNone || paymentInfo.orderId.length == 0 || paymentInfo.orderPrice == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return NO;
    }
    
    void (^CustomOrderDescription)(QBPaymentInfo *paymentInfo) = ^(QBPaymentInfo *paymentInfo) {
        paymentInfo.orderDescription = [QBPaymentConfig sharedConfig].contact.length > 0 ? [QBPaymentConfig sharedConfig].contact : orderInfo.orderDescription;
    };
    
    if (self.everFetchedConfig) {
        CustomOrderDescription(paymentInfo);
        return [self startPaymentWithPaymentInfo:paymentInfo maxDiscount:orderInfo.maxDiscount beginAction:beginAction completionHandler:completionHandler];
    } else {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [self refreshAvailablePaymentTypesWithCompletionHandler:^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            paymentInfo.paymentType = [self paymentTypeForOrderPayType:orderInfo.payType];
            CustomOrderDescription(paymentInfo);
            [self startPaymentWithPaymentInfo:paymentInfo maxDiscount:orderInfo.maxDiscount beginAction:beginAction completionHandler:completionHandler];
        }];
        return YES;
    }
}

- (BOOL)startPaymentWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                        maxDiscount:(NSUInteger)maxDiscount
                        beginAction:(QBAction)beginAction
                  completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    QBPayType payType = paymentInfo.paymentType;
    QBPaySubType subType = paymentInfo.paymentSubType;
    
    paymentInfo.orderId = [self realPaymentOrderIdWithPaymentInfo:paymentInfo];
    paymentInfo.orderPrice = [self realPaymentPriceWithPaymentInfo:paymentInfo maxDiscount:maxDiscount];
//    paymentInfo.orderDescription = [self realOrderDescriptionWithPaymentInfo:paymentInfo];
    paymentInfo.paymentStatus = QBPayStatusPaying;
    [paymentInfo save];
    
    self.paymentInfo = paymentInfo;
    self.completionHandler = completionHandler;
    
    @weakify(self);
    QBPaymentCompletionHandler paymentHandler = ^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
        @strongify(self);
        [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
        QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    };
    
    BOOL success = NO;
#ifdef QBPAYMENT_VIAPAY_ENABLED
    if (payType == QBPayTypeVIAPay && (subType == QBPaySubTypeAlipay || subType == QBPaySubTypeWeChat || subType == QBPaySubTypeQQ)) {
        
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        NSDictionary *viaPayTypeMapping = @{@(QBPaySubTypeAlipay):@(QBVIAPayTypeShenZhou),
                                            @(QBPaySubTypeWeChat):@(QBVIAPayTypeWeChat),
                                            @(QBPaySubTypeQQ):@(QBVIAPayTypeQQ)};
        
        [[PayUitls getIntents]   gotoPayByFee:@(paymentInfo.orderPrice).stringValue
                                 andTradeName:paymentInfo.orderDescription
                              andGoodsDetails:paymentInfo.orderDescription
                                    andScheme:self.urlScheme
                            andchannelOrderId:[paymentInfo.orderId stringByAppendingFormat:@"$%@", [QBPaymentNetworkingConfiguration defaultConfiguration].RESTAppId]
                                      andType:[viaPayTypeMapping[@(subType)] stringValue]
                             andViewControler:[QBPaymentUtil viewControllerForPresentingPayment]];
        
        success = YES;
    }
#endif

#ifdef QBPAYMENT_IAPPPAY_ENABLED
    if (payType == QBPayTypeIAppPay) {
        
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        QBIAppPayConfig *payConfig = [QBPaymentConfig sharedConfig].configDetails.iAppPayConfig;
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = payConfig.appid;
        iAppMgr.privateKey = payConfig.privateKey;
        iAppMgr.waresid = payConfig.waresid.stringValue;
        iAppMgr.appUserId = paymentInfo.userId ?: @"UnregisterUser";
        iAppMgr.privateInfo = paymentInfo.reservedData;
        iAppMgr.notifyUrl = payConfig.notifyUrl;
        iAppMgr.publicKey = payConfig.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo payType:subType completionHandler:paymentHandler];
        
        success = YES;
    }
#endif

#ifdef QBPAYMENT_DXTXPAY_ENABLED
    if (payType == QBPayTypeDXTXPay && (subType == QBPaySubTypeWeChat || subType == QBPaySubTypeAlipay)) {
        success = YES;
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        NSNumber *goodsId = [QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.waresid;
        NSString *appKey = [QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.appKey;
        
        [[PayuPlugin defaultPlugin] payWithViewController:[QBPaymentUtil viewControllerForPresentingPayment]
                                             o_paymode_id:PayTypeWXApp
                                                O_bizcode:paymentInfo.orderId
                                               o_goods_id:goodsId.intValue
                                             o_goods_name:paymentInfo.orderDescription
                                                  o_price:paymentInfo.orderPrice/100.
                                                o_address:[QBPaymentConfig sharedConfig].configDetails.dxtxPayConfig.notifyUrl
                                            o_showaddress:nil
                                            o_privateinfo:paymentInfo.reservedData
                                                   Scheme:self.urlScheme
                                                   AppKey:appKey
                                            completeBlock:^(NSDictionary *result)
        {
            QBLog(@"DXTX payment response: %@", result);
            
            NSInteger code = [result[@"resultStatus"] integerValue];
            QBPayResult payResult = QBPayResultFailure;
            if (code == 6001) {
                payResult = QBPayResultCancelled;
            } else if (code == 9000) {
                payResult = QBPayResultSuccess;
            }
            paymentHandler(payResult, paymentInfo);
        }];
        
//        [[PayuPlugin defaultPlugin] payWithViewController:[UIApplication sharedApplication].keyWindow.rootViewController
//                                             o_paymode_id:subType==QBPaySubTypeWeChat?PayTypeWX:PayTypeAliPay
//                                                O_bizcode:paymentInfo.orderId
//                                               o_goods_id:goodsId.intValue
//                                             o_goods_name:paymentInfo.orderDescription
//                                                  o_price:paymentInfo.orderPrice/100.
//                                            o_privateinfo:paymentInfo.reservedData
//                                                   Scheme:self.urlScheme
//                                                   AppKey:appKey
//                                            completeBlock:^(NSDictionary *result)
//        {
//            QBLog(@"DXTX payment response: %@", result);
//            
//            NSInteger code = [result[@"resultStatus"] integerValue];
//            QBPayResult payResult = QBPayResultFailure;
//            if (code == 6001) {
//                payResult = QBPayResultCancelled;
//            } else if (code == 9000) {
//                payResult = QBPayResultSuccess;
//            }
//            paymentHandler(payResult, paymentInfo);
//        }
//         ];
    }
#endif
    
#ifdef QBPAYMENT_MTDLPAY_ENABLED
    if (payType == QBPayTypeMTDLPay && (subType == QBPaySubTypeWeChat || subType == QBPaySubTypeAlipay)) {
        
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        QBMTDLPayConfig *payConfig = [QBPaymentConfig sharedConfig].configDetails.mtdlPayConfig;
        
        if (!payConfig.appid || !payConfig.appKey) {
            success = NO;
        } else {
            success = YES;
            
            NSString *contactInfo = @"客服电话：4008007161";
            
            NSMutableDictionary *params = @{@"amount":@(paymentInfo.orderPrice).stringValue,
                                     @"appid":payConfig.appid,
                                     @"body":contactInfo,
                                     @"mchntOrderNo":paymentInfo.orderId,
                                     @"subject":paymentInfo.orderDescription ?: @"",
                                     @"notifyUrl":payConfig.notifyUrl ?: @"",
                                     @"extra":paymentInfo.reservedData ?: @"",
                                     @"payChannelId":subType == QBPaySubTypeWeChat ? [QJPaySDK PAY_WEIXIN] : [QJPaySDK PAY_APLIPAY]}.mutableCopy;

            [QJPaySDK QJPayStart:params
                       AppScheme:self.urlScheme
                          appKey:payConfig.appKey
        andCurrentViewController:[QBPaymentUtil viewControllerForPresentingPayment]
                     andDelegate:self
                            Flag:0x80];
        }
    }
#endif
    
#ifdef QBPAYMENT_HTPAY_ENABLED
    if (payType == QBPayTypeHTPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [[HTPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:^(BOOL success, id obj) {
            if (success) {
                [self activatePaymentInfo:paymentInfo withRetryTimes:3 shouldCommitFailureResult:YES completionHandler:^(BOOL success, id obj) {
                    [hud hide:YES];
                    if (success) {
                        QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
                    } else {
                        QBSafelyCallBlock(paymentHandler, QBPayResultFailure, paymentInfo);
                    }
                    
                }];
            } else {
                [hud hide:YES];
                QBSafelyCallBlock(paymentHandler, QBPayResultFailure, paymentInfo);
            }
        }];
        
        success = YES;
    }
#endif
    
#if defined(QBPAYMENT_WFTPAY_ENABLED)
    if (payType == QBPayTypeSPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        [[SPayUtil sharedInstance] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
        
        success = YES;
    }
#endif
    
#ifdef QBPAYMENT_JSPAY_ENABLED
    if (payType == QBPayTypeJSPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        
        QBJSPayConfig *payConfig = [QBPaymentConfig sharedConfig].configDetails.jsPayConfig;
        
        if (subType == QBPaySubTypeWeChat) {
            success = YES;
            
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            [[JsAppPay sharedInstance] payOrderWithweixinPay:[QBPaymentUtil viewControllerForPresentingPayment] description:paymentInfo.orderDescription goodsAmount:@(paymentInfo.orderPrice).stringValue appId:payConfig.productId paraId:payConfig.mchId orderId:paymentInfo.orderId notifyUrl:payConfig.notifyUrl attach:paymentInfo.reservedData key:payConfig.key withSuccessBlock:^(id resultDic) {
                
                void (^Handler)(void) = ^{
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    QBPayResult payResult = [resultDic isEqual:@"wxsuccess"] ? QBPayResultSuccess : QBPayResultFailure;
                    paymentHandler(payResult, paymentInfo);
                };
                
                if ([NSThread currentThread].isMainThread) {
                    Handler();
                } else {
                    dispatch_async(dispatch_get_main_queue(), Handler);
                }
                
            }];
        }
//        else if (subType == QBPaySubTypeAlipay) {
//            success = YES;
//            
//            [[JsPay sharedInstance] payOrderWithAliPayWithdescription:paymentInfo.orderDescription
//                                                          goodsAmount:@(paymentInfo.orderPrice).stringValue
//                                                                appId:payConfig.productId
//                                                               paraId:payConfig.mchId
//                                                               scheme:self.urlScheme
//                                                              orderId:paymentInfo.orderId
//                                                            notifyUrl:payConfig.notifyUrl
//                                                     withSuccessBlock:^(id resultDic)
//            {
//                QBPayResult payResult = [resultDic isEqual:@"alisuccess"] ? QBPayResultSuccess : QBPayResultFailure;
//                paymentHandler(payResult, paymentInfo);
//            }];
//        }
    }
#endif
    
#ifdef QBPAYMENT_HEEPAY_ENABLED
    if (payType == QBPayTypeHeePay && subType == QBPaySubTypeWeChat) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[HeePayManager sharedManager] payWithPaymentInfo:paymentInfo
                                        completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_XLTXPAY_ENABLED
    if (payType == QBPayTypeXLTXPay && (subType == QBPaySubTypeWeChat || subType == QBPaySubTypeAlipay)) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[XLTXPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_MINGPAY_ENABLED
    if (payType == QBPayTypeMingPay && (subType == QBPaySubTypeWeChat || subType == QBPaySubTypeAlipay)) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[MingPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
            QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
            
            self.paymentInfo = nil;
            self.completionHandler = nil;
        }];
    }
#endif
    
#ifdef QBPAYMENT_WJPAY_ENABLED
    if (payType == QBPayTypeWJPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[WJPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_MLYPAY_ENABLED
    if (payType == QBPayTypeMLYPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[MLYPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
            QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
            
            self.paymentInfo = nil;
            self.completionHandler = nil;
        }];
    }
#endif
    
#ifdef QBPAYMENT_LSPAY_ENABLED
    if (payType == QBPayTypeLSPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[LSPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_RMPAY_ENABLED
    if (payType == QBPayTypeRMPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[QBRMPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_ZRPAY_ENABLED
    if (payType == QBPayTypeZRPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[ZRPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:paymentHandler];
    }
#endif
    
#ifdef QBPAYMENT_YIPAY_ENABLED
    if (payType == QBPayTypeYiPay) {
        QBSafelyCallBlock(beginAction, paymentInfo);
        success = YES;
        
        [[YiPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
//            if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
//                [self onPaymentResult:payResult withPaymentInfo:paymentInfo];
//            }
            QBSafelyCallBlock(completionHandler, payResult, paymentInfo);
            
            self.paymentInfo = nil;
            self.completionHandler = nil;
        }];
        
    }
#endif
    
    if (!success) {
        paymentHandler(QBPayResultFailure, paymentInfo);
    }
    return success;
}

- (NSString *)realPaymentOrderIdWithPaymentInfo:(QBPaymentInfo *)paymentInfo {
    if (paymentInfo.paymentType == QBPayTypeLSPay) {
        return [NSUUID UUID].UUIDString.md5;
    }
    return paymentInfo.orderId;
}

- (NSUInteger)realPaymentPriceWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                                  maxDiscount:(NSUInteger)maxDiscount
{
    if (maxDiscount == 0) {
        return paymentInfo.orderPrice;
    }
    
    if (paymentInfo.paymentType == QBPayTypeMLYPay && paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        if (paymentInfo.orderPrice <= 1000) {
            return paymentInfo.orderPrice;
        }
        
        const NSUInteger discountPrice = (1+arc4random_uniform(maxDiscount)) * 10;
        return paymentInfo.orderPrice - discountPrice;
    }
    return paymentInfo.orderPrice;
}

- (NSString *)realOrderDescriptionWithPaymentInfo:(QBPaymentInfo *)paymentInfo
{
    NSArray *orderDescs = @[@"豪华大礼包",@"至尊大礼包",@"终极大礼包"];
    
    NSUInteger index = paymentInfo.targetPayPointType == 0 ? 0 : (paymentInfo.targetPayPointType-1) % orderDescs.count;
    return orderDescs[index];
}

- (void)onPaymentResult:(QBPayResult)payResult withPaymentInfo:(QBPaymentInfo *)paymentInfo {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = payResult;
    paymentInfo.paymentStatus = QBPayStatusNotProcessed;
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (self.shouldCommitPayment) {
        [self.commitModel commitPaymentInfo:paymentInfo];
    }
}

#pragma mark - ApplicationCallback

- (void)handleOpenUrl:(NSURL *)url {
    if (self.paymentInfo.paymentType == QBPayTypeIAppPay) {
#ifdef QBPAYMENT_IAPPPAY_ENABLED
        [[IappPayMananger sharedMananger] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeVIAPay) {
#ifdef QBPAYMENT_VIAPAY_ENABLED
        [[PayUitls getIntents] paytoAli:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeDXTXPay) {
#ifdef QBPAYMENT_DXTXPAY_ENABLED
//        [[PayuPlugin defaultPlugin] processOrderWithPaymentResult:url];
        [[PayuPlugin defaultPlugin] application:[UIApplication sharedApplication] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMingPay) {
#ifdef QBPAYMENT_MINGPAY_ENABLED
        //        [[PayuPlugin defaultPlugin] processOrderWithPaymentResult:url];
        [[MingPayManager sharedManager] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMTDLPay) {
#ifdef QBPAYMENT_MTDLPAY_ENABLED
        [QJPaySDK handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMLYPay) {
#ifdef QBPAYMENT_MLYPAY_ENABLED
        [[MLYPayManager sharedManager] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeLSPay) {
#ifdef QBPAYMENT_LSPAY_ENABLED
        [[LSPayManager sharedManager] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeRMPay) {
#ifdef QBPAYMENT_RMPAY_ENABLED
        [[QBRMPayManager sharedManager] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeZRPay) {
#ifdef QBPAYMENT_ZRPAY_ENABLED
        [[ZRPayManager sharedManager] handleOpenURL:url];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeYiPay) {
#ifdef QBPAYMENT_YIPAY_ENABLED
        [[YiPayManager sharedManager] handleOpenURL:url];
#endif
    }
    //    else if (self.paymentInfo.paymentType == QBPayTypeJSPay) {
    //#ifdef QBPAYMENT_JSPAY_ENABLED
    //        [JsPay backMessageWithURL:url];
    //#endif
    //    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [WYPayManager heepaySDKWillEnterForeground];
//    [[SPayUtil sharedInstance] applicationWillEnterForeground];
    if (self.paymentInfo.paymentType == QBPayTypeDXTXPay) {
#ifdef QBPAYMENT_DXTXPAY_ENABLED
        [[PayuPlugin defaultPlugin] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeSPay) {
#if defined(QBPAYMENT_WFTPAY_ENABLED)
        [[SPayUtil sharedInstance] applicationWillEnterForeground];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMingPay) {
#if defined(QBPAYMENT_MINGPAY_ENABLED)
        [[MingPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeHTPay) {
#ifdef QBPAYMENT_HTPAY_ENABLED
        [[HTPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMTDLPay) {
#ifdef QBPAYMENT_MTDLPAY_ENABLED
        [[NSNotificationCenter defaultCenter] postNotificationName:[QJPaySDK WETCHAR] object:nil];
#endif
//    } else if (self.paymentInfo.paymentType == QBPayTypeJSPay) {
//#ifdef QBPAYMENT_JSPAY_ENABLED
//        [JsAppPay applicationWillEnterForeground:application];
//#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeXLTXPay) {
#ifdef QBPAYMENT_XLTXPAY_ENABLED
        [[XLTXPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeWJPay) {
#ifdef QBPAYMENT_WJPAY_ENABLED
        [[WJPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeMLYPay) {
#ifdef QBPAYMENT_MLYPAY_ENABLED
        [[MLYPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeLSPay) {
#ifdef QBPAYMENT_LSPAY_ENABLED
        [[LSPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeRMPay) {
#ifdef QBPAYMENT_RMPAY_ENABLED
        [[QBRMPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeZRPay) {
#ifdef QBPAYMENT_ZRPAY_ENABLED
        [[ZRPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    } else if (self.paymentInfo.paymentType == QBPayTypeYiPay) {
#ifdef QBPAYMENT_YIPAY_ENABLED
        [[YiPayManager sharedManager] applicationWillEnterForeground:application];
#endif
    }
}

- (void)usePaymentConfigInTestServer:(BOOL)useTestConfig {
    self.configModel.isTest = useTestConfig;
}

#pragma mark - Activate payment

- (void)activatePaymentInfos:(NSArray<QBPaymentInfo *> *)paymentInfos withRetryTimes:(NSUInteger)retryTimes completionHandler:(QBCompletionHandler)completionHandler {
    @weakify(self);
    [self activatePaymentInfos:paymentInfos withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (retryTimes == 0 || success) {
            QBSafelyCallBlock(completionHandler, success, obj);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1), dispatch_get_global_queue(0, 0), ^{
                [self activatePaymentInfos:paymentInfos withRetryTimes:retryTimes-1 completionHandler:completionHandler];
            });
        }
    }];
}

- (void)activatePaymentInfo:(QBPaymentInfo *)paymentInfo
             withRetryTimes:(NSUInteger)retryTimes
  shouldCommitFailureResult:(BOOL)shouldCommitFailureResult
          completionHandler:(QBCompletionHandler)completionHandler {
    [self activatePaymentInfos:@[paymentInfo] withRetryTimes:retryTimes completionHandler:^(BOOL success, id obj) {
        if (!success && shouldCommitFailureResult) {
            [self onPaymentResult:QBPayResultFailure withPaymentInfo:paymentInfo];
        }
        
        QBSafelyCallBlock(completionHandler, success, paymentInfo);
    }];
}

- (void)activatePaymentInfos:(NSArray<QBPaymentInfo *> *)paymentInfos
       withCompletionHandler:(QBCompletionHandler)completionHandler
{
    NSMutableString *orders = [NSMutableString string];
    [paymentInfos enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.orderId.length > 0) {
            [orders appendString:obj.orderId];
            
            if (idx != paymentInfos.count-1) {
                [orders appendString:@"|"];
            }
        }
    }];
    
    if (orders.length == 0) {
        QBSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    @weakify(self);
    [self.orderQueryModel queryOrder:orders withCompletionHandler:^(BOOL success, id obj) {
        if (success) {
            if (![obj isKindOfClass:[NSString class]]) {
                QBSafelyCallBlock(completionHandler, NO, nil);
                return ;
            }
            
            NSArray<NSString *> *paidOrders = [obj componentsSeparatedByString:@"|"];
            __block QBPaymentInfo *paidPaymentInfo;
            [paymentInfos enumerateObjectsUsingBlock:^(QBPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([paidOrders containsObject:obj.orderId]) {
                    paidPaymentInfo = obj;
                    *stop = YES;
                }
            }];
            
            if (paidPaymentInfo) {
                @strongify(self);
                [self onPaymentResult:QBPayResultSuccess withPaymentInfo:paidPaymentInfo];
            }
            
            QBSafelyCallBlock(completionHandler, paidPaymentInfo != nil, paidPaymentInfo);
        } else {
            QBSafelyCallBlock(completionHandler, NO, nil);
        }
    }];
}

#ifdef QBPAYMENT_VIAPAY_ENABLED

#pragma mark - VIAPay Callback

- (void)getResult:(NSDictionary *)sender {
    QBPayResult paymentResult = sender[@"result"] == nil ? QBPayResultFailure : [sender[@"result"] integerValue] == 0 ? QBPayResultSuccess : QBPayResultFailure;
    if (paymentResult == QBPayResultFailure) {
        QBLog(@"首游时空支付失败：%@", sender[@"info"]);
//    } else if (paymentResult == PAYRESULT_SUCCESS) {
//        UIViewController *currentController = [QBUtil currentVisibleViewController];
//        if ([currentController isKindOfClass:NSClassFromString(@"SZFViewController")]) {
//            [currentController dismissViewControllerAnimated:YES completion:nil];
//        }
    }
    
    [self onPaymentResult:paymentResult withPaymentInfo:self.paymentInfo];
    
    if (self.completionHandler) {
        if ([NSThread currentThread].isMainThread) {
            self.completionHandler(paymentResult, self.paymentInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(paymentResult, self.paymentInfo);
            });
        }
    }
}
#endif

#ifdef QBPAYMENT_MTDLPAY_ENABLED

#pragma mark - MTDLPay Callback

- (void)QJPayResponseResult:(int)response {
    NSDictionary *payResultMapping = @{@0:@(QBPayResultSuccess),
                                       @1:@(QBPayResultCancelled),
                                       @-1:@(QBPayResultFailure)};
    
    NSNumber *value = payResultMapping[@(response)];
    QBPayResult payResult = value ? value.integerValue : QBPayResultFailure;
    
    [self onPaymentResult:payResult withPaymentInfo:self.paymentInfo];
    QBSafelyCallBlock(self.completionHandler, payResult, self.paymentInfo);
}

#endif

#pragma mark - Deprecated methods

- (QBPayType)wechatPaymentType {
    return [self paymentTypeForOrderPayType:QBOrderPayTypeWeChatPay] ? QBPayTypeUnknown : QBPayTypeNone;
}

- (QBPayType)alipayPaymentType {
    return [self paymentTypeForOrderPayType:QBOrderPayTypeAlipay] ? QBPayTypeUnknown : QBPayTypeNone;
}

- (QBPayType)cardPayPaymentType {
    //    if ([QBPaymentConfig sharedConfig].iappPayInfo) {
    //        return QBPayTypeIAppPay;
    //    }
    return QBPayTypeNone;
}

- (QBPayType)qqPaymentType {
    return [self paymentTypeForOrderPayType:QBOrderPayTypeQQPay] ? QBPayTypeUnknown : QBPayTypeNone;
}

- (BOOL)startPaymentWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    return [self startPaymentWithPaymentInfo:paymentInfo maxDiscount:0 beginAction:nil completionHandler:completionHandler];
}
@end
