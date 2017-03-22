//
//  QLLiveShowJumpQueuePopView.h
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLLiveShowJumpQueuePopView : UIView

@property (nonatomic,retain) QLLiveShow *liveShow;
@property (nonatomic,copy) QBAction jumpQueueAction;

+ (instancetype)popInView:(UIView *)view withLiveShow:(QLLiveShow *)liveShow jumpQueueAction:(QBAction)jumpQueueAction;

@end
