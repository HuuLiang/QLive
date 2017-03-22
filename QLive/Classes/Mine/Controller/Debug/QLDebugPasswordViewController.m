//
//  QLDebugPasswordViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLDebugPasswordViewController.h"

@interface QLDebugPasswordViewController ()

@end

@implementation QLDebugPasswordViewController

- (instancetype)init {
    return [super initWithText:nil placeholder:@"输入调试代码" maxLength:25 didFinishAction:^BOOL(NSString *text, id obj) {
        if (text.length == 0) {
            [[QLHUDManager sharedManager] showError:@"调试代码不能为空"];
            return NO;
        }
        return YES;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"调试模式";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
