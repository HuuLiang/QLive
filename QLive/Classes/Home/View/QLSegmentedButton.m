//
//  QLSegmentedButton.m
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLSegmentedButton.h"

static const CGFloat kImageSize = 15;

@implementation QLSegmentedButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.84] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.titleLabel.font = kBigFont;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.titleLabel.font = selected ? kExtraBigBoldFont : kBigFont;
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
