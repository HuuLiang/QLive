//
//  QLResourceDownloader.m
//  QLive
//
//  Created by Sean Yue on 2017/3/24.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLResourceDownloader.h"
#import <AFNetworking.h>
#import <SSZipArchive.h>

static NSString *const kQLResourceReadyUserDefaultsKey = @"com.qlive.userdefaults.resourceready";

@interface QLResourceDownloader ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) NSURLSessionDownloadTask *downloadTask;
@end

@implementation QLResourceDownloader
@synthesize resourcePath = _resourcePath;

QBSynthesizeSingletonMethod(sharedDownloader)

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isResourceReady {
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kQLResourceReadyUserDefaultsKey];
    return value.boolValue;
}

- (void)setIsResourceReady:(BOOL)isResourceReady {
    [[NSUserDefaults standardUserDefaults] setObject:@(isResourceReady) forKey:kQLResourceReadyUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)resourcePath {
    if (_resourcePath) {
        return _resourcePath;
    }
    
    NSString *targetPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    _resourcePath = [targetPath stringByAppendingPathComponent:@"liveresources/Resources"];
    return _resourcePath;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type {
    
    NSString *resourcePath = self.resourcePath;
    if (!resourcePath) {
        return [[NSBundle mainBundle] pathForResource:name ofType:type];
    }
    
    NSString *filePath = [resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, type]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    } else {
        return [[NSBundle mainBundle] pathForResource:name ofType:type];
    }
}

- (void)downloadResourceFile:(NSString *)fileURLString
                    progress:(void (^)(CGFloat))progress
                  completion:(QLCompletionHandler)completion
{
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.timeoutInterval = 30;
    
    [self.sessionManager GET:fileURLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QBSafelyCallBlock(progress, downloadProgress.totalUnitCount > 0 ? (CGFloat)downloadProgress.completedUnitCount/(CGFloat)downloadProgress.totalUnitCount : 0);
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        
        NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Resources_%@.zip", [QLUtil currentDateTimeString]]];
        BOOL success = [(NSData *)responseObject writeToFile:filePath atomically:YES];
        QBSafelyCallBlock(completion, success ? filePath : nil, success ? nil :[NSError errorWithDomain:@"com.qlive.errordomain.resourcedownloader" code:-1 userInfo:nil]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        QBSafelyCallBlock(completion, nil, error);
    }];
//    self.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            QBSafelyCallBlock(progress, downloadProgress.totalUnitCount > 0 ? (CGFloat)downloadProgress.completedUnitCount/(CGFloat)downloadProgress.totalUnitCount : 0);
//        });
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
//        NSString *filePath = [cachePath stringByAppendingPathComponent:response.suggestedFilename];
//        return [NSURL fileURLWithPath:filePath];
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            QBSafelyCallBlock(completion, filePath, error);
//        });
//    }];
//    [self.downloadTask resume];
}

- (void)unzipFile:(NSString *)filePath progress:(void (^)(CGFloat))progress completion:(QLCompletionHandler)completion {
    NSString *resourcePath = self.resourcePath;
    [SSZipArchive unzipFileAtPath:filePath toDestination:resourcePath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QBSafelyCallBlock(progress, total > 0 ? (CGFloat)entryNumber / (CGFloat)total : 0);
        });
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QBSafelyCallBlock(completion, resourcePath, error);
        });
    }];
}
@end
