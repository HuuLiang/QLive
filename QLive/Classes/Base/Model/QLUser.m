//
//  QLUser.m
//  QLive
//
//  Created by Sean Yue on 2017/3/3.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLUser.h"

static NSString *const kUserDefaultsCurrentUserKey = @"com.qbstore.userdefaults.currentuser";
static QLUser *_currentUser = nil;

NSString *const kQLUserGenderMale = @"M";
NSString *const kQLUserGenderFemale = @"F";
NSString *const kQLAnchorTypeLive = @"LIVE";
NSString *const kQLAnchorTypeShow = @"SHOW";

NSString *const kQLCurrentUserChangedNotification = @"com.qbstore.notification.currentuserchanged";

@interface QLUser ()
@property (nonatomic) NSNumber *id;
@end

@implementation QLUser

+ (instancetype)currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCurrentUserKey];
        _currentUser = [self objectFromDictionary:dic];
        
        if (!_currentUser) {
            QLUser *defaultUser = [[QLUser alloc] init];
            defaultUser.name = @"新司机";
            defaultUser.gender = kQLUserGenderMale;
            defaultUser.userId = @(100000 + arc4random_uniform(900000)).stringValue;
            [defaultUser saveAsCurrentUser];
        }
    });
    return _currentUser;
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(userId));
}

- (void)setId:(NSNumber *)id {
    _id = id;
    _userId = id.stringValue;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    _id = @(userId.integerValue);
}

- (void)addGoldCount:(NSUInteger)goldCount {
    self.goldCount = @(self.goldCount.unsignedIntegerValue + goldCount);
}

- (NSString *)genderString {
    return [self.gender isEqualToString:kQLUserGenderMale] ? @"男" : [self.gender isEqualToString:kQLUserGenderFemale] ? @"女" : nil;
}

- (void)saveAsCurrentUser {
    [[NSUserDefaults standardUserDefaults] setObject:[self dictionaryRepresentation] forKey:kUserDefaultsCurrentUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _currentUser = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:kQLCurrentUserChangedNotification object:_currentUser];
}

- (id)copyWithZone:(NSZone *)zone {
    QLUser *user = [[QLUser alloc] init];
    user.userId = [self.userId copyWithZone:zone];
    user.logoUrl = [self.logoUrl copyWithZone:zone];
    user.name = [self.name copyWithZone:zone];
    user.city = [self.city copyWithZone:zone];
    user.gender = [self.gender copyWithZone:zone];
    user.goldCount = [self.goldCount copyWithZone:zone];
    user.isVIP = [self.isVIP copyWithZone:zone];
    
    user.imgCover = [self.imgCover copyWithZone:zone];
    user.anchorUrl = [self.anchorUrl copyWithZone:zone];
    user.anchorType = [self.anchorType copyWithZone:zone];
    user.anchorRank = [self.anchorRank copyWithZone:zone];
    user.onlineUsers = [self.onlineUsers copyWithZone:zone];
    user.anchorUrl2 = [self.anchorUrl2 copyWithZone:zone];
    user.qqNum = [self.qqNum copyWithZone:zone];
    user.weixinNum = [self.weixinNum copyWithZone:zone];
    return user;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (!((QLUser *)object).userId || !self.userId) {
        return NO;
    }
    
    return [((QLUser *)object).userId isEqual:self.userId];
}

- (NSUInteger)hash {
    return self.userId.hash;
}

//#ifdef DEBUG
//- (NSString *)logoUrl {
//    return @"http://v1.qzone.cc/avatar/201407/15/09/00/53c47d2962bce014.jpg%21200x200.jpg";
//}
//
//- (NSString *)imgCover {
//    return @"http://v1.qzone.cc/avatar/201407/15/09/00/53c47d2962bce014.jpg%21200x200.jpg";
//}
//#endif
@end
