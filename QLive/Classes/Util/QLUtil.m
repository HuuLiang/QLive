//
//  QLUtil.m
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLUtil.h"
#import <sys/sysctl.h>

static NSString *const kQLRegisterUserDefaultsKeyName = @"com.qlive.userdefaults.userregister";

@implementation QLUtil

+ (NSString *)currentDateTimeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDefaultDateTimeFormat];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDefaultDateTimeFormat];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kQLRegisterUserDefaultsKeyName];
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kQLRegisterUserDefaultsKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
