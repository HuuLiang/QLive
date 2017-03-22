//
//  ZWXPayModel.h
//  WZXSDKDemo
//
//  Created by ZJ on 16/12/9.
//  Copyright © 2016年 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWXPayModel : NSObject
/** 需 传进来的参数 */

/** 新用户注册时自动生成，商户id */
@property (nonatomic ,copy)NSString *channelId;

/** 新用户注册完成后 自己添加应用，应用id */
@property (nonatomic ,copy)NSString *appId;

/** 应用名称 */
@property (nonatomic ,copy)NSString *appName;

/** plist文件中的BundleIdentifier 名称 */
@property (nonatomic ,copy)NSString *packageName;

/** 应用版本 */
@property (nonatomic ,copy)NSString *appVersion;

/** 计费点对应的金额，单位：分 */
@property (nonatomic ,copy)NSString *money;

/** 应用计费点名称 */
@property (nonatomic ,copy)NSString *pricePointName;

/** 应用计费点对应的描述 请注意“仅需X.XX元” 不要用真实价格数据来代替 */
@property (nonatomic ,copy)NSString *pricePointDec;

/** 渠道号，由商户在后台选择 */
@property (nonatomic ,copy)NSString *qd;


//计费点名称 商品名称  用户自传
@property (nonatomic ,copy)NSString *appFeeName;

//签名
@property (nonatomic ,copy)NSString *sign;

/** 可选 传进来的参数 */


/** 最大长度60，不支持jason对象toString */
@property (nonatomic ,copy)NSString *cpParam;

/**    商户需要传入参数       */

//时间戳 格式为:"yyyyMMddHHmmss"
@property (nonatomic ,copy)NSString *times;

/** 新用户注册时自动生成，MD5私钥 */
@property (nonatomic ,copy)NSString *key;


@end
