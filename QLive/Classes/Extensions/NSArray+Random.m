//
//  NSArray+Random.m
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (NSArray *)QL_arrayByPickingRandomCount:(NSUInteger)count {
    if (count >= self.count) {
        return self.copy;
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    
    NSMutableArray *arr = self.mutableCopy;
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger index = arc4random_uniform((uint32_t)arr.count);
        [results addObject:arr[index]];
        [arr removeObject:arr[index]];
    }
    return results;
}

@end
