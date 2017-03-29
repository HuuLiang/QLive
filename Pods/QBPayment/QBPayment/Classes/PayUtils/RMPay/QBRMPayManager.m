//
//  QBRMPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/3/23.
//
//

#import "QBRMPayManager.h"
#import "RMPayManager.h"
#import "QBPaymentInfo.h"
#import <QBDefines.h>

@interface QBRMPayManager () <RMPayManagerDelegate>
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;
@end

@implementation QBRMPayManager

+ (instancetype)sharedManager {
    static QBRMPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [RMPayManager sharedInstance].delegate = self;
        [RMPayManager sharedInstance].isPay = YES;
    }
    return self;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler
{
    if (self.appId.length == 0 || self.mchId.length == 0 || self.key.length == 0) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    self.paymentInfo = paymentInfo;
    self.completionHandler = completionHandler;
    
    [[RMPayManager sharedInstance] clickToPayAppId:self.appId
                                         PartnerId:self.mchId
                                               Key:self.key
                                    ChannelOrderId:paymentInfo.orderId
                                              Body:paymentInfo.orderDescription
                                            Detail:paymentInfo.orderDescription
                                          TotalFee:@(paymentInfo.orderPrice)
                                            Attach:paymentInfo.reservedData
                                         NotifyUrl:self.notifyUrl
                                        Controller:[UIApplication sharedApplication].keyWindow.rootViewController
                                             Block:^(NSInteger state)
    {
        
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[RMPayManager sharedInstance] application:[UIApplication sharedApplication] handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[RMPayManager sharedInstance] checkOrderState];
}

#pragma mark - RMPayManagerDelegate

- (void)checkOrderWithState:(NSInteger)state Msg:(NSString *)msg {
    if (self.paymentInfo) {
        QBSafelyCallBlock(self.completionHandler, state == 0 ? QBPayResultSuccess : QBPayResultFailure, self.paymentInfo);
        
        self.paymentInfo = nil;
        self.completionHandler = nil;
    }
    
}
@end
