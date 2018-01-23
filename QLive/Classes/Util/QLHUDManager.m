//
//  QLHUDManager.m
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLHUDManager.h"
#import <SVProgressHUD.h>
#import <SIAlertView.h>

static const SVProgressHUDMaskType kDefaultMaskType = SVProgressHUDMaskTypeBlack;

@implementation QLHUDManager

QBSynthesizeSingletonMethod(sharedManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        [SVProgressHUD setDefaultMaskType:kDefaultMaskType];
        [SVProgressHUD setMinimumSize:CGSizeMake(kScreenWidth/4, kScreenWidth/4)];
        [SVProgressHUD setMinimumDismissTimeInterval:3];
    }
    return self;
}

- (void)showLoading {
    [SVProgressHUD show];
}

- (void)showLoadingInfo:(NSString *)info {
    [SVProgressHUD showWithStatus:info];
}

- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration complete:(void (^)(void))complete {
    [SVProgressHUD showWithStatus:info];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if (complete) {
            complete();
        }
    });
}

- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration isSucceeded:(BOOL)isSucceeded complete:(NSString *(^)(void))complete {
    [SVProgressHUD showWithStatus:info];
    [self bk_performBlock:^(id obj) {
        NSString *text = complete ? complete() : nil;
        if (isSucceeded) {
            [SVProgressHUD showSuccessWithStatus:text];
        } else {
            [SVProgressHUD showErrorWithStatus:text];
        }
    } afterDelay:duration];
}

- (void)showError:(NSString *)error {
    [SVProgressHUD showErrorWithStatus:error];
}

- (void)showSuccess:(NSString *)success {
    [SVProgressHUD showSuccessWithStatus:success];
}

- (void)showInfo:(NSString *)info {
    [SVProgressHUD showInfoWithStatus:info];
}

- (void)hide {
    [SVProgressHUD dismiss];
}
@end
