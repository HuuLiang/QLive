//
//  QLHttpResponse.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLHttpResponse.h"

@implementation QLHttpResponse

- (BOOL)success {
    return self.code.unsignedIntegerValue == 100;
}

@end
