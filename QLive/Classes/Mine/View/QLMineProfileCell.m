//
//  QLMineProfileCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/3.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineProfileCell.h"

@interface QLMineProfileCell ()
{
    UIImageView *_detailImageView;
}
@end

@implementation QLMineProfileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = kMediumFont;
        self.detailTextLabel.font = kSmallFont;
        self.detailTextLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        
        _detailImageView = [[UIImageView alloc] init];
        _detailImageView.forceRoundCorner = YES;
        [self.contentView addSubview:_detailImageView];
        {
            [_detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.centerY.equalTo(self.contentView);
                make.width.equalTo(_detailImageView.mas_height);
                make.height.equalTo(self.contentView).multipliedBy(0.75);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.textLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.detailTextLabel.text = subtitle;
}

- (void)setDetailImage:(UIImage *)detailImage {
    _detailImage = detailImage;
    _detailImageView.image = detailImage;
}
@end
