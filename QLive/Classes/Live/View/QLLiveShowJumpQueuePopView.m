//
//  QLLiveShowJumpQueuePopView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveShowJumpQueuePopView.h"

@interface QLLiveShowJumpQueuePopView ()
{
    UIView *_contentView;
    UIImageView *_avatarImageView;
    UILabel *_nameLabel;
    UIButton *_jumpButton;
}
@end

@implementation QLLiveShowJumpQueuePopView

+ (instancetype)popInView:(UIView *)view withLiveShow:(QLLiveShow *)liveShow jumpQueueAction:(QBAction)jumpQueueAction {
    QLLiveShowJumpQueuePopView *selfView = [[self alloc] init];
    selfView.liveShow = liveShow;
    selfView.jumpQueueAction = jumpQueueAction;
    [selfView showInView:view];
    return selfView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(self).multipliedBy(0.75);
                make.height.mas_equalTo(150);
            }];
        }
        
        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setImage:[UIImage imageNamed:@"yellow_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        {
            [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentView.mas_right).offset(-5);
                make.centerY.equalTo(_contentView.mas_top).offset(5);
                make.size.mas_equalTo(CGSizeMake(35, 35));
            }];
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = kExtraBigFont;
        titleLabel.textColor = [UIColor redColor];
        titleLabel.text = @"对不起，该直播间锁定中";
        [_contentView addSubview:titleLabel];
        {
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentView);
                make.top.equalTo(_contentView).offset(30);
            }];
        }
        
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.forceRoundCorner = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_contentView addSubview:_avatarImageView];
        {
            [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_contentView).offset(15);
                make.bottom.equalTo(_contentView).offset(-15);
                make.size.mas_equalTo(CGSizeMake(60, 60));
            }];
        }
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = kBigFont;
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        [_contentView addSubview:_nameLabel];
        {
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_avatarImageView.mas_right).offset(10);
                make.centerY.equalTo(_avatarImageView);
            }];
        }
        
        _jumpButton = [[UIButton alloc] init];
        _jumpButton.layer.cornerRadius = 10;
        _jumpButton.layer.masksToBounds = YES;
        _jumpButton.layer.borderWidth = 0.5;
        _jumpButton.layer.borderColor = [UIColor colorWithHexString:@"#89d0ec"].CGColor;
        [_jumpButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_jumpButton setTitle:@"插队观看" forState:UIControlStateNormal];
        [_jumpButton setTitleColor:[UIColor colorWithHexString:@"#89d0ec"] forState:UIControlStateNormal];
        [_jumpButton addTarget:self action:@selector(onJumpQueue) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_jumpButton];
        {
            [_jumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_contentView).offset(-10);
                make.centerY.equalTo(_avatarImageView);
                make.width.mas_equalTo(88);
                make.height.mas_equalTo(44);
            }];
        }
    }
    return self;
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (void)setLiveShow:(QLLiveShow *)liveShow {
    _liveShow = liveShow;
    
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:liveShow.logoUrl] placeholderImage:[UIImage imageNamed:@"mine_avatar"]];
    _nameLabel.text = liveShow.name;
    
}

- (void)onJumpQueue {
    [self hide];
    QBSafelyCallBlock(self.jumpQueueAction, self);
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    self.frame = view.bounds;
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

- (void)hide {
    if (self.superview) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

@end
