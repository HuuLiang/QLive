//
//  QLBaseViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"
#import "QLLiveCastViewController.h"

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
}

- (BOOL)hidesBottomBarWhenPushed {
    return self.navigationController.viewControllers.firstObject != self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)startLiveCastWithAnchor:(QLAnchor *)anchor {
    QLLiveCastViewController *playerVC = [[QLLiveCastViewController alloc] initWithAnchor:anchor];
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
