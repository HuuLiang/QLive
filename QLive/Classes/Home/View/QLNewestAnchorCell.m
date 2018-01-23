//
//  QLNewestAnchorCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLNewestAnchorCell.h"

@interface QLNewestAnchorCell ()
{
    UIImageView *_starImageView;
    //    UILabel *_typeLabel;
    UIImageView *_typeImageView;
    UIButton *_audienceButton;
    UIImageView *_thumbImageView;
}
@end

@implementation QLNewestAnchorCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _starImageView = [[UIImageView alloc] init];
        _starImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_starImageView];
        {
            [_starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(self).offset(10);
                make.size.mas_equalTo(CGSizeMake(35, 15));
            }];
        }
        
        //        _typeLabel = [[UILabel alloc] init];
        //        _typeLabel.font = kExtraSmallFont;
        //        _typeLabel.textColor = [UIColor whiteColor];
        //        _typeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        //        [self addSubview:_typeLabel];
        //        {
        //            [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //                make.right.equalTo(self).offset(-10);
        //                make.top.equalTo(_starImageView);
        //            }];
        //        }
        
        _typeImageView = [[UIImageView alloc] init];
        [self addSubview:_typeImageView];
        {
            [_typeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-10);
                make.top.equalTo(_starImageView);
                make.size.mas_equalTo(CGSizeMake(54, 20));
            }];
        }
        
        _audienceButton = [[UIButton alloc] init];
        _audienceButton.titleLabel.font = kExtraSmallFont;
        _audienceButton.userInteractionEnabled = NO;
        _audienceButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [_audienceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_audienceButton setTitle:@"0" forState:UIControlStateNormal];
        
        UIImage *image = [UIImage imageNamed:@"live_online"];
        [_audienceButton setImage:image forState:UIControlStateNormal];
        [self addSubview:_audienceButton];
        {
            [_audienceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.mas_equalTo(self);
//                make.size.mas_equalTo();
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}

- (void)setStar:(NSUInteger)star {
    _star = star;
    _starImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rank_%ld", MIN(17, star)]];
}

- (void)setTypeString:(NSString *)typeString {
    _typeString = typeString;
//    _typeLabel.text = typeString;
    _typeImageView.image = [UIImage imageNamed:typeString];
}

//- (void)setTypeStringColor:(UIColor *)typeStringColor {
//    _typeStringColor = typeStringColor;
//    _typeLabel.textColor = typeStringColor;
//}

- (void)setNumberOfAudience:(NSUInteger)numberOfAudience {
    _numberOfAudience = numberOfAudience;
    [_audienceButton setTitle:[NSString stringWithFormat:@"%ld人在看", (unsigned long)numberOfAudience] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_audienceButton) {  
        CGRect audienceRect = _audienceButton.frame;
        _audienceButton.frame = CGRectMake(audienceRect.origin.x, audienceRect.origin.y, audienceRect.size.width + 8, audienceRect.size.height);
    }
}

@end
