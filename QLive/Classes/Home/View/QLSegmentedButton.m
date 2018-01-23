//
//  QLSegmentedButton.m
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLSegmentedButton.h"

#define kBtnBigFont  [UIFont systemFontOfSize:MIN(15,roundf(kScreenWidth*0.047))]
#define kBtnExtraBigBoldFont [UIFont boldSystemFontOfSize:MIN(16,roundf(kScreenWidth*0.05))]


static const CGFloat kImageSize = 15;

@implementation QLSegmentedButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];//[UIColor colorWithWhite:1 alpha:0.84]
        [self setTitleColor:[UIColor colorWithHexString:@"#5AC8FA"] forState:UIControlStateSelected];
        self.titleLabel.font = kBtnBigFont;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.titleLabel.font = selected ? kBtnExtraBigBoldFont : kBtnBigFont;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [self titleRectForContentRect:contentRect];
    return CGRectMake(CGRectGetMaxX(titleRect), titleRect.origin.y - imageRect.size.height/4, imageRect.size.width, imageRect.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (![self imageForState:self.state]) {
        return titleRect;
    } else {
        return CGRectOffset(titleRect, -kImageSize/2, 0);
    }
}
@end
