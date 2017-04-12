//
//  YiPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/4/5.
//
//

#import "YiPayManager.h"
#import "QBPaymentInfo.h"
#import <QBDefines.h>
#import <NSString+md5.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "QBPaymentManager.h"
#import <RACEXTScope.h>
#import <AlipaySDK/AlipaySDK.h>
#import "QBPaymentUtil.h"
#import <SPayClient.h>
#import "SPayUtil.h"
#import "QBPaymentWebViewController.h"

static NSString *const kPayURL = @"http://api.epaysdk.cn/wfNewThreepayApi";
//static NSString *const kWeChatPayURL = @"http://api.epaysdk.cn/threeapppay";//@"http://api.epaysdk.cn/wfalipayscanpay";

@interface YiPayManager ()
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) UIViewController *payingViewController;

@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@end

@implementation YiPayManager

+ (instancetype)sharedManager {
    static YiPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.urlScheme)
        || paymentInfo.orderPrice == 0 || QBP_STRING_IS_EMPTY(paymentInfo.orderId)
        || (paymentInfo.paymentSubType != QBPaySubTypeAlipay)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *orderId = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    NSString *orderDesc = paymentInfo.orderDescription ?: @"商品";
    NSMutableDictionary *params = @{@"subject":orderDesc,
                                    @"total_fee":@(paymentInfo.orderPrice),
                                    @"body":orderDesc,
                                    //@"paychannel":paymentInfo.paymentSubType == QBPaySubTypeAlipay ? @"pay_alipay_wap" : @"YFtencent_app",
                                    @"pay_type":paymentInfo.paymentSubType == QBPaySubTypeAlipay ? @"pay_alipay_wap" : @"pay_weixin_wap",
                                    @"mchNo":self.mchId,
                                    @"tag":paymentInfo.paymentSubType == QBPaySubTypeAlipay ? @"470":@"462",
                                    @"version":@"1.0",
                                    @"appid":self.appId,
                                    @"mchorderid":orderId,
                                    @"show_url":@"www.baidu.com",
                                    @"mch_app_id":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"],
                                    @"device_info":@"IOS_WAP",
                                    @"ua":@"App/WebView",
                                    @"mch_app_name":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
                                    @"callback_url":@"www.baidu.com"}.mutableCopy;
    
//    if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
//        [params addEntriesFromDictionary:@{@"show_url":@"www.baidu.com",
//                                           @"mch_app_id":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"],
//                                           @"device_info":@"IOS_WAP",
//                                           @"ua":@"AppleWebKit/537.36",
//                                           @"mch_app_name":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
//                                           @"callback_url":@"www.baidu.com"}];
//    } else {
//        [params addEntriesFromDictionary:@{@"appName":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
//                                           @"ua":[QBPaymentUtil deviceName] ?: @"",
//                                           @"os":@"ios",
//                                           @"packagename":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]}];
//    }
    
    
    NSMutableString *str = [NSMutableString string];
    NSArray *signedKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [signedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[obj];
        [str appendFormat:@"%@=%@&", obj, value];
    }];
    
    [str appendFormat:@"key=%@", self.key];
    [params setObject:str.md5 forKey:@"sign"];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.sessionManager POST:kPayURL
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task,
                                id  _Nullable responseObject)
    {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSNumber *errorCode = jsonObj[@"errorcode"];
        if (!errorCode || errorCode.integerValue != 0) {
            QBLog(@"YiPay fails: %@", jsonObj[@"errormsg"]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
            NSString *content = jsonObj[@"content"];
            if (content.length == 0) {
                QBLog(@"YiPay fails: response content is empty!");
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                return ;
            }
            
            self.paymentInfo = paymentInfo;
            self.completionHandler = completionHandler;
            
            QBLog(@"YiPay wap open URL: %@", content);
            QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:content]];
            webVC.capturedAlipayRequest = ^(NSURL *url, id obj) {
                [[UIApplication sharedApplication] openURL:url];
            };
            [[QBPaymentUtil viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
            
            self.payingViewController = webVC;

        } else { //QBPaySubTypeWeChat
            NSString *services = jsonObj[@"services"];
            NSString *token_id = jsonObj[@"token_id"];
            NSString *WXappid = jsonObj[@"WXappid"];
            
            if (QBP_STRING_IS_EMPTY(services) || QBP_STRING_IS_EMPTY(token_id)) {
                QBLog(@"YiPay fails: response content is empty!");
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                return ;
            }
            
            SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
            wechatConfigModel.appScheme = WXappid;
            wechatConfigModel.wechatAppid = WXappid;
            [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
            
            [[SPayClient sharedInstance] application:[UIApplication sharedApplication]
                       didFinishLaunchingWithOptions:nil];
            
            self.paymentInfo = paymentInfo;
            self.completionHandler = completionHandler;
            
            [[SPayClient sharedInstance] pay:[QBPaymentUtil viewControllerForPresentingPayment]
                                      amount:@(paymentInfo.orderPrice)
                           spayTokenIDString:token_id
                           payServicesString:@"pay.weixin.app"
                                      finish:^(SPayClientPayStateModel *payStateModel,
                                               SPayClientPaySuccessDetailModel *paySuccessDetailModel)
            {
                QBSafelyCallBlock(completionHandler, payStateModel.payState == SPayClientConstEnumPaySuccess?QBPayResultSuccess:QBPayResultFailure, paymentInfo);
                
                self.paymentInfo = nil;
                self.completionHandler = nil;
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task,
                NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        QBLog(@"YiPay fails: %@", error.localizedDescription);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    }];
//    NSURL *url = [self URLWithParams:params];
//    QBLog(@"YiPay open URL: %@", url.absoluteString);
//    
//    self.paymentInfo = paymentInfo;
//    self.completionHandler = completionHandler;
    
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    [QBPaymentWebViewController presentWebContentWithURL:url inViewController:QBPViewControllerForPresentingPayment()];
////    [[UIApplication sharedApplication] openURL:url];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//    });
}

//- (NSURL *)URLWithParams:(NSDictionary *)params {
//    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@?", kPayURL];
//    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [urlString appendFormat:@"%@=%@&", key, obj];
//    }];
//    
//    if ([urlString hasSuffix:@"&"]) {
//        [urlString deleteCharactersInRange:NSMakeRange(urlString.length-1, 1)];
//    }
//    
//
//    return [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
//}

- (void)handleOpenURL:(NSURL *)url {
//    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//        [self onCallback:resultDic];
//    }];
    
//    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

//- (void)onCallback:(NSDictionary *)resultDic {
//    NSInteger status = [resultDic[@"resultStatus"] integerValue];
//    
//    QBPayResult result = QBPayResultFailure;
//    if (status == 9000) {
//        result = QBPayResultSuccess;
//    } else if (status == 6001) {
//        result = QBPayResultCancelled;
//    }
//    QBSafelyCallBlock(self.completionHandler, result, self.paymentInfo);
//    
//    self.completionHandler = nil;
//    self.paymentInfo = nil;
//}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[QBPaymentManager sharedManager] activatePaymentInfo:self.paymentInfo withRetryTimes:3 shouldCommitFailureResult:YES completionHandler:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        [self.payingViewController dismissViewControllerAnimated:YES completion:nil];
        self.payingViewController = nil;
        
        QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    }];
}
@end

