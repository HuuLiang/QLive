//
//  QLLiveShow.m
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveShow.h"

NSString *const kQLLiveShowAnchorTypePublic = @"KAICHE";
NSString *const kQLLiveShowAnchorTypePrivate = @"CHADUI";
NSString *const kQLLiveShowAnchorTypeBigShow = @"DAXIU";
const NSInteger kQLLiveShowNumberOfTickers = 30;

@interface QLLiveShow ()
@property (nonatomic) NSNumber *id;
@end

@implementation QLLiveShow

SynthesizeContainerPropertyElementClassMethod(ticketInfos, QLLiveShowTicketInfo)

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(liveId));
}

- (void)setId:(NSNumber *)id {
    _id = id;
    _liveId = id.stringValue;
}

+ (void)mapLiveShows:(NSArray<QLLiveShow *> *)liveShows
     withTicketInfos:(NSArray<QLLiveShowTicketInfo *> *)ticketInfos {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [ticketInfos enumerateObjectsUsingBlock:^(QLLiveShowTicketInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.ownerId) {
            return ;
        }
        
        NSMutableArray<QLLiveShowTicketInfo *> *ticketInfos = dic[obj.ownerId];
        if (!ticketInfos) {
            ticketInfos = [NSMutableArray array];
            [dic setObject:ticketInfos forKey:obj.ownerId];
        }
        [ticketInfos addObject:obj];
    }];
    
    [liveShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.ticketInfos = dic[obj.id];
    }];
}

- (QLLiveShowTicketInfo *)ticketInfoAtSecond:(u_int64_t)second {
    return [self.ticketInfos bk_match:^BOOL(QLLiveShowTicketInfo *obj) {
        NSUInteger popAtSecond = obj.popTime.unsignedIntegerValue;
        
        const NSInteger range = 3; // second-range <= popAtSecond <= second+range
        if (popAtSecond >= second-range && popAtSecond <= second+range ) {
            return YES;
        }
        return NO;
    }];
}
@end

@interface QLLiveShowTicketInfo ()
@property (nonatomic) NSString *key;
@end

@implementation QLLiveShowTicketInfo

- (NSString *)key {
    return [NSString stringWithFormat:@"%@_%@", self.ownerId, self.id];
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(key));
}
@end

@implementation QLLiveShowResponse

SynthesizeContainerPropertyElementClassMethod(shows, QLLiveShow)

@end
