//
//  QLLiveViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveViewController.h"
#import "QLButton.h"

@interface QLLiveViewController () <UITextFieldDelegate>
{
    UIButton *_closeButton;
    UITextField *_titleTextField;
    UIView *_titleUnderlineView;
    UILabel *_shareTitleLabel;
    UIView *_shareSeparator;
    
    QLButton *_wxTimelineShareButton;
    QLButton *_wxMsgShareButton;
    QLButton *_qqShareButton;
    
    UIButton *_liveButton;
}
@end

@implementation QLLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#494b4a"];
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(30);
            make.right.equalTo(self.view).offset(-15);
        }];
    }
    
    
    _titleTextField = [[UITextField alloc] init];
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"^.^想要直播些什么..." attributes:@{NSFontAttributeName:kHugeFont,
                                                                                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _titleTextField.textColor = [UIColor whiteColor];
    _titleTextField.font = kHugeFont;
    _titleTextField.delegate = self;
    [self.view addSubview:_titleTextField];
    {
        [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view).multipliedBy(0.5);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.mas_equalTo(44);
        }];
    }
    
    _titleUnderlineView = [[UIView alloc] init];
    _titleUnderlineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_titleUnderlineView];
    {
        [_titleUnderlineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_titleTextField);
            make.top.equalTo(_titleTextField.mas_bottom);
            make.height.mas_equalTo(1);
        }];
    }
    
    _shareTitleLabel = [[UILabel alloc] init];
    _shareTitleLabel.textColor = [UIColor whiteColor];
    _shareTitleLabel.font = kBigFont;
    _shareTitleLabel.text = @"邀请朋友捧场";
    [self.view addSubview:_shareTitleLabel];
    {
        [_shareTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_titleUnderlineView.mas_bottom).offset((NSInteger)(kScreenHeight *0.075));
        }];
    }
    
    _shareSeparator = [[UIView alloc] init];
    _shareSeparator.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_shareSeparator];
    {
        [_shareSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_shareTitleLabel.mas_bottom).offset(10);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(1);
            make.width.equalTo(self.view).multipliedBy(0.6);
        }];
    }
    
    _wxTimelineShareButton = [[QLButton alloc] init];
    [_wxTimelineShareButton setImage:[UIImage imageNamed:@"live_wechat_timeline_share_normal"] forState:UIControlStateNormal];
    [_wxTimelineShareButton setImage:[UIImage imageNamed:@"live_wechat_timeline_share_highlight"] forState:UIControlStateHighlighted];
    [_wxTimelineShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
    [_wxTimelineShareButton setTitle:@"朋友圈" forState:UIControlStateNormal];
    [self.view addSubview:_wxTimelineShareButton];
    
    _wxMsgShareButton = [[QLButton alloc] init];
    [_wxMsgShareButton setImage:[UIImage imageNamed:@"live_wechat_msg_share_normal"] forState:UIControlStateNormal];
    [_wxMsgShareButton setImage:[UIImage imageNamed:@"live_wechat_msg_share_highlight"] forState:UIControlStateHighlighted];
    [_wxMsgShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
    [_wxMsgShareButton setTitle:@"微信" forState:UIControlStateNormal];
    [self.view addSubview:_wxMsgShareButton];
    
    _qqShareButton = [[QLButton alloc] init];
    [_qqShareButton setImage:[UIImage imageNamed:@"live_qq_share_normal"] forState:UIControlStateNormal];
    [_qqShareButton setImage:[UIImage imageNamed:@"live_qq_share_highlight"] forState:UIControlStateHighlighted];
    [_qqShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
    [_qqShareButton setTitle:@"QQ" forState:UIControlStateNormal];
    [self.view addSubview:_qqShareButton];
    
    const CGSize buttonSize = CGSizeMake(66, 96);
    const CGFloat interButtonSpacing = (kScreenWidth - buttonSize.width * 3) / 4;
    
    [_wxTimelineShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_shareSeparator.mas_bottom).offset(10);
        make.size.mas_equalTo(buttonSize);
    }];
    
    [_wxMsgShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_wxTimelineShareButton);
        make.top.equalTo(_wxTimelineShareButton);
        make.right.equalTo(_wxTimelineShareButton.mas_left).offset(-interButtonSpacing);
    }];
    
    [_qqShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_wxTimelineShareButton);
        make.top.equalTo(_wxTimelineShareButton);
        make.left.equalTo(_wxTimelineShareButton.mas_right).offset(interButtonSpacing);
    }];
    
    _liveButton = [[UIButton alloc] init];
    _liveButton.layer.cornerRadius = 22;
    _liveButton.layer.masksToBounds = YES;
    [_liveButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#ffff55"]] forState:UIControlStateNormal];
    [_liveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    [_liveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_liveButton addTarget:self action:@selector(onLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_liveButton];
    {
        [_liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_wxTimelineShareButton.mas_bottom).offset(30);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.mas_equalTo(44);
        }];
    }
    
}

- (void)onClose {
    self.tabBarController.selectedIndex = 0;
}

- (void)onShare {
    [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:2 complete:^{
        [[QLAlertManager sharedManager] alertWithTitle:@"提示" message:@"请在手机设置打开应用权限"];
    }];
}

- (void)onLive {
    [[QLAlertManager sharedManager] alertWithTitle:@"警告" message:@"请开启相机权限"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length + string.length - range.length <= 12) {
        return YES;
    }
    return NO;
}

@end
