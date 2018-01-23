//
//  QLHttpClient.h
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QLHttpMethodType) {
    QLHttpMethodUnknown,
    QLHttpMethodGET,
    QLHttpMethodPOST
};

@interface QLHttpClient : NSObject

QBDeclareSingletonMethod(sharedClient)
- (instancetype)initWithBaseURL:(NSURL *)baseURL;

- (void)requestURL:(NSString *)urlPath
        withParams:(id)params
        methodType:(QLHttpMethodType)methodtype
 completionHandler:(QLCompletionHandler)completionHandler;

@end

extern NSString *const kQLHttpClientArgErrorDomain;
