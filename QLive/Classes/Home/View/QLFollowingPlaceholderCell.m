//
//  QLFollowingPlaceholderCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLFollowingPlaceholderCell.h"

@interface QLFollowingPlaceholderCell ()
{
    UIImageView *_bgImageView;
    UILabel *_titleLabel;
    UIButton *_actionButton;
}
@end
@implementation QLFollowingPlaceholderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
        [self addSubview:_bgImageView];
        {
            [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_centerY);
            }];
        }
        
        _actionButton = [[UIButton alloc] init];
        _actionButton.userInteractionEnabled = NO;
        _actionButton.titleLabel.font = _titleLabel.font;
        _actionButton.layer.borderWidth = 1;
        _actionButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _actionButton.forceRoundCorner = YES;
        _actionButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [self addSubview:_actionButton];
        {
            [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_titleLabel.mas_bottom).offset(10);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [_actionButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _bgImageView.image = backgroundImage;
}
@end
