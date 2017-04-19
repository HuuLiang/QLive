//
//  LSWxScanPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/4/19.
//
//

#import "LSWxScanPayManager.h"
#import "QBDefines.h"
#import "QBPaymentInfo.h"
#import "NSString+md5.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "QBPaymentUtil.h"
#import "QBPaymentQRCodeViewController.h"
#import "QBPaymentManager.h"

static NSString *const kLSWxScanPayURL = @"http://pay.ido007.cn/";

@interface LSWxScanPayManager ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@end

@implementation LSWxScanPayManager

+ (instancetype)sharedManager {
    static id _sharedManager;
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
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 30;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (self.mchId.length == 0 || self.key.length == 0 || self.notifyUrl.length == 0 || paymentInfo.orderId.length == 0 || paymentInfo.orderPrice == 0 || paymentInfo.paymentSubType != QBPaySubTypeWeChat) {
        QBLog(@"%@: invalid payment arguments!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSMutableDictionary *params = @{@"mchno":self.mchId,
                                    @"money":[NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice/100.],
                                    @"orderno":paymentInfo.orderId,
                                    @"payType":@"wxpay_pc",
                                    @"notifyUrl":self.notifyUrl,
                                    @"attach":paymentInfo.reservedData?:@""}.mutableCopy;
    NSString *sign = [NSString stringWithFormat:@"%@|%@|%@", params[@"mchno"], params[@"money"], self.key].md5;
    [params setObject:sign forKey:@"sign"];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.sessionManager GET:kLSWxScanPayURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        UIImage *image = [UIImage imageWithData:responseObject];
        if (!image) {
            QBLog(@"%@: prepay response object error!", [self class]);
            QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
            return ;
        }
        
        [QBPaymentQRCodeViewController presentQRCodeInViewController:[QBPaymentUtil viewControllerForPresentingPayment]
                                                           withImage:image
                                                   paymentCompletion:^(id qrVC)
        {
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            [[QBPaymentManager sharedManager] activatePaymentInfo:paymentInfo withRetryTimes:3 shouldCommitFailureResult:YES completionHandler:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                if (success) {
                    [qrVC dismissViewControllerAnimated:YES completion:nil];
                    QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
                } else {
                    QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                }
            }];
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        QBLog(@"%@: prepay fails!", [self class]);
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

@end
