//
//  QBRMPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/3/23.
//
//

#import <Foundation/Foundation.h>
#import <QBPaymentDefines.h>

@interface QBRMPayManager : NSObject

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler;

- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
