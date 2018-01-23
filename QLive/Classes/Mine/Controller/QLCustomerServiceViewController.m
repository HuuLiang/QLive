//
//  QLCustomerServiceViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLCustomerServiceViewController.h"

@interface QLCustomerServiceViewController ()
{
    UITextView *_contentTextView;
}
@end

@implementation QLCustomerServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"客服中心";
    
    _contentTextView = [[UITextView alloc] init];
    _contentTextView.font = kMediumFont;
    _contentTextView.textColor = [UIColor colorWithHexString:@"#333333"];
    _contentTextView.text = @"在线客服QQ：3230961134\n（工作时间：9:00-18:00）";
    _contentTextView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_contentTextView];
    {
        [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.bottom.equalTo(self.view).offset(-15);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
