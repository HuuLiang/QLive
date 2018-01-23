//
//  QLHUDManager.h
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLHUDManager : NSObject

QBDeclareSingletonMethod(sharedManager)

- (void)showLoading;
- (void)showLoadingInfo:(NSString *)info;
- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration complete:(void (^)(void))complete;
- (void)showLoadingInfo:(NSString *)info
           withDuration:(NSTimeInterval)duration
            isSucceeded:(BOOL)isSucceeded
               complete:(NSString *(^)(void))complete;

- (void)showError:(NSString *)error;
- (void)showSuccess:(NSString *)success;
- (void)showInfo:(NSString *)info;

- (void)hide;

@end
