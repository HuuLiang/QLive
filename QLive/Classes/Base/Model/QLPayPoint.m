//
//  QLPayPoint.m
//  QLive
//
//  Created by Sean Yue on 2017/3/10.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPayPoint.h"

static NSString *const kQLPayPointsUserDefaultsKey = @"com.qlive.userdefaults.paypoints";
static QLPayPoints *_sharedPayPoints;

NSString *const kQLVIPPayPointType = @"VIP";
NSString *const kQLChargePayPointType = @"DEPOSIT";
NSString *const kQLAnchorPayPointType = @"ANCHOR";

NSString *const kQLAnchorPayPointName_PrivateCast = @"SIBO"; //私播
NSString *const kQLAnchorPayPointName_LightThisCast = @"BCDL_A"; //本场点亮
NSString *const kQLAnchorPayPointName_LightMonthlyCast = @"BYDL_B"; //包月点亮
NSString *const kQLAnchorPayPointName_PrivateShow = @"SIXIU"; //私秀
NSString *const kQLAnchorPayPointName_JumpQueue = @"CHADUI"; //插队
NSString *const kQLAnchorPayPointName_BookThisTicket = @"SC_A"; //本场观看，上车
NSString *const kQLAnchorPayPointName_BookMonthlyTicket = @"SC_B"; //包月观看，上车

@implementation QLPayPoint

@end

@implementation QLPayPoints

SynthesizeContainerPropertyElementClassMethod(VIP, QLPayPoint)
SynthesizeContainerPropertyElementClassMethod(DEPOSIT, QLPayPoint)
SynthesizeContainerPropertyElementClassMethod(ANCHOR, QLPayPoint)

+ (instancetype)sharedPayPoints {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kQLPayPointsUserDefaultsKey];
        _sharedPayPoints = [self objectFromDictionary:dic];
    });
    return _sharedPayPoints;
}

- (void)save {
    _sharedPayPoints = self;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.dictionaryRepresentation forKey:kQLPayPointsUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation QLPayPointsResponse

SynthesizePropertyClassMethod(points, QLPayPoints)

@end
