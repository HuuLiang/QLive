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
#import "QLLiveViewController.h"
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
        _sharedController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background"];
        _sharedController.tabBar.shadowImage = [[UIImage alloc] init];
        
//        _sharedController.tabBar.barStyle = UIBarStyleBlack;
//        _sharedController.tabBar.shadowImage = [UIImage imageWithColor:[QLTheme defaultTheme].themeColor];
        
        QLHomeViewController *homeVC = [[QLHomeViewController alloc] init];
        QLNavigationController *homeNav = [[QLNavigationController alloc] initWithRootViewController:homeVC];
        homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                           image:[[UIImage imageNamed:@"tabbar_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        homeNav.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        
        QLLiveViewController *liveVC = [[QLLiveViewController alloc] init];
//        QLNavigationController *liveNav = [[QLNavigationController alloc] initWithRootViewController:liveVC];
        liveVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                           image:[[UIImage imageNamed:@"tabbar_live_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_live_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        QLMineViewController *mineVC = [[QLMineViewController alloc] init];
        QLNavigationController *mineNav = [[QLNavigationController alloc] initWithRootViewController:mineVC];
        mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                           image:[[UIImage imageNamed:@"tabbar_mine_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"tabbar_mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        mineNav.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        
        _sharedController.viewControllers = @[homeNav,liveVC,mineNav];
        
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
