//
//  QLRESTManager.h
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLRESTManager : NSObject

QBDeclareSingletonMethod(sharedManager)

- (void)request_queryAnchorsWithCompletionHandler:(QLCompletionHandler)completionHandler;
- (void)request_queryLiveShowsWithCompletionHandler:(QLCompletionHandler)completionHandler;
- (void)request_queryPayPointsWithCompletionHandler:(QLCompletionHandler)completionHandler;

@end

extern NSString *const kQLRESTErrorDomain;

extern const NSInteger kQLRESTParameterErrorCode;
extern const NSInteger kQLRESTLogicErrorCode;
extern const NSInteger kQLRESTNetworkErrorCode;
