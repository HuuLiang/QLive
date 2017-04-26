//
//  QLLiveShowView.m
//  QLive
//
//  Created by ylz on 2017/4/24.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveShowView.h"
#import "QLButton.h"

@interface QLLiveShowView ()

{
    UIButton *_closeButton;
    UILabel *_shareTitleLabel;
    QLButton *_wxTimelineShareButton;
    QLButton *_wxMsgShareButton;
    QLButton *_qqShareButton;
    
    UIButton *_liveButton;
}

@end

@implementation QLLiveShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat height = MAX(213, kScreenHeight*0.37);
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self addSubview:backView];
        {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(self);
                make.height.mas_equalTo(height);
            }];
        }
        UIView *topView = [[UIView alloc] init];
        topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];//;[UIColor clearColor];
        topView.userInteractionEnabled = NO;
        [self addSubview:topView];
        {
            [topView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.mas_equalTo(self);
                make.bottom.mas_equalTo(backView.mas_top);
            }];
        }
        _closeButton = [[UIButton alloc] init];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:_closeButton];
        {
            [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(backView).offset(-17);
                make.centerX.equalTo(backView);
                make.size.mas_equalTo(CGSizeMake(35, 35));
            }];
        }
        
        _liveButton = [[UIButton alloc] init];
        _liveButton.layer.cornerRadius = 22;
        _liveButton.layer.masksToBounds = YES;
        [_liveButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#5AC8FA"]] forState:UIControlStateNormal];
        [_liveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_liveButton addTarget:self action:@selector(onLive) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:_liveButton];
        {
            [_liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(backView).offset(30);
                make.left.equalTo(backView).offset(40);
                make.right.equalTo(backView).offset(-40);
                make.height.mas_equalTo(44);
            }];
        }
        _wxTimelineShareButton = [[QLButton alloc] init];
        [_wxTimelineShareButton setImage:[UIImage imageNamed:@"live_show_wechat_circle"] forState:UIControlStateNormal];
        //        [_wxTimelineShareButton setImage:[UIImage imageNamed:@"live_wechat_timeline_share_highlight"] forState:UIControlStateHighlighted];
        [_wxTimelineShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [_wxTimelineShareButton setTitle:@"朋友圈" forState:UIControlStateNormal];
        [backView addSubview:_wxTimelineShareButton];
        
        _wxMsgShareButton = [[QLButton alloc] init];
        [_wxMsgShareButton setImage:[UIImage imageNamed:@"live_show_wechat"] forState:UIControlStateNormal];
        //        [_wxMsgShareButton setImage:[UIImage imageNamed:@"live_wechat_msg_share_highlight"] forState:UIControlStateHighlighted];
        [_wxMsgShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [_wxMsgShareButton setTitle:@"微信" forState:UIControlStateNormal];
        [backView addSubview:_wxMsgShareButton];
        
        _qqShareButton = [[QLButton alloc] init];
        [_qqShareButton setImage:[UIImage imageNamed:@"live_show_qq"] forState:UIControlStateNormal];
        //        [_qqShareButton setImage:[UIImage imageNamed:@"live_qq_share_highlight"] forState:UIControlStateHighlighted];
        [_qqShareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [_qqShareButton setTitle:@"QQ" forState:UIControlStateNormal];
        [backView addSubview:_qqShareButton];
        
        const CGSize buttonSize = CGSizeMake(24, 24);
        const CGFloat interButtonSpacing = (kScreenWidth - buttonSize.width * 3) / 6;
        
        [_wxTimelineShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView);
            make.top.equalTo(_liveButton.mas_bottom).offset(13);
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
        
        _shareTitleLabel = [[UILabel alloc] init];
        _shareTitleLabel.textColor = [UIColor whiteColor];
        _shareTitleLabel.font = [UIFont systemFontOfSize:MIN(14,roundf(kScreenWidth*0.44))];
        _shareTitleLabel.text = @"邀请更多的朋友来捧场";
        [backView addSubview:_shareTitleLabel];
        {
            [_shareTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(backView);
                make.top.equalTo(_wxTimelineShareButton.mas_bottom).offset(11);
            }];
        }
        
    }
    return self;
}

- (void)onLive {
    [[QLAlertManager sharedManager] alertWithTitle:@"警告" message:@"请开启相机权限"];
}

- (void)onShare {
    //    [self hide];
    //    QBSafelyCallBlock(self.shareAction, self);
    QBSafelyCallBlock(self.action,self)
}

- (void)onClose {
    
    QBSafelyCallBlock(self.closeAction,self)
}
@end
