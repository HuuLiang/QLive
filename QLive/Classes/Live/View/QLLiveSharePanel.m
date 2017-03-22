//
//  QLLiveSharePanel.m
//  QLive
//
//  Created by Sean Yue on 2017/3/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveSharePanel.h"
#import "QLButton.h"

@interface QLLiveSharePanel ()
{
    UILabel *_titleLabel;
    UIView *_separator;
    QLButton *_wechatMsgButton;
    QLButton *_wechatTimelineButton;
    QLButton *_qqButton;
}
@property (nonatomic,retain) UITapGestureRecognizer *autoHideGestureRecognizer;
@end

@implementation QLLiveSharePanel

+ (instancetype)showPanelInView:(UIView *)view withShareAction:(QBAction)shareAction {
    QLLiveSharePanel *panel = [[self alloc] init];
    panel.shareAction = shareAction;
    [panel showInView:view];
    return panel;
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kBigBoldFont;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"每日分享领金币";
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(15);
            }];
        }
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor whiteColor];
        [self addSubview:_separator];
        {
            [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_titleLabel.mas_bottom).offset(15);
                make.width.equalTo(self).multipliedBy(0.75);
                make.height.mas_equalTo(1);
            }];
        }
        
        _wechatMsgButton = [[QLButton alloc] init];
        [_wechatMsgButton setImage:[UIImage imageNamed:@"live_wechat_msg_share_normal"] forState:UIControlStateNormal];
        [_wechatMsgButton setTitle:@"微信" forState:UIControlStateNormal];
        [_wechatMsgButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_wechatMsgButton];
        {
            [_wechatMsgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).multipliedBy(0.5);
                make.top.equalTo(_separator.mas_bottom).offset(15);
                make.size.mas_equalTo(CGSizeMake(66, 96));
            }];
        }
        
        _wechatTimelineButton = [[QLButton alloc] init];
        [_wechatTimelineButton setImage:[UIImage imageNamed:@"live_wechat_timeline_share_normal"] forState:UIControlStateNormal];
        [_wechatTimelineButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [_wechatTimelineButton setTitle:@"朋友圈" forState:UIControlStateNormal];
        [self addSubview:_wechatTimelineButton];
        {
            [_wechatTimelineButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_wechatMsgButton);
                make.size.equalTo(_wechatMsgButton);
            }];
        }
        
        _qqButton = [[QLButton alloc] init];
        [_qqButton setImage:[UIImage imageNamed:@"live_qq_share_normal"] forState:UIControlStateNormal];
        [_qqButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
        [_qqButton setTitle:@"QQ" forState:UIControlStateNormal];
        [self addSubview:_qqButton];
        {
            [_qqButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).multipliedBy(1.5);
                make.top.equalTo(_wechatTimelineButton);
                make.size.equalTo(_wechatTimelineButton);
            }];
        }
    }
    return self;
}

- (void)onShare {
    [self hide];
    QBSafelyCallBlock(self.shareAction, self);
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    const CGFloat width = view.bounds.size.width;
    const CGFloat height = 170;
    CGRect frame = CGRectMake(0, CGRectGetHeight(view.bounds)-height, width, height);
    self.frame = CGRectOffset(frame, 0, frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    }];
    
    self.autoHideGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [view addGestureRecognizer:self.autoHideGestureRecognizer];
}

- (void)hide {
    if (!self.superview) {
        return ;
    }
    
    [self.autoHideGestureRecognizer.view removeGestureRecognizer:self.autoHideGestureRecognizer];
    self.autoHideGestureRecognizer = nil;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
