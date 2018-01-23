//
//  QLAnchorNormalCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLAnchorNormalCell.h"

@interface QLAnchorNormalCell ()
{
    UIImageView *_thumbImageView;
    UIImageView *_avatarImageView;
    UIImageView *_locIconImageView;
    UIImageView *_liveIconImageView;
    UILabel *_titleLabel;
    UILabel *_cityLabel;
    UILabel *_audienceLabel;
}
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *city;
@property (nonatomic) NSURL *avatarURL;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSUInteger numberOfAudience;
@end

@implementation QLAnchorNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self);
                make.height.equalTo(_thumbImageView.mas_width);
            }];
        }
        
        _liveIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_icon"]];
        [self addSubview:_liveIconImageView];
        {
            [_liveIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_thumbImageView).offset(15);
                make.right.equalTo(_thumbImageView).offset(-15);
                make.size.mas_equalTo(CGSizeMake(62, 24));
            }];
        }
        
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.forceRoundCorner = YES;
        [self addSubview:_avatarImageView];
        {
            [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(self).offset(10);
                make.bottom.equalTo(_thumbImageView.mas_top).offset(-10);
                make.width.equalTo(_avatarImageView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_avatarImageView.mas_right).offset(10);
                make.bottom.equalTo(_avatarImageView.mas_centerY);
            }];
        }
        
        _locIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray_location"]];
        [self addSubview:_locIconImageView];
        {
            [_locIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(5);
            }];
        }
        
        _cityLabel = [[UILabel alloc] init];
        _cityLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _cityLabel.font = kExtraSmallFont;
        [self addSubview:_cityLabel];
        {
            [_cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_locIconImageView);
                make.left.equalTo(_locIconImageView.mas_right).offset(5);
            }];
        }
        
        _audienceLabel = [[UILabel alloc] init];
        _audienceLabel.font = [UIFont systemFontOfSize:15];
        _audienceLabel.textColor = [UIColor colorWithHexString:@"#5AC8FA"];
        [self addSubview:_audienceLabel];
        {
            [_audienceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-10);
                make.centerY.equalTo(_avatarImageView);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}

- (void)setAvatarURL:(NSURL *)avatarURL {
    _avatarURL = avatarURL;
    [_avatarImageView sd_setImageWithURL:avatarURL];
}

- (void)setName:(NSString *)name {
    _name = name;
    _titleLabel.text = name;
}

- (void)setCity:(NSString *)city {
    _city = city;
    _cityLabel.text = city;
}

- (void)setNumberOfAudience:(NSUInteger)numberOfAudience {
    _numberOfAudience = numberOfAudience;
    
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld在看", (unsigned long)numberOfAudience]];
//    [attrString addAttributes:@{NSForegroundColorAttributeName:[QLTheme defaultTheme].themeColor,
//                                NSFontAttributeName:kExtraBigFont} range:NSMakeRange(0, attrString.length-2)];
//    [attrString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"],
//                                NSFontAttributeName:kSmallFont} range:NSMakeRange(attrString.length-2, 2)];
    _audienceLabel.text = [NSString stringWithFormat:@"%zd人看",numberOfAudience];
}

- (void)setAnchor:(QLAnchor *)anchor {
    _anchor = anchor;
    
    self.imageURL = [NSURL URLWithString:anchor.imgCover];
    self.avatarURL = [NSURL URLWithString:anchor.logoUrl];
    self.name = anchor.name;
    self.city = anchor.city;
    self.numberOfAudience = anchor.onlineUsers.unsignedIntegerValue;
    
    _liveIconImageView.image = [anchor.anchorType isEqualToString:kQLAnchorTypeShow] ? [UIImage imageNamed:@"live_private_icon"] : [UIImage imageNamed:@"live_icon"];
}
@end
