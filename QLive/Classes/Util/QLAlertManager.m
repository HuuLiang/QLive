//
//  QLAlertManager.m
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLAlertManager.h"
#import <SIAlertView.h>

@implementation QLAlertManager

QBSynthesizeSingletonMethod(sharedManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SIAlertView appearance] setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleFade];
    }
    return self;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alert show];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message action:(QBAction)action {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        QBSafelyCallBlock(action, self);
    }];
    [alert show];
}

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              OKButton:(NSString *)OKButton
          cancelButton:(NSString *)cancelButton
              OKAction:(QBAction)OKAction
          cancelAction:(QBAction)cancelAction
{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:cancelButton type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        QBSafelyCallBlock(cancelAction, self);
    }];
    [alert addButtonWithTitle:OKButton type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        QBSafelyCallBlock(OKAction, self);
    }];
    [alert show];
    
}
@end
