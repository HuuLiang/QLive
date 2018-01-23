//
//  QLMineZoneViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineZoneViewController.h"

@interface QLMineZoneViewController ()
{
    UILabel *_titleLabel;
    UIButton *_publishButton;
}
@end

@implementation QLMineZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的动态";
    
    _publishButton = [[UIButton alloc] init];
    _publishButton.layer.cornerRadius = 22;
    _publishButton.layer.borderColor = [UIColor colorWithHexString:@"#f22376"].CGColor;
    _publishButton.layer.borderWidth = 0.5;
    [_publishButton setTitleColor:[UIColor colorWithHexString:@"#f22376"] forState:UIControlStateNormal];
    [_publishButton setTitle:@"发布动态" forState:UIControlStateNormal];
    [_publishButton addTarget:self action:@selector(onPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishButton];
    {
        [_publishButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(44);
            make.width.equalTo(self.view).multipliedBy(0.4);
        }];
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    _titleLabel.font = kMediumFont;
    _titleLabel.text = @"你还没有最新动态，去发布一个吧";
    [self.view addSubview:_titleLabel];
    {
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(_publishButton.mas_top).offset(-15);
        }];
    }
}

- (void)onPublish {
    [[QLAlertManager sharedManager] alertWithTitle:@"等级不够" message:@"你当前等级太低，请提升等级！"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
