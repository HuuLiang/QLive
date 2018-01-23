//
//  QLLiveGiftCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveGiftCell.h"

@interface QLLiveGiftCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}
@end

@implementation QLLiveGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(5);
                make.width.equalTo(self).dividedBy(2);
                make.height.equalTo(_imageView.mas_width);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kMediumFont;
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.top.equalTo(_imageView.mas_bottom).offset(5);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.font = kSmallFont;
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#fdfc04"];
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.top.equalTo(_titleLabel.mas_bottom).offset(3);
            }];
        }
    }
    return self;
}

- (void)setGift:(QLLiveGift *)gift {
    _gift = gift;
    
    _imageView.image = gift.image;
    _titleLabel.text = gift.name;
    _subtitleLabel.text = [NSString stringWithFormat:@"%ld金币", (unsigned long)gift.cost];
}
@end
