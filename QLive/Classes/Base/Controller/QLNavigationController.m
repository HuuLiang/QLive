//
//  QLNavigationController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLNavigationController.h"
#import "UINavigationItem+QLNavigationItem.h"
#import "QLMineViewController.h"

@interface QLNavigationController () <UINavigationControllerDelegate>

@end

@implementation QLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
//    self.navigationBar.barTintColor = [QLTheme defaultTheme].themeColor;
//    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage imageNamed:@"navbar_line"];//[[UIImage alloc] init];
//    self.navigationBar.layer.borderColor = [UIColor colorWithHexString:@"#e6e6e6"].CGColor;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"],
                                               NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    self.delegate = self;

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.visibleViewController.preferredStatusBarStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    BOOL navigationBarHidden = viewController.navigationItem.navigationBarHidden;
    [self setNavigationBarHidden:navigationBarHidden animated:YES];
}
@end
