//
//  QLMineAvatarCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/17.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineAvatarCell.h"

@interface QLMineAvatarCell ()
{
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}
@end

@implementation QLMineAvatarCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.forceRoundCorner = YES;
        [self.contentView addSubview:_thumbImageView];
        {
            [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(15);
                make.height.equalTo(self.contentView).multipliedBy(0.6);
                make.width.equalTo(_thumbImageView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        [self.contentView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_thumbImageView.mas_right).offset(10);
                make.bottom.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-15);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _subtitleLabel.font = kSmallFont;
        [self.contentView addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(5);
            }];
        }
    }
    return self;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImage = avatarImage;
    _thumbImageView.image = avatarImage;
}

- (void)setName:(NSString *)name {
    _name = name;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"昵称 %@", name]];
    [attrString addAttribute:NSFontAttributeName value:kBigBoldFont range:NSMakeRange(0, 2)];
    _titleLabel.attributedText = attrString;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    _subtitleLabel.text = [NSString stringWithFormat:@"ID:%@", userId];
}
@end
