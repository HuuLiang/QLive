//
//  QLUser.h
//  QLive
//
//  Created by Sean Yue on 2017/3/3.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPersistence.h"

@interface QLUser : DBPersistence <NSCopying>

@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *logoUrl;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *gender;

@property (nonatomic) NSNumber *goldCount;
@property (nonatomic) NSNumber *isVIP;

// Anchor
@property (nonatomic) NSString *imgCover;
@property (nonatomic) NSString *anchorUrl;
@property (nonatomic) NSString *anchorType;
@property (nonatomic) NSNumber *anchorRank;
@property (nonatomic) NSNumber *onlineUsers;
@property (nonatomic) NSString *anchorUrl2;
@property (nonatomic) NSString *qqNum;
@property (nonatomic) NSString *weixinNum;

+ (instancetype)currentUser;

- (void)addGoldCount:(NSUInteger)goldCount;
- (NSString *)genderString;
- (void)saveAsCurrentUser;

@end

// QLUser.gender
extern NSString *const kQLUserGenderMale;
extern NSString *const kQLUserGenderFemale;

// QLUser.anchorType
extern NSString *const kQLAnchorTypeLive;
extern NSString *const kQLAnchorTypeShow;

// User related notifications
extern NSString *const kQLCurrentUserChangedNotification;
