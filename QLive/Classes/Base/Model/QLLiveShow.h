//
//  QLLiveShow.h
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLHttpResponse.h"

@class QLLiveShowTicketInfo;

@interface QLLiveShow : DBPersistence

@property (nonatomic) NSString *liveId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *logoUrl;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *anchorUrl;
@property (nonatomic) NSString *anchorType;
@property (nonatomic) NSNumber *ticketCounts;
@property (nonatomic) NSString *anchorUrl2;
@property (nonatomic) NSString *qqNum;
@property (nonatomic) NSString *weiXinNum;
@property (nonatomic,retain) NSArray<QLLiveShowTicketInfo *> *ticketInfos;

@property (nonatomic) NSNumber *lastCastSeconds;
@property (nonatomic) NSNumber *hasReadPrivateInfos;

+ (void)mapLiveShows:(NSArray<QLLiveShow *> *)liveShows withTicketInfos:(NSArray<QLLiveShowTicketInfo *> *)ticketInfos;
- (QLLiveShowTicketInfo *)ticketInfoAtSecond:(u_int64_t)second;

@end

@interface QLLiveShowTicketInfo : DBPersistence

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSNumber *ownerId;
@property (nonatomic) NSNumber *fee;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *popTime;

@end

@interface QLLiveShowResponse : QLHttpResponse

@property (nonatomic,retain) NSArray<QLLiveShow *> *shows;

@end

extern NSString *const kQLLiveShowAnchorTypePublic;  //即将开车
extern NSString *const kQLLiveShowAnchorTypePrivate; //私播
extern NSString *const kQLLiveShowAnchorTypeBigShow; //大秀

extern const NSInteger kQLLiveShowNumberOfTickers;
