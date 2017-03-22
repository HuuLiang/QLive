//
//  QLUtil.h
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLUtil : NSObject

+ (NSString *)currentDateTimeString;
+ (NSDate *)dateFromString:(NSString *)dateString;

+ (NSString *)deviceName;
+ (NSString *)appVersion;

+ (NSString *)userId;
+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

@end
