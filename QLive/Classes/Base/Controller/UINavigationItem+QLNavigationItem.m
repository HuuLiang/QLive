//
//  UINavigationItem+QLNavigationItem.m
//  QLive
//
//  Created by Sean Yue on 2017/3/1.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "UINavigationItem+QLNavigationItem.h"

static const void *kNavigationBarHiddenAssociatedKey = &kNavigationBarHiddenAssociatedKey;

@implementation UINavigationItem (QLNavigationItem)

- (BOOL)navigationBarHidden {
    NSNumber *value = objc_getAssociatedObject(self, kNavigationBarHiddenAssociatedKey);
    return value.boolValue;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    objc_setAssociatedObject(self, kNavigationBarHiddenAssociatedKey, @(navigationBarHidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
