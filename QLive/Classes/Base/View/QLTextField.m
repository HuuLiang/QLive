//
//  QLTextField.m
//  QLive
//
//  Created by Sean Yue on 2017/3/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLTextField.h"

@implementation QLTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    return CGRectInset(textRect, 5, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    return CGRectInset(placeholderRect, 5, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editingRect = [super editingRectForBounds:bounds];
    return CGRectInset(editingRect, 5, 0);
}
@end
