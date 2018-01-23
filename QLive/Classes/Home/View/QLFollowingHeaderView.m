//
//  QLFollowingHeaderView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLFollowingHeaderView.h"

@interface QLFollowingHeaderView ()
{
    UIView *_stripView;
    UILabel *_titleLabel;
}
@end

@implementation QLFollowingHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        
        _stripView = [[UIView alloc] init];
        _stripView.backgroundColor = [UIColor colorWithHexString:@"#f786b4"];
        [self addSubview:_stripView];
        {
            [_stripView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(10);
                make.centerY.equalTo(self);
                make.height.equalTo(self).multipliedBy(0.66);
                make.width.mas_equalTo(5);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.font = kSmallFont;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_stripView.mas_right).offset(5);
                make.centerY.equalTo(self);
                make.right.equalTo(self).offset(-10);
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
