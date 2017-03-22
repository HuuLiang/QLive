//
//  QLPayPoint.h
//  QLive
//
//  Created by Sean Yue on 2017/3/10.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLPayPoint : NSObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *fee;
@property (nonatomic) NSNumber *goldCount;
@property (nonatomic) NSString *pointDesc;
@property (nonatomic) NSString *pointType;

@end

@interface QLPayPoints : NSObject

@property (nonatomic,retain) NSArray<QLPayPoint *> *VIP;
@property (nonatomic,retain) NSArray<QLPayPoint *> *DEPOSIT;
@property (nonatomic,retain) NSArray<QLPayPoint *> *ANCHOR;

+ (instancetype)sharedPayPoints;
- (void)save;

@end

@interface QLPayPointsResponse : QLHttpResponse

@property (nonatomic,retain) QLPayPoints *points;

@end

extern NSString *const kQLVIPPayPointType;
extern NSString *const kQLChargePayPointType;
extern NSString *const kQLAnchorPayPointType;

// Anchor PayPoint Names
extern NSString *const kQLAnchorPayPointName_PrivateCast; //私播
extern NSString *const kQLAnchorPayPointName_LightThisCast; //本场点亮
extern NSString *const kQLAnchorPayPointName_LightMonthlyCast; //包月点亮
extern NSString *const kQLAnchorPayPointName_PrivateShow; //私秀
extern NSString *const kQLAnchorPayPointName_JumpQueue; //插队
extern NSString *const kQLAnchorPayPointName_BookThisTicket; //本场观看，上车
extern NSString *const kQLAnchorPayPointName_BookMonthlyTicket; //包月观看，上车
