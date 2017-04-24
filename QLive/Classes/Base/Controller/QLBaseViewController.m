//
//  QLBaseViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"
#import "QLLiveCastViewController.h"
#import "QLRecentMessageViewController.h"
#import "QLSearchViewController.h"

@interface QLBaseViewController ()

@end

@implementation QLBaseViewController

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    if (self.hasCreatSearchView) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navbaritem_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onSearch)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navbaritem_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onChat)];
    }
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return self.navigationController.viewControllers.firstObject != self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)startLiveCastWithAnchor:(QLAnchor *)anchor {
    QLLiveCastViewController *playerVC = [[QLLiveCastViewController alloc] initWithAnchor:anchor];
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSearch {
    QLSearchViewController *searchVC = [[QLSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:NO];
}

- (void)onChat {
    QLRecentMessageViewController *messageVC = [[QLRecentMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

@end
