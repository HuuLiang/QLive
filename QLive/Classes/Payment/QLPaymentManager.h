//
//  QLPaymentManager.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QLPaymentContentType) {
    QLPaymentContentTypeNone,
    QLPaymentContentTypeVIP,
    QLPaymentContentTypeCharge,
    QLPaymentContentTypePrivateCast, //私播
    QLPaymentContentTypeLightThisCast, //本场点亮
    QLPaymentContentTypeLightMonthlyCast, //包月点亮
    QLPaymentContentTypePrivateShow, //私秀
    QLPaymentContentTypeJumpQueue, //插队
    QLPaymentContentTypeBookThisTicket, //本场观看，上车
    QLPaymentContentTypeBookMonthlyTicket //包月观看，上车
};

@interface QLPaymentManager : NSObject

QBDeclareSingletonMethod(sharedManager)

- (void)setup;
- (void)showPaymnetViewControllerInViewController:(UIViewController *)viewController withContentType:(QLPaymentContentType)contentType userInfo:(NSDictionary *)userInfo completion:(void (^)(BOOL success, QLPayPoint *payPoint))completion;
- (void)showPaymentActionSheetWithPayPoint:(QLPayPoint *)payPoint contentId:(NSNumber *)contentId completed:(void (^)(BOOL success))completed;
- (void)activateUnsuccessfulPayments;

- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)handleOpenUrl:(NSURL *)url;

- (BOOL)contentIsPaidWithContentId:(NSNumber *)contentId contentType:(QLPaymentContentType)contentType;

@end

extern NSString *const kQLPaymentLiveCastAnchorUserInfo;
extern NSString *const kQLPaymentLiveShowUserInfo;
