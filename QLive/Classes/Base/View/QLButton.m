//
//  QLButton.m
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLButton.h"

@implementation QLButton

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.bounds.size.width >= self.bounds.size.height) {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (contentRect.size.width >= contentRect.size.height) {
        return [super imageRectForContentRect:contentRect];
    } else {
        return CGRectMake(0, 0, contentRect.size.width, contentRect.size.width);
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (contentRect.size.width >= contentRect.size.height) {
        return [super titleRectForContentRect:contentRect];
    } else {
        return CGRectMake(0, contentRect.size.width, contentRect.size.width, contentRect.size.height-contentRect.size.width);
    }
}
@end
