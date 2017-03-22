//
//  QLMineVIPHeaderView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineVIPHeaderView.h"

@interface QLMineVIPHeaderView ()
{
    UIView *_lineView;
    UILabel *_titleLabel;
}
@end

@implementation QLMineVIPHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#333333"];
        [self addSubview:_lineView];
        {
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(20);
                make.right.equalTo(self).offset(-20);
                make.centerY.equalTo(self);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kMediumFont;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

@end
