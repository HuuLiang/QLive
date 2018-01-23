//
//  QLLiveShowViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLVideoPlayerViewController.h"

@interface QLLiveShowViewController : QLVideoPlayerViewController

@property (nonatomic,retain,readonly) QLLiveShow *liveShow;

- (instancetype)initWithLiveShow:(QLLiveShow *)liveShow;

@end
