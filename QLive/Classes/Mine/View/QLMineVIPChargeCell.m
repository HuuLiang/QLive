//
//  QLMineVIPChargeCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/12.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineVIPChargeCell.h"

@interface QLMineVIPChargeCell ()
{
    UILabel *_titleLabel;
    UIButton *_chargeButton;
    UIView *_separator;
}
@end

@implementation QLMineVIPChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(20);
            }];
        }
        
        _chargeButton = [[UIButton alloc] init];
        _chargeButton.forceRoundCorner = YES;
        _chargeButton.titleLabel.font = kMediumFont;
        _chargeButton.userInteractionEnabled = NO;
        [_chargeButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [_chargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [_chargeButton setBackgroundImage:[UIImage imageWithColor:[QLTheme defaultTheme].themeColor] forState:UIControlStateNormal];
        [self addSubview:_chargeButton];
        {
            [_chargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self).offset(-15);
                make.size.mas_equalTo(CGSizeMake(80, 36));
            }];
        }
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithHexString:@"#999999"];
        [self addSubview:_separator];
        {
            [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.right.equalTo(_chargeButton);
                make.bottom.equalTo(self);
                make.height.mas_equalTo(0.5);
            }];
        }
    }
    return self;
}

- (void)setAmount:(CGFloat)amount withGoldCount:(NSUInteger)goldCount bonusGoldCount:(NSUInteger)bonusGoldCount {
    NSString *goldString = [NSString stringWithFormat:@"%ld", (unsigned long)goldCount];
    NSString *amountString = QLIntegralPrice(amount);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@金币送%ld金币=%@元", goldString, (unsigned long)bonusGoldCount, amountString]];
    [attrString addAttribute:NSFontAttributeName value:kBigBoldFont range:NSMakeRange(0, goldString.length)];
    [attrString addAttribute:NSFontAttributeName value:kBigBoldFont range:NSMakeRange(attrString.length - amountString.length - 1, amountString.length)];
    
    _titleLabel.attributedText = attrString;
}
@end
