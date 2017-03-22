//
//  QLPaymentActionSheetButton.m
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPaymentActionSheetButton.h"

@interface QLPaymentActionSheetButton ()
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}
@end

@implementation QLPaymentActionSheetButton

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
    self = [super init];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = title;
        _titleLabel.font = kBigFont;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                if (subtitle.length > 0) {
                    make.bottom.equalTo(self.mas_centerY);
                } else {
                    make.centerY.equalTo(self);
                }
            }];
        }
        
        _iconImageView = [[UIImageView alloc] initWithImage:image];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconImageView];
        {
            [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleLabel);
                make.right.equalTo(_titleLabel.mas_left).offset(-10);
                make.size.mas_equalTo(CGSizeMake(_titleLabel.font.pointSize * 1.25,_titleLabel.font.pointSize*1.25));
            }];
        }
        
        if (subtitle.length > 0) {
            _subtitleLabel = [[UILabel alloc] init];
            _subtitleLabel.text = subtitle;
            _subtitleLabel.font = kMediumFont;
            _subtitleLabel.textColor = [UIColor colorWithHexString:@"#999999"];
            [self addSubview:_subtitleLabel];
            {
                [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_titleLabel.mas_bottom).offset(5);
                    make.centerX.equalTo(self);
                }];
            }
        }
    }
    return self;
}

@end
