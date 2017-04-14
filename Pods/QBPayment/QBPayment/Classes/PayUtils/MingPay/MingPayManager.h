//
//  MingPayManager.h
//  Pods
//
//  Created by Sean Yue on 2016/11/16.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface MingPayManager : NSObject

@property (nonatomic) NSString *mch;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
