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
#import "QBPaymentManager.h"
#import "QBPaymentInfo.h"
#import <RACEXTScope.h>
#import <WXApi.h>

static NSString *const kLSPayURL = @"http://payapi.ido007.cn/api/";

@interface LSPayManager ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
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
    if (self.mchId.length == 0 || self.key.length == 0 || self.notifyUrl.length == 0 || paymentInfo.orderId.length == 0 || paymentInfo.orderPrice == 0) {
        QBLog(@"%@: invalid payment arguments!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSString *payTypeString;
    if (paymentInfo.paymentSubType == QBPaySubTypeWeChat) {
        payTypeString = @"wxpay_ios";
    } else if (paymentInfo.paymentSubType == QBPaySubTypeAlipay) {
        payTypeString = @"alipay_ios";
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
    
    @weakify(self);
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
        
        NSDictionary *payinfo = jsonObject[@"payinfo"];
        if (payinfo == nil) {
            QBLog(@"%@: NO payinfo response!", [self class]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        [WXApi registerApp:payinfo[@"appid"]];
        
        PayReq *payReq = [[PayReq alloc] init];
        payReq.openID = payinfo[@"appid"];
        payReq.partnerId = payinfo[@"mch_id"];
        payReq.prepayId = payinfo[@"prepay_id"];
        payReq.nonceStr = payinfo[@"nonce_str"];
        payReq.timeStamp = [payinfo[@"time"] intValue];
        payReq.sign = payinfo[@"sign"];
        payReq.package = @"Sign=WXPay";
        BOOL success = [WXApi sendReq:payReq];
        
        @strongify(self);
        if (success) {
            self.paymentInfo = paymentInfo;
            self.completionHandler = completionHandler;
        } else {
            QBLog(@"%@: cannot invoke the payment!", [self class]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
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
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo == nil) {
        return ;
    }
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[QBPaymentManager sharedManager] activatePaymentInfos:@[self.paymentInfo] withRetryTimes:3 completionHandler:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    }];
//    [[LsWxPayManager sharedInstance] applicationWillEnterForeground:application];
}
@end
