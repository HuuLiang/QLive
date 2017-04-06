//
//  QBPaymentUtil.h
//  Pods
//
//  Created by Sean Yue on 2017/4/5.
//
//

#import <Foundation/Foundation.h>

@interface QBPaymentUtil : NSObject

+ (UIViewController *)viewControllerForPresentingPayment;
+ (NSString *)deviceName;

@end
