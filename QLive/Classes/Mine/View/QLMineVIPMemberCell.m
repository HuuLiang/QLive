//
//  QLMineVIPMemberCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/11.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineVIPMemberCell.h"

@interface QLMineVIPMemberCell ()
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIButton *_vipButton;
}
@end

@implementation QLMineVIPMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_icon"]];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(20);
                make.height.equalTo(self).multipliedBy(0.5);
                make.width.equalTo(_iconImageView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kBigBoldFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.mas_centerY);
                make.left.equalTo(_iconImageView.mas_right).offset(15);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _subtitleLabel.font = kMediumFont;
        _subtitleLabel.text = @"享受专属免费观看权限";
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(5);
            }];
        }
        
        _vipButton = [[UIButton alloc] init];
        _vipButton.titleLabel.font = kSmallFont;
        _vipButton.forceRoundCorner = YES;
        _vipButton.userInteractionEnabled = NO;
        [_vipButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#ee7f58"]] forState:UIControlStateNormal];
        [_vipButton setTitle:@"开通会员" forState:UIControlStateNormal];
        [_vipButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [self addSubview:_vipButton];
        {
            [_vipButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self).offset(-15);
                make.size.mas_equalTo(CGSizeMake(80, 36));
            }];
        }
        
        self.amount = 0;
    }
    return self;
}

- (void)setAmount:(CGFloat)amount {
    _amount = amount;
    _titleLabel.text = [NSString stringWithFormat:@"¥%@ 开通VIP", QLIntegralPrice(amount)];
}

- (void)setIsVIP:(BOOL)isVIP {
    _isVIP = isVIP;
    _vipButton.hidden = isVIP;
    
    if (isVIP) {
        _titleLabel.text = @"您已经是VIP会员";
    } else {
        _titleLabel.text = [NSString stringWithFormat:@"¥%@ 开通VIP", QLIntegralPrice(_amount)];
    }
}
@end
