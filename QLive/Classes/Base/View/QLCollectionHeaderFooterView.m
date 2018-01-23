//
//  QLCollectionHeaderFooterView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLCollectionHeaderFooterView.h"

@implementation QLCollectionHeaderFooterView

- (void)setBackgroundView:(UIView *)backgroundView {
    [_backgroundView removeFromSuperview];
    
    _backgroundView = backgroundView;
    [self addSubview:_backgroundView];
    {
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}
@end
