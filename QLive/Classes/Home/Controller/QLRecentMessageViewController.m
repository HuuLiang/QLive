//
//  QLRecentMessageViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLRecentMessageViewController.h"

@interface QLRecentMessageViewController ()
{
    UIImageView *_placeholderImageView;
    UILabel *_placeholderLabel;
}
@end

@implementation QLRecentMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"最新消息";
    
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
    _placeholderLabel.font = kMediumFont;
    _placeholderLabel.text = @"你还没有最新消息";
    [self.view addSubview:_placeholderLabel];
    {
        [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    
    _placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_placeholder"]];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_placeholderImageView];
    {
        [_placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_placeholderLabel.mas_top).offset(-15);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(120, 120));
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
