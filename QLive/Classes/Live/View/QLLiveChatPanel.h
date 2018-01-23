//
//  QLLiveChatPanel.h
//  QLive
//
//  Created by Sean Yue on 2017/3/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLLiveChatPanel : UIView

@property (nonatomic,copy) QBAction sendAction;

+ (instancetype)showPanelInView:(UIView *)view withSendAction:(QBAction)sendAction;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
