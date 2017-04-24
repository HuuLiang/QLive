//
//  MingPayManager.m
//  Pods
//
//  Created by Sean Yue on 2016/11/16.
//
//

#import "MingPayManager.h"
#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "AFNetworking.h"
#import "SPayClient.h"
#import "MPGYWetChatSDK.h"
#import "MBProgressHUD.h"
#import "QBPaymentUtil.h"
#import "QBPaymentManager.h"
//
//static NSString *const kMingPayWeChatPayURL = @"http://ltongzy.com:8080/apiTvShow/cpay/wxpay";
//static NSString *const kMingPayAlipayURL = @"http://ltongzy.com:8080/apiTvShow/cpay/alipay";
//
//static NSString *const kMingPayWeChatPayStandbyURL = @"http://sdk.hhuanggt.com:8080/apiTvShow/cpay/wxpay";
//static NSString *const kMingPayAlipayStandbyURL = @"http://sdk.hhuanggt.com:8080/apiTvShow/cpay/alipay";

@interface MingPayManager ()
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@end

@implementation MingPayManager

+ (instancetype)sharedManager {
    static MingPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    [self payWithPaymentInfo:paymentInfo isStandby:NO completionHandler:completionHandler];
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
                 isStandby:(BOOL)isStandby
         completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (paymentInfo.orderId.length == 0 || self.mch.length == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    void (^failure)(NSError *error) = ^(NSError *error) {
        if (error) {
            QBLog(@"MingPay error: %@", error.localizedDescription);
        }
        
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    };
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [MPGYWetChatSDK success:^(id data) {
        //解析数据中存在HTML5标签过滤掉
        NSDictionary *dic = [MPGYWetChatSDK filterdata:data];
        NSString *appid;
        if ([dic count] != 0) {
            appid = dic[@"appid"];
            SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
            wechatConfigModel.appScheme = appid;
            wechatConfigModel.wechatAppid = appid;
            //配置微信APP支付
            [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
            [[SPayClient sharedInstance] application:[UIApplication sharedApplication]
                       didFinishLaunchingWithOptions:nil];
            QBLog(@"MingPay appid=%@",appid);
            
        } else {
            failure(nil);
            return ;
        }
        
        NSString *orderIdPrefix = @"P001_";
        NSString *orderId = [MPGYWetChatSDK channelNumber:self.mch];
        NSDictionary *params = @{@"out_trade_no":orderId,
                                 @"total_fee":@(paymentInfo.orderPrice).stringValue,
                                 @"body":paymentInfo.orderDescription,
                                 @"device_info":@"iphone",
                                 @"attach":paymentInfo.reservedData,
                                 @"callback_url":self.notifyUrl};
        paymentInfo.orderId = [orderId substringFromIndex:orderIdPrefix.length];
        [paymentInfo save];
        
        [MPGYWetChatSDK parameters:params.mutableCopy success:^(id data) {
            //解析数据中存在HTML5标签过滤掉
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            NSDictionary *dic = [MPGYWetChatSDK filterdata:data];
            NSLog(@"%@",dic);
            
            NSString *token = dic[@"token_id"];
            if ([token length] != 0) {
                //调起SPaySDK支付
                self.paymentInfo = paymentInfo;
                self.completionHandler = completionHandler;
                
                [[SPayClient sharedInstance] pay:[QBPaymentUtil viewControllerForPresentingPayment]
                                          amount:nil
                               spayTokenIDString:token
                               payServicesString:@"pay.weixin.app"
                                          finish:^(SPayClientPayStateModel *payStateModel,
                                                   SPayClientPaySuccessDetailModel *paySuccessDetailModel) {
                                              
                                              if (payStateModel.payState != SPayClientConstEnumPaySuccess) {
                                                  failure(nil);
                                              }
                                              
                                          }];
                
            } else {
                failure(nil);
            }
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    
//    NSString *orderId = [self processOrderNo:paymentInfo.orderId];
//    
//    NSDictionary *params = @{@"out_trade_no":orderId,
//                             @"device_info":@"1",
//                             @"body":paymentInfo.orderDescription?:@"",
//                             @"attach":paymentInfo.reservedData ?: @"",
//                             @"goods_tag":@"1",
//                             @"total_fee":[NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice/100.],
//                             @"callback_url": @""};
//    
//    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] init];
//    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [sessionManager POST:kMingPayWeChatPayURL
//              parameters:params
//                progress:nil
//                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
//     {
//         
//     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
//     {
//         QBLog(@"Ming Pay Error: %@", error.localizedDescription);
//     }];
}

//- (NSString *)processOrderNo:(NSString *)orderNo {
//    const CGFloat maxOrderNoLength = 30;
//    
//    NSMutableString *replacedOrderNo = orderNo.mutableCopy;
//    [replacedOrderNo replaceOccurrencesOfString:@"_" withString:@"-" options:0 range:NSMakeRange(0, replacedOrderNo.length)];
//    
//    if (self.mchId.length == 0) {
//        return [replacedOrderNo substringFromIndex:MAX(0, replacedOrderNo.length-maxOrderNoLength)];
//    }
//    
//    NSString *trimmedOrderNo = [NSString stringWithFormat:@"%@_%@", self.mchId, [replacedOrderNo substringFromIndex:MAX(0, replacedOrderNo.length-(maxOrderNoLength-self.mchId.length-1))]];
//    return trimmedOrderNo;
//}

- (void)handleOpenURL:(NSURL *)url {
    [[SPayClient sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [[SPayClient sharedInstance] applicationWillEnterForeground:application];
    
    if (self.paymentInfo == nil) {
        return ;
    }
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[QBPaymentManager sharedManager] activatePaymentInfo:self.paymentInfo withRetryTimes:5 shouldCommitFailureResult:YES completionHandler:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        QBSafelyCallBlock(self.completionHandler, success ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    }];
}
@end
