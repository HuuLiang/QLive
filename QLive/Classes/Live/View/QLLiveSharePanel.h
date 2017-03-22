//
//  QLLiveSharePanel.h
//  QLive
//
//  Created by Sean Yue on 2017/3/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLLiveSharePanel : UIView

@property (nonatomic,copy) QBAction shareAction;

+ (instancetype)showPanelInView:(UIView *)view withShareAction:(QBAction)shareAction;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
