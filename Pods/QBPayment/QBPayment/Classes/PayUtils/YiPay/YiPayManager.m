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

static NSString *const kPayURL = @"http://api.epaysdk.cn/threeapppay";//@"http://api.epaysdk.cn/wfalipayscanpay";

@interface YiPayManager ()
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
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
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.mchId) || QBP_STRING_IS_EMPTY(self.appId) || QBP_STRING_IS_EMPTY(self.key) || QBP_STRING_IS_EMPTY(self.urlScheme)
        || paymentInfo.orderPrice == 0 || QBP_STRING_IS_EMPTY(paymentInfo.orderId)
        || (paymentInfo.paymentSubType != QBPaySubTypeWeChat && paymentInfo.paymentSubType != QBPaySubTypeAlipay)) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *orderId = [NSString stringWithFormat:@"%@$%@", paymentInfo.orderId, paymentInfo.reservedData];
    NSString *orderDesc = paymentInfo.orderDescription ?: @"商品";
    NSMutableDictionary *params = @{@"subject":orderDesc,
                                    @"total_fee":@(paymentInfo.orderPrice),
                                    @"body":orderDesc,
                                    @"paychannel":paymentInfo.paymentSubType == QBPaySubTypeAlipay ? @"YFAlipay_app" : @"YFtencent_app",
                                    @"mchNo":self.mchId,
                                    @"tag":@"462",
                                    @"version":@"1.0",
                                    @"appid":self.appId,
                                    @"appName":[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
                                    @"ua":[QBPaymentUtil deviceName] ?: @"",
                                    @"os":@"ios",
                                    @"packagename":[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"],
                                    @"mchorderid":orderId}.mutableCopy;
    
    NSMutableString *str = [NSMutableString string];
    NSArray *signedKeys = @[@"subject",@"total_fee",@"body",@"paychannel",@"mchNo",@"tag",@"version",@"mchorderid"];
    [signedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[obj];
        [str appendFormat:@"%@", value];
    }];
    
    [str appendString:self.key];
    NSString *sign = str.md5;
    [params setObject:sign forKey:@"sign"];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.sessionManager POST:kPayURL
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task,
                                id  _Nullable responseObject)
    {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSInteger status = [jsonObj[@"status"] integerValue];
        if (status != 0) {
            QBLog(@"YiPay fails: %@", jsonObj[@"message"]);
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
            [[AlipaySDK defaultService] payOrder:content fromScheme:self.urlScheme callback:^(NSDictionary *resultDic) {
                [self onCallback:resultDic];
            }];
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
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [self onCallback:resultDic];
    }];
    
//    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)onCallback:(NSDictionary *)resultDic {
    NSInteger status = [resultDic[@"resultStatus"] integerValue];
    
    QBPayResult result = QBPayResultFailure;
    if (status == 9000) {
        result = QBPayResultSuccess;
    } else if (status == 6001) {
        result = QBPayResultCancelled;
    }
    QBSafelyCallBlock(self.completionHandler, result, self.paymentInfo);
    
    self.completionHandler = nil;
    self.paymentInfo = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [[QBPaymentManager sharedManager] activatePaymentInfos:@[self.paymentInfo] withRetryTimes:3 completionHandler:^(BOOL success, id obj) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
            
            self.paymentInfo = nil;
            self.completionHandler = nil;
        }];
    }
}
@end
