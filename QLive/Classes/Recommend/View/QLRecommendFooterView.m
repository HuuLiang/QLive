//
//  QLRecommendFooterView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLRecommendFooterView.h"

@interface QLRecommendFooterView ()
@property (nonatomic,retain,readonly) UIButton *button;
@end

@implementation QLRecommendFooterView
@synthesize button = _button;

- (UIButton *)button {
    if (_button) {
        return _button;
    }
    
    _button = [[UIButton alloc] init];
    [_button setBackgroundImage:[UIImage imageWithColor:[QLTheme defaultTheme].themeColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _button.layer.cornerRadius = 5;
    _button.layer.masksToBounds = YES;
    _button.titleLabel.font = kMediumFont;
    [self addSubview:_button];
    {
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.75);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
    }
    
    @weakify(self);
    [_button bk_addEventHandler:^(id sender) {
        @strongify(self);
        QBSafelyCallBlock(self.action, self);
    } forControlEvents:UIControlEventTouchUpInside];
    return _button;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.button setTitle:title forState:UIControlStateNormal];
}

@end
