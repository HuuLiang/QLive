//
//  QLAdInfo.h
//  QLive
//
//  Created by Sean Yue on 2017/4/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLAdInfo : NSObject

@property (nonatomic) NSString *adUrl;
@property (nonatomic) NSString *imgCover;

@end

@interface QLAdInfos : QLHttpResponse

@property (nonatomic,retain) NSArray<QLAdInfo *> *adInfos;

@end
