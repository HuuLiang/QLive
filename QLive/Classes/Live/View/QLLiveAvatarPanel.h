//
//  QLLiveAvatarPanel.h
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLLiveAvatarPanel : UIView

@property (nonatomic,retain) QLAnchor *anchor;
@property (nonatomic,copy) QBAction buttonAction;

+ (instancetype)showPanelInView:(UIView *)view withAnchor:(QLAnchor *)anchor buttonAction:(QBAction)buttonAction;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
