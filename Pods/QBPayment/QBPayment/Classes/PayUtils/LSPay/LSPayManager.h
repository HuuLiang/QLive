//
//  LSPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/1/13.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface LSPayManager : NSObject

@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *urlScheme;

+ (instancetype)sharedManager;
- (void)setup;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
