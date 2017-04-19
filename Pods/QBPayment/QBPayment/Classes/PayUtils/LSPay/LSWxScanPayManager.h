//
//  LSWxScanPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/4/19.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface LSWxScanPayManager : NSObject

@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *key;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
