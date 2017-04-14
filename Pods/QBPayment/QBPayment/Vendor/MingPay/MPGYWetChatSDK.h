//
//  MPGYWetChatSDK.h
//  MPGYWetChatSDK
//
//  Created by mpgy on 2017/2/21.
//  Copyright © 2017年 com.mpgy.www. All rights reserved.
//

#import <Foundation/Foundation.h>
//宏定义成功block 回调成功后得到的信息
typedef void (^HttpSuccess)(id data);
//宏定义失败block 回调失败信息
typedef void (^HttpFailure)(NSError *error);
@interface MPGYWetChatSDK : NSObject
//请求微信的appid
+(void)  success:(HttpSuccess)success failure:(HttpFailure)failure;
//post请求支付需要的token_id
+(void) parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure;
//解析数据中存在HTML标签过滤掉
+(NSDictionary *)filterdata:(NSData *)data;
//传入渠道号自动生成订单号
+ (NSString *)channelNumber:(NSString *)channel;
@end
