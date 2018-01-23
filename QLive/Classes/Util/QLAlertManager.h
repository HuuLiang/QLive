//
//  QLAlertManager.h
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLAlertManager : NSObject

QBDeclareSingletonMethod(sharedManager)

- (void)alertWithTitle:(NSString *)title message:(NSString *)message;
- (void)alertWithTitle:(NSString *)title message:(NSString *)message action:(QBAction)action;
- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              OKButton:(NSString *)OKButton
          cancelButton:(NSString *)cancelButton
              OKAction:(QBAction)OKAction
          cancelAction:(QBAction)cancelAction;


@end
