//
//  QLTheme.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLTheme.h"

@implementation QLTheme

+ (instancetype)defaultTheme {
    static QLTheme *_defaultTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTheme = [[self alloc] init];
        _defaultTheme.themeColor = [UIColor colorWithHexString:@"#ffffff"];
    });
    return _defaultTheme;
}
@end
