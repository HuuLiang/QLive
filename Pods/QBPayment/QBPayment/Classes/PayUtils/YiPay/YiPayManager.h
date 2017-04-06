//
//  YiPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/4/5.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface YiPayManager : NSObject

@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *urlScheme;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo
         completionHandler:(QBPaymentCompletionHandler)completionHandler;

- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
