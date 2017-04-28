//
//  LSPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/1/13.
//
//

#import "LSPayManager.h"
#import "AFNetworking.h"
#import "QBDefines.h"
#import "QBPaymentInfo.h"
#import "NSString+md5.h"
//#import "LsWxPayManager.h"
#import "MBProgressHUD.h"
#import "QBPaymentWebViewController.h"
#import "QBPaymentManager.h"
#import "QBPaymentInfo.h"
#import <RACEXTScope.h>
#import <lsPay/LsPayManager.h>
#import "QBPaymentUtil.h"
#import "LSWxScanPayManager.h"

static NSString *const kLSPayURL = @"http://payapi.ido007.cn/api/";

@interface LSPayManager ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) UIViewController *payingVC;

@end

@implementation LSPayManager

+ (instancetype)sharedManager {
    static id _sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
//    [[LsWxPayManager sharedInstance] macChannelConfig];
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 30;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (paymentInfo.paymentType == QBPayTypeLSScanPay && paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        [LSWxScanPayManager sharedManager].mchId = self.mchId;
        [LSWxScanPayManager sharedManager].notifyUrl = self.notifyUrl;
        [LSWxScanPayManager sharedManager].key = self.key;
        [[LSWxScanPayManager sharedManager] payWithPaymentInfo:paymentInfo completionHandler:completionHandler];
        return ;
    }
    
    if (self.mchId.length == 0 || self.key.length == 0 || self.notifyUrl.length == 0 || paymentInfo.orderId.length == 0 || paymentInfo.orderPrice == 0) {
        QBLog(@"%@: invalid payment arguments!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *payTypeString;
    if (paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        payTypeString = @"wxpay_ios";
    } else if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
        if (paymentInfo.paymentType == QBPayTypeLSScanPay) {
            payTypeString = @"alipay_wap";
        } else {
            payTypeString = @"alipay_ios";
        }
        
    } else {
        QBLog(@"%@: invalid payment arguments!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *priceString = [NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice/100.];
    NSString *sign = [NSString stringWithFormat:@"%@|%@|%@", self.mchId, priceString, self.key].md5;
    
    NSDictionary *params = @{@"orderno":paymentInfo.orderId,
                             @"mchno":self.mchId,
                             @"money":priceString,
                             @"payType":payTypeString,
                             @"notifyUrl":self.notifyUrl,
                             @"attach":paymentInfo.reservedData ?: @"",
                             @"sign":sign};
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.sessionManager POST:kLSPayURL
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSString *respStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (!respStr) {
            QBLog(@"%@: prepay response object error!", [self class]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        } else {
            QBLog(@"%@ prepay response: %@", [self class], respStr);
        }
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            QBLog(@"%@: prepay repsonse object error!", [self class]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        if (paymentInfo.paymentType == QBPayTypeLSScanPay) {
            NSString *payURL = jsonObject[@"pay_url"];
            if (payURL.length > 0) {
                self.paymentInfo = paymentInfo;
                self.completionHandler = completionHandler;
                
                QBLog(@"LS Wap Pay open URL: %@", payURL);
                QBPaymentWebViewController *webVC = [[QBPaymentWebViewController alloc] initWithURL:[NSURL URLWithString:payURL]];
                webVC.capturedAlipayRequest = ^(NSURL *url, id obj) {
                    [[UIApplication sharedApplication] openURL:url];
                };
                [[QBPaymentUtil viewControllerForPresentingPayment] presentViewController:webVC animated:YES completion:nil];
                
                self.payingVC = webVC;
            } else {
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            }
        } else {
            NSDictionary *payinfo = jsonObject[@"payinfo"];
            if (payinfo == nil) {
                QBLog(@"%@: NO payinfo response!", [self class]);
                QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                return ;
            }
            
            [[LsPayManager sharedInstance] lsPayWithViewController:[QBPaymentUtil viewControllerForPresentingPayment]
                                                          orderStr:payinfo scheme:self.urlScheme
                                                              type:paymentInfo.paymentSubType==QBPaySubTypeAlipay?@"2":@"1"
                                                             block:^(NSDictionary *sender)
             {
                 NSString *payStatus = sender[@"payStatus"];
                 NSString *code = sender[@"code"];
                 QBLog(@"LSPay status: %@", payStatus);
                 
                 QBSafelyCallBlock(completionHandler, [code isEqualToString:@"0"] ? QBPayResultSuccess : QBPayResultFailure, paymentInfo);
             }];
        }
        
        
//        [WXApi registerApp:payinfo[@"appid"]];
//        
//        PayReq *payReq = [[PayReq alloc] init];
//        payReq.openID = payinfo[@"appid"];
//        payReq.partnerId = payinfo[@"mch_id"];
//        payReq.prepayId = payinfo[@"prepay_id"];
//        payReq.nonceStr = payinfo[@"nonce_str"];
//        payReq.timeStamp = [payinfo[@"time"] intValue];
//        payReq.sign = payinfo[@"self_sign"];
//        payReq.package = @"Sign=WXPay";
//        BOOL success = [WXApi sendReq:payReq];
//        
//        @strongify(self);
//        if (success) {
//            self.paymentInfo = paymentInfo;
//            self.completionHandler = completionHandler;
//        } else {
//            QBLog(@"%@: cannot invoke the payment!", [self class]);
//            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
//            return ;
//        }
//        [[LsWxPayManager sharedInstance] sendPayRequestWithViewController:[UIApplication sharedApplication].keyWindow.rootViewController
//                                                                    appid:appid
//                                                                 token_id:token_id
//                                                                  success:^(SPayClientPayStateModel *payStateModel, SPayClientPaySuccessDetailModel *paySuccessDetailModel)
//        {
//            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//            
//            QBSafelyCallBlock(completionHandler, payStateModel.payState == SPayClientConstEnumPaySuccess ? QBPayResultSuccess : QBPayResultFailure, paymentInfo);
//            
//        }];
     
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        QBLog(@"%@: prepay fails!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[LsPayManager sharedInstance] processAuthResult:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    if (self.paymentInfo == nil) {
//        return ;
//    }
//    
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    [[QBPaymentManager sharedManager] activatePaymentInfos:@[self.paymentInfo] withRetryTimes:3 completionHandler:^(BOOL success, id obj) {
//        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        
//        QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
//        
//        self.paymentInfo = nil;
//        self.completionHandler = nil;
//    }];
    [[LsPayManager sharedInstance] applicationWillEnterForeground:application];
    
    if (self.paymentInfo.paymentType == QBPayTypeLSScanPay && self.paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [[QBPaymentManager sharedManager] activatePaymentInfo:self.paymentInfo withRetryTimes:3 shouldCommitFailureResult:YES completionHandler:^(BOOL success, id obj) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            @weakify(self);
            [self.payingVC dismissViewControllerAnimated:YES completion:^{
                @strongify(self);
                self.payingVC = nil;
                
                QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
                
                self.paymentInfo = nil;
                self.completionHandler = nil;
            }];
            
        }];
    }
}
@end
