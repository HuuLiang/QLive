//
//  QLAnchor.m
//  QLive
//
//  Created by Sean Yue on 2017/3/7.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLAnchor.h"

@implementation QLAnchor

- (id)copyWithZone:(NSZone *)zone {
    QLAnchor *anchor = [super copyWithZone:zone];
    anchor.followingTime = [self.followingTime copyWithZone:zone];
    anchor.lastCastSeconds = [self.lastCastSeconds copyWithZone:zone];
    anchor.numberOfFollowing = [self.numberOfFollowing copyWithZone:zone];
    anchor.numberOfFollowed = [self.numberOfFollowed copyWithZone:zone];
    anchor.numberOfRichness = [self.numberOfRichness copyWithZone:zone];
    anchor.numberOfCharm = [self.numberOfCharm copyWithZone:zone];
    anchor.hasReadPrivateInfos = [self.hasReadPrivateInfos copyWithZone:zone];
    return anchor;
}
@end

@implementation QLAnchorResponse

SynthesizeContainerPropertyElementClassMethod(anchors, QLAnchor)

@end
