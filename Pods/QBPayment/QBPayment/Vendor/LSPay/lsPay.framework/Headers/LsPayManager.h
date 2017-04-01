//
//  LsPayManager.h
//  LsPaySDK
//
//  Created by joe on 17/3/15.
//  Copyright © 2017年 leiSheng. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^handelBlock)(NSDictionary * sender);

@interface LsPayManager : NSObject

/**
 *   单例
 
 *
 */
+ (instancetype)sharedInstance;

/**
 *   商户模式
 
 *
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**
 *  viewController ---------------------    调用的视图一般为self
 *  payinfo	---------------------   微信支付传payinfo字典，由统一下单接口获取(参考商户接入文档)，支付宝支付传payinfo字符串，通过调用统一下单接口获取：参考商户接入文档
 *  type ------------------ 微信传1 支付宝传2
 *  scheme ------------------ 回调关键词  必须和info里填写的一致
 *  block ------------------ 支付结果回调:有返回支付后相关信息 code==0.支付成功
 */
-(void)lsPayWithViewController:(UIViewController *)viewController orderStr:(id )payinfo scheme:(NSString *)scheme  type:(NSString *)type block:(handelBlock)block;

/**
 *  处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
 *
 *  @param url        支付结果url
 */
-(void)processAuthResult:(NSURL *)url;

@end
