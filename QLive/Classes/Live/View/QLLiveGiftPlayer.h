//
//  QLLiveGiftPlayer.h
//  QLive
//
//  Created by Sean Yue on 2017/3/16.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLLiveGift.h"

@interface QLLiveGiftPlayer : UIView

- (void)showGift:(QLLiveGift *)gift byUser:(QLUser *)user inView:(UIView *)view;

@end
