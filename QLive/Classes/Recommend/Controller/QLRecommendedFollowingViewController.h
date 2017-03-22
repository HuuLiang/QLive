//
//  QLRecommendedFollowingViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"

@interface QLRecommendedFollowingViewController : QLBaseViewController

+ (void)showViewControllerIfNeededInViewController:(UIViewController *)viewController;

- (instancetype)init __attribute__((unavailable("Use initWithAnchors: instead!")));
- (instancetype)initWithAnchors:(NSArray<QLAnchor *> *)anchors;
- (void)showInViewController:(UIViewController *)viewController;

@end
