//
//  QLLivePrivateShowContactViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"

@interface QLLivePrivateShowContactViewController : QLBaseViewController

@property (nonatomic,retain) QLAnchor *anchor;
@property (nonatomic,retain) QLLiveShow *liveShow;

+ (instancetype)showContactInViewController:(UIViewController *)viewController withAnchor:(QLAnchor *)anchor;
+ (instancetype)showContactInViewController:(UIViewController *)viewController withLiveShow:(QLLiveShow *)liveShow;

@end
