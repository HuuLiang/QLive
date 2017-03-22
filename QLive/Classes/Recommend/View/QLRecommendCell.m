//
//  QLRecommendCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLRecommendCell.h"

@interface QLRecommendCell ()
{
    UIImageView *_thumbImageView;
    UILabel *_nameLabel;
}
@property (nonatomic,retain) UIImageView *selectedImageView;
@end

@implementation QLRecommendCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.forceRoundCorner = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.height.equalTo(_thumbImageView.mas_width);
            }];
        }
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _nameLabel.font = kMediumFont;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        {
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_thumbImageView.mas_bottom).offset(5);
                make.left.right.bottom.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)setAvatarURL:(NSURL *)avatarURL {
    _avatarURL = avatarURL;
    [_thumbImageView sd_setImageWithURL:avatarURL];
}

- (void)setName:(NSString *)name {
    _name = name;
    _nameLabel.text = name;
}

- (UIImageView *)selectedImageView {
    if (_selectedImageView) {
        return _selectedImageView;
    }
    
    _selectedImageView = [[UIImageView alloc] init];
    _selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _selectedImageView.hidden = YES;
    _selectedImageView.image = [UIImage imageNamed:@"black_arrow"];
    [self addSubview:_selectedImageView];
    {
        [_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_thumbImageView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _selectedImageView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.selectedImageView.hidden = NO;
    } else {
        _selectedImageView.hidden = YES;
    }
}
@end
