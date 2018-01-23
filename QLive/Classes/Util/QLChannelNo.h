//
//  QLChannelNo.h
//  QLive
//
//  Created by Sean Yue on 2017/3/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLChannelNo : NSObject

@property (nonatomic,readonly) NSString *channelNo;

+ (instancetype)defaultChannelNo;

@end
