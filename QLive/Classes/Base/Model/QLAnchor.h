//
//  QLAnchor.h
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLUser.h"
#import "QLHttpResponse.h"

@interface QLAnchor : QLUser

@property (nonatomic) NSString *followingTime;
@property (nonatomic) NSNumber *lastCastSeconds;

@property (nonatomic) NSNumber *numberOfFollowing;
@property (nonatomic) NSNumber *numberOfFollowed;
@property (nonatomic) NSNumber *numberOfRichness;
@property (nonatomic) NSNumber *numberOfCharm;

@property (nonatomic) NSNumber *hasReadPrivateInfos;
@end

@interface QLAnchorResponse : QLHttpResponse

@property (nonatomic,retain) NSArray<QLAnchor *> *anchors;

@end
