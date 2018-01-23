//
//  QLMineIncomeViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineIncomeViewController.h"

@interface QLMineIncomeViewController ()
{
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UIButton *_withdrawLabel;
    
    UIView *_separator;
    UIButton *_withdrawButton;
}
@end

@implementation QLMineIncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的收益";
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    _titleLabel.font = kMediumFont;
    _titleLabel.text = @"可提现金额（元）";
    [self.view addSubview:_titleLabel];
    {
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(50);
        }];
    }
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont boldSystemFontOfSize:50];
    _priceLabel.text = @"0.0";
    [self.view addSubview:_priceLabel];
    {
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        }];
    }
    
    _separator = [[UIView alloc] init];
    _separator.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self.view addSubview:_separator];
    {
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_priceLabel.mas_bottom).offset(50);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    _withdrawButton = [[UIButton alloc] init];
    _withdrawButton.layer.cornerRadius = 5;
    _withdrawButton.layer.masksToBounds = YES;
    [_withdrawButton setBackgroundImage:[UIImage imageWithColor:[QLTheme defaultTheme].themeColor] forState:UIControlStateNormal];
    [_withdrawButton setTitle:@"提现" forState:UIControlStateNormal];
    [_withdrawButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [_withdrawButton addTarget:self action:@selector(onWithdraw) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_withdrawButton];
    {
        [_withdrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(_separator.mas_bottom).offset(15);
            make.height.mas_equalTo(44);
        }];
    }
}

- (void)onWithdraw {
    [[QLAlertManager sharedManager] alertWithTitle:@"余额不足" message:@"必须大于100元才能提现！"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
