//
//  QLCommonFunctions.h
//  QLive
//
//  Created by Sean Yue on 2017/3/12.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#ifndef QLCommonFunctions_h
#define QLCommonFunctions_h

FOUNDATION_STATIC_INLINE NSString * QLIntegralPrice(const CGFloat price) {
    if ((unsigned long)(price * 100.) % 100==0) {
        return [NSString stringWithFormat:@"%ld", (unsigned long)price];
    } else {
        return [NSString stringWithFormat:@"%.2f", price];
    }
}

#endif /* QLCommonFunctions_h */
