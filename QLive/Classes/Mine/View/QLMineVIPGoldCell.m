//
//  QLMineVIPGoldCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/11.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineVIPGoldCell.h"

@interface QLMineVIPGoldCell ()
{
    UILabel *_titleLabel;
    UILabel *_goldLabel;
}
@end

@implementation QLMineVIPGoldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        _titleLabel.text = @"持有金币";
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self).dividedBy(3);
            }];
        }
        
        _goldLabel = [[UILabel alloc] init];
        _goldLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _goldLabel.font = kExExHugeBoldFont;
        _goldLabel.text = @"0";
        [self addSubview:_goldLabel];
        {
            [_goldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_titleLabel.mas_bottom).offset(15);
            }];
        }
    }
    return self;
}

- (void)setGoldCount:(NSUInteger)goldCount {
    _goldCount = goldCount;
    _goldLabel.text = @(goldCount).stringValue;
}

@end
