//
//  DXTXWxScanPayManager.h
//  Pods
//
//  Created by Sean Yue on 2017/4/20.
//
//

#import <Foundation/Foundation.h>
#import "QBPaymentDefines.h"

@interface DXTXWxScanPayManager : NSObject

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;

+ (instancetype)sharedManager;

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler;

@end
