//
//  ZWXPaySDK_1.h
//  TestDemo
//
//  Created by ZJ on 16/12/9.
//  Copyright © 2016年 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController,ZWXPayModel, ZWXPayRespObject;

typedef void(^WXzfBlock)(ZWXPayRespObject *respObject);

@interface ZWXPaySDK_1 : NSObject

//微信支付
- (void)tbatWithZWXPayModel:(ZWXPayModel *)payModel ViewController:(UIViewController *)viewController complete:(void(^)(ZWXPayRespObject *respObject))complete;

@end


@interface BlockManager : NSObject

@property (nonatomic, copy) WXzfBlock wxzfBlock;

+ (instancetype)shareManager;

@end

