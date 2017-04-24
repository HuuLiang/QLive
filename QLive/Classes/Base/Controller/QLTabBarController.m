//
//  QLTabBarController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLTabBarController.h"
#import "QLNavigationController.h"
#import "QLRecommendedFollowingViewController.h"

#import "QLHomeViewController.h"
#import "QLFollowingViewController.h"
#import "QLLiveViewController.h"
#import "QLShowTimeViewController.h"
#import "QLMineViewController.h"

@interface QLTabBarController ()

@end

@implementation QLTabBarController

+ (instancetype)sharedController {
    static QLTabBarController *_sharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[self alloc] init];
        _sharedController.tabBar.translucent = NO;
//        _sharedController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background"];
        _sharedController.tabBar.shadowImage = [[UIImage alloc] init];
        
//        _sharedController.tabBar.barStyle = UIBarStyleBlack;
//        _sharedController.tabBar.shadowImage = [UIImage imageWithColor:[QLTheme defaultTheme].themeColor];
        
        QLHomeViewController *homeVC = [[QLHomeViewController alloc] init];
        homeVC.hasCreatSearchView = YES;
        homeVC.title = @"蜜汁直播";
        QLNavigationController *homeNav = [[QLNavigationController alloc] initWithRootViewController:homeVC];
        homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"精选"
                                                           image:[[UIImage imageNamed:@"tabbar_ choiceness_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_ choiceness_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        homeNav.tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        
        QLFollowingViewController *followVC = [[QLFollowingViewController alloc] init];
        followVC.title = @"我的关注";
        followVC.hasCreatSearchView = YES;
        QLNavigationController *followNav = [[QLNavigationController alloc] initWithRootViewController:followVC];
        followNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"关注"
                                                             image:[[UIImage imageNamed:@"tabbar_attention_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[[UIImage imageNamed:@"tabbar_attention_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        followNav.tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        
        QLLiveViewController *liveVC = [[QLLiveViewController alloc] init];
        liveVC.title = @"蜜汁直播";
        liveVC.hasCreatSearchView = YES;
//        QLNavigationController *liveNav = [[QLNavigationController alloc] initWithRootViewController:liveVC];
        liveVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                           image:[[UIImage imageNamed:@"tabbar_live_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_live_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        QLShowTimeViewController *showTimeVC = [[QLShowTimeViewController alloc] init];
        showTimeVC.title = @"秀场";
        showTimeVC.hasCreatSearchView = YES;
        QLNavigationController *showTimeNav = [[QLNavigationController alloc] initWithRootViewController:showTimeVC];
        showTimeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"秀场"
                                                               image:[[UIImage imageNamed:@"tabbar_show_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                       selectedImage:[[UIImage imageNamed:@"tabbar_show_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        showTimeNav.tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        
        QLMineViewController *mineVC = [[QLMineViewController alloc] init];
        mineVC.title = @"我的";
        QLNavigationController *mineNav = [[QLNavigationController alloc] initWithRootViewController:mineVC];
        mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                           image:[[UIImage imageNamed:@"tabbar_mine_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        mineNav.tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        
        _sharedController.viewControllers = @[homeNav,followNav,liveVC,showTimeNav,mineNav];
        
        UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateBegan) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDebugNotification object:nil];
            }
        }];
        longPressGes.minimumPressDuration = 3;
        [_sharedController.tabBar addGestureRecognizer:longPressGes];
    });
    return _sharedController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [QLRecommendedFollowingViewController showViewControllerIfNeededInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
