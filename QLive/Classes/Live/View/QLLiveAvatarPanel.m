//
//  QLLiveAvatarPanel.m
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveAvatarPanel.h"

@interface QLLiveAvatarPanel ()
{
    UIImageView *_avatarImageView;
    UIImageView *_tagImageView;
    
    UILabel *_nameLabel;
    UIImageView *_starImageView;
    UILabel *_detailLabel;
    
    UILabel *_followingLabel;
    UILabel *_followedLabel;
    UILabel *_richnessLabel;
    UILabel *_charmLabel;
    
    UIButton *_followButton;
}
@property (nonatomic,retain) UITapGestureRecognizer *autoHideGestureRecognizer;
@end

@implementation QLLiveAvatarPanel

+ (instancetype)showPanelInView:(UIView *)view withAnchor:(QLAnchor *)anchor buttonAction:(QBAction)buttonAction {
    QLLiveAvatarPanel *panel = [[self alloc] init];
    panel.anchor = anchor;
    panel.buttonAction = buttonAction;
    [panel showInView:view];
    return panel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];

        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.forceRoundCorner = YES;
        [self addSubview:_avatarImageView];
        {
            [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(15);
                make.size.mas_equalTo(CGSizeMake(75, 75));
            }];
        }
        
        _tagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_avatar_tag"]];
        [self addSubview:_tagImageView];
        {
            [_tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.right.equalTo(_avatarImageView);
            }];
        }
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = kMediumFont;
        [self addSubview:_nameLabel];
        {
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).offset(-21);
                make.top.equalTo(_avatarImageView.mas_bottom).offset(10);
            }];
        }
        
        _starImageView = [[UIImageView alloc] init];
        [self addSubview:_starImageView];
        {
            [_starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nameLabel);
                make.left.equalTo(_nameLabel.mas_right).offset(5);
            }];
        }
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.font = kSmallFont;
        [self addSubview:_detailLabel];
        {
            [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_nameLabel.mas_bottom).offset(5);
            }];
        }
        
        _followingLabel = [[UILabel alloc] init];
        _followingLabel.textColor = [UIColor whiteColor];
        _followingLabel.font = kMediumFont;
        [self addSubview:_followingLabel];
        {
            [_followingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).dividedBy(2);
                make.top.equalTo(_detailLabel.mas_bottom).offset(15);
            }];
        }
        
        _followedLabel = [[UILabel alloc] init];
        _followedLabel.textColor = _followingLabel.textColor;
        _followedLabel.font = _followingLabel.font;
        [self addSubview:_followedLabel];
        {
            [_followedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_followingLabel);
                make.top.equalTo(_followingLabel.mas_bottom).offset(10);
            }];
        }
        
        _richnessLabel = [[UILabel alloc] init];
        _richnessLabel.textColor = _followingLabel.textColor;
        _richnessLabel.font = _followingLabel.font;
        [self addSubview:_richnessLabel];
        {
            [_richnessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_followingLabel);
                make.centerX.equalTo(self).multipliedBy(1.5);
            }];
        }
        
        _charmLabel = [[UILabel alloc] init];
        _charmLabel.textColor = _followingLabel.textColor;
        _charmLabel.font = _followingLabel.font;
        [self addSubview:_charmLabel];
        {
            [_charmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_richnessLabel);
                make.centerY.equalTo(_followedLabel);
            }];
        }
        
        _followButton = [[UIButton alloc] init];
        _followButton.layer.cornerRadius = 5;
        _followButton.layer.masksToBounds = YES;
        _followButton.titleLabel.font = kMediumFont;
        [_followButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_followButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [_followButton addTarget:self action:@selector(onFollowButton) forControlEvents:UIControlEventTouchUpInside];
        [_followButton setTitle:@"+ 关注" forState:UIControlStateNormal];
        [self addSubview:_followButton];
        {
            [_followButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.width.equalTo(self).multipliedBy(0.7);
                make.height.mas_equalTo(36);
                make.bottom.equalTo(self).offset(-15);
            }];
        }
    }
    return self;
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (void)onFollowButton {
    QBSafelyCallBlock(self.buttonAction, self);
}

- (void)setAnchor:(QLAnchor *)anchor {
    _anchor = anchor;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.anchor.logoUrl]];
    _nameLabel.text = self.anchor.name;
    _starImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rank_%ld", (unsigned long)MIN(17, self.anchor.anchorRank.unsignedIntegerValue)]];
    _detailLabel.text = [NSString stringWithFormat:@"ID:%@  %@", self.anchor.userId, self.anchor.city];
    
    _followingLabel.attributedText = [self attributedStringWithTitle:@"关注" numbers:self.anchor.numberOfFollowing.unsignedIntegerValue];
    _followedLabel.attributedText = [self attributedStringWithTitle:@"粉丝" numbers:self.anchor.numberOfFollowed.unsignedIntegerValue];
    _richnessLabel.attributedText = [self attributedStringWithTitle:@"富豪值" numbers:self.anchor.numberOfRichness.unsignedIntegerValue];
    _charmLabel.attributedText = [self attributedStringWithTitle:@"魅力值" numbers:self.anchor.numberOfCharm.unsignedIntegerValue];
    
    [_followButton setTitle:self.anchor.followingTime ? @"取消关注" : @"+ 关注" forState:UIControlStateNormal];
    [_followButton setTitleColor:self.anchor.followingTime ? [UIColor redColor] : [UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
}

- (NSAttributedString *)attributedStringWithTitle:(NSString *)title numbers:(NSUInteger)numbers {
    NSString *str = [NSString stringWithFormat:@"%@:%ld", title, (unsigned long)numbers];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    [attrString addAttribute:NSForegroundColorAttributeName value:[QLTheme defaultTheme].themeColor range:NSMakeRange(title.length+1, str.length - title.length - 1)];
    return attrString;
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    CGRect frame = CGRectMake(0, 0, view.bounds.size.width, 270);
    self.frame = CGRectOffset(frame, 0, -CGRectGetHeight(frame));
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
        self.frame = CGRectOffset(self.frame, 0, -self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
