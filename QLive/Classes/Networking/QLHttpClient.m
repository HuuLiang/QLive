//
//  QLHttpClient.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLHttpClient.h"
#import <NSString+md5.h>
#import <NSString+crypt.h>
#import <AFNetworking.h>

NSString *const kQLHttpClientArgErrorDomain = @"com.qlive.errordomain.arg";

static NSString *const kQLHttpEncryptedPassword = @"wdnxs&*@#!*qb)*&qiang";

@interface QLHttpClient ()
@property (nonatomic,readonly) NSURL *baseURL;
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@end

@implementation QLHttpClient

+ (instancetype)sharedClient {
    static QLHttpClient *_sharedClient;
    static dispatch_once_t _sharedOnceToken;
    dispatch_once(&_sharedOnceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kQLRESTBaseURL]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    self = [self init];
    if (self) {
        _baseURL = baseURL;
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)requestURL:(NSString *)urlPath
        withParams:(id)params
        methodType:(QLHttpMethodType)methodtype
 completionHandler:(QLCompletionHandler)completionHandler
{
    QBLog(@"Request URL: %@ with params: \n%@", urlPath, params);
    
    @weakify(self);
    if (methodtype == QLHttpMethodGET) {
        urlPath = [urlPath stringByAppendingFormat:@"?t=%@", [QLUtil currentDateString]];
        [self.sessionManager GET:urlPath parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @strongify(self);
            id decryptedResponse = [self decryptedResponse:responseObject];
            QBLog(@"QBStoreSDK HTTP URL:%@ \nResponse: %@", urlPath, decryptedResponse);
            QBSafelyCallBlock(completionHandler, decryptedResponse, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            QBLog(@"QBStoreSDK HTTP URL:%@ \nNetwork Error: %@", urlPath, error.localizedDescription);
            QBSafelyCallBlock(completionHandler, nil, error);
        }];
    } else if (methodtype == QLHttpMethodPOST) {
        [self.sessionManager POST:urlPath parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @strongify(self);
            id decryptedResponse = [self decryptedResponse:responseObject];
            QBLog(@"QBStoreSDK HTTP URL:%@ \nResponse: %@", urlPath, decryptedResponse);
            QBSafelyCallBlock(completionHandler, decryptedResponse, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            QBLog(@"QBStoreSDK HTTP URL:%@ \nNetwork Error: %@", urlPath, error.localizedDescription);
            QBSafelyCallBlock(completionHandler, nil, error);
        }];
    } else {
        NSError *error = [NSError errorWithDomain:kQLHttpClientArgErrorDomain code:-1 userInfo:@{kQLErrorMessageKeyName:@"The HTTP method type is NOT supported!"}];
        QBLog(@"QBStoreSDK HTTP URL:%@ \nError:%@", urlPath, error.userInfo[kQLErrorMessageKeyName]);
        QBSafelyCallBlock(completionHandler, nil, error);
    }
}

- (id)decryptedResponse:(id)response {
    NSString *encryptedString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if (encryptedString.length == 0) {
        return nil;
    }
    
    NSString *key = [kQLHttpEncryptedPassword.md5 substringToIndex:16];
    NSString *jsonString = [encryptedString decryptedStringWithPassword:key];
    if (jsonString.length == 0) {
        return nil;
    }
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return jsonObject;
}

//
//- (id)encryptParams:(id)params {
//    if (!params) {
//        return nil;
//    }
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
//    if (!jsonData) {
//        return nil;
//    }
//    
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *encryptedDataString = [jsonString encryptedStringWithPassword:[kEncryptionPassword.md5 substringToIndex:16]];
//    return @{@"data":encryptedDataString};
//}
@end
