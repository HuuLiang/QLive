//
//  QLLiveCastViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLVideoPlayerViewController.h"

@interface QLLiveCastViewController : QLVideoPlayerViewController

@property (nonatomic,retain,readonly) QLAnchor *anchor;

- (instancetype)initWithAnchor:(QLAnchor *)anchor;

@end
