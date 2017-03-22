//
//  QLRESTManager.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLRESTManager.h"
#import "QLHttpClient.h"
#import "QLHttpResponse.h"

NSString *const kQLRESTErrorDomain = @"com.qlive.errordomain.rest";
const NSInteger kQLRESTParameterErrorCode = -1;
const NSInteger kQLRESTLogicErrorCode = -998;
const NSInteger kQLRESTNetworkErrorCode = -999;

@implementation QLRESTManager

QBSynthesizeSingletonMethod(sharedManager)

- (void)request_queryAnchorsWithCompletionHandler:(QLCompletionHandler)completionHandler {
    [[QLHttpClient sharedClient] requestURL:@"/livecps/anchors.json"
                                 withParams:nil
                                 methodType:QLHttpMethodGET
                          completionHandler:^(id obj, NSError *error)
    {
        [self onResponseWithObject:obj error:error modelClass:[QLAnchorResponse class] completionHandler:completionHandler];
    }];
}

- (void)request_queryLiveShowsWithCompletionHandler:(QLCompletionHandler)completionHandler {
    [[QLHttpClient sharedClient] requestURL:@"/livecps/shows.json"
                                 withParams:nil
                                 methodType:QLHttpMethodGET
                          completionHandler:^(id obj, NSError *error)
    {
        [self onResponseWithObject:obj error:error modelClass:[QLLiveShowResponse class] completionHandler:completionHandler];
    }];
}

- (void)request_queryPayPointsWithCompletionHandler:(QLCompletionHandler)completionHandler {
    [[QLHttpClient sharedClient] requestURL:@"/livecps/payPoints.json" withParams:nil methodType:QLHttpMethodGET completionHandler:^(id obj, NSError *error) {
        [self onResponseWithObject:obj error:error modelClass:[QLPayPointsResponse class] completionHandler:completionHandler];
    }];
}

- (void)onResponseWithObject:(id)object
                       error:(NSError *)error
                  modelClass:(Class)modelClass
           completionHandler:(QLCompletionHandler)completionHandler
{
    if (!object) {
        error = [self errorFromURLError:error];
        QBSafelyCallBlock(completionHandler, object, error);
    } else {
        NSAssert([modelClass isSubclassOfClass:[QLHttpResponse class]], @"The response class you specified is NOT kind of QLHttpResponse class!");
        QLHttpResponse *instance = [modelClass objectFromDictionary:object];
        if (![instance success]) {
            NSString *errorMessage = [NSString stringWithFormat:@"网络数据返回错误(错误码：%@)", [instance code]];
            error = [NSError errorWithDomain:kQLRESTErrorDomain code:kQLRESTLogicErrorCode errorMessage:errorMessage logicCode:[instance code].integerValue];
            QBSafelyCallBlock(completionHandler, nil, error);
        } else {
            QBSafelyCallBlock(completionHandler, instance, nil);
        }
    }
}

- (NSError *)errorFromURLError:(NSError *)error {
    
    NSDictionary *errorMessages = @{@(NSURLErrorBadURL):@"地址错误",
                                    @(NSURLErrorTimedOut):@"请求超时",
                                    @(NSURLErrorUnsupportedURL):@"不支持的网络地址",
                                    @(NSURLErrorCannotFindHost):@"找不到目标服务器",
                                    @(NSURLErrorCannotConnectToHost):@"无法连接到服务器",
                                    @(NSURLErrorDataLengthExceedsMaximum):@"请求数据长度超出限制",
                                    @(NSURLErrorNetworkConnectionLost):@"网络连接断开",
                                    @(NSURLErrorDNSLookupFailed):@"DNS查找失败",
                                    @(NSURLErrorHTTPTooManyRedirects):@"HTTP重定向太多",
                                    @(NSURLErrorResourceUnavailable):@"网络资源无效",
                                    @(NSURLErrorNotConnectedToInternet):@"设备未连接到网络",
                                    @(NSURLErrorRedirectToNonExistentLocation):@"重定向到不存在的地址",
                                    @(NSURLErrorBadServerResponse):@"服务器响应错误",
                                    @(NSURLErrorUserCancelledAuthentication):@"网络授权取消",
                                    @(NSURLErrorUserAuthenticationRequired):@"需要用户授权"};
    
    
    NSString *errorMessage = errorMessages[@(error.code)];
    errorMessage = errorMessage ? [NSString stringWithFormat:@"网络请求错误：%@", errorMessage] : @"网络请求错误";
    
    return [NSError errorWithDomain:kQLRESTErrorDomain
                               code:kQLRESTNetworkErrorCode
                       errorMessage:errorMessage];
}

@end
