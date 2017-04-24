//
//  RMPayManager.h
//  RMPayDemo
//
//  Created by menglong on 2016/12/30.
//  Copyright © 2016年 menglong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@protocol RMPayManagerDelegate <NSObject>


/**
  支付状态查询代理

 @param state 返回状态 0 （成功）/1（失败）
 @param msg 返回消息
 */
- (void)checkOrderWithState:(NSInteger )state Msg:(NSString *)msg;

@end

@interface RMPayManager : NSObject

+ (RMPayManager *)sharedInstance;

@property (nonatomic,weak) id delegate;

/**
 设置开启或者关闭支付功能 YES（开启） 默认为NO（关闭）
 */
@property (nonatomic,assign) BOOL isPay;

/**
 *  RMPay 支付前请求
 *
 *  @param appId             融梦分配给产品的id（必填）
 *  @param partnerId         融梦分配给cp的id（必填）
 
 *  @param key               融梦分配给cp的key，用于校验订单合法性（必填）
 *  @param channelOrderId    CP订单ID(一定要32个字符以内)（必填）
 *  @param body              商品名称（必填）
 
 *  @param detail            商品详细描述（非必填）
 *  @param totalFee          商品价格，以分为单位（必填）
 *  @param attach            透传字段，支付通知里原样返回（非必填）
 *  @Controller              控制器
 *  @param notifyUrl         支付完成通知回调url（必填）
 *  @param completeBlock     返回的参数
 
 */
- (void)clickToPayAppId:(NSString *)appId
              PartnerId:(NSString *)partnerId
                    Key:(NSString *)key
         ChannelOrderId:(NSString *)channelOrderId
                   Body:(NSString *)body
                 Detail:(NSString *)detail
               TotalFee:(NSNumber *)totalFee
                 Attach:(NSString *)attach
              NotifyUrl:(NSString *)notifyUrl
             Controller:(UIViewController *)controller
                  Block:(void(^)(NSInteger state))completeBlock;

/**
 APPDelegate里面调用(注意：本版本弃用)
 */
- (void)checkOrderState;


#pragma mark - URL代理

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options;

@end
