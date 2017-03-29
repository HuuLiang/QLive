//
//  QLChannelNo.m
//  QLive
//
//  Created by Sean Yue on 2017/3/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLChannelNo.h"

@implementation QLChannelNo

+ (instancetype)defaultChannelNo {
    static QLChannelNo *_defaultChannelNo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultChannelNo = [self channelNoWithFile:@"ChannelNo"];
    });
    return _defaultChannelNo;
}

+ (instancetype)channelNoWithFile:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *channelDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    QLChannelNo *channelNo = [[self alloc] initWithChannelNo:channelDic[@"ChannelNo"]];
    return channelNo;
}

- (instancetype)initWithChannelNo:(NSString *)channelNo {
    self = [super init];
    if (self) {
        _channelNo = channelNo;
    }
    return self;
}
@end
