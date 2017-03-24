//
//  QLResourceDownloader.h
//  QLive
//
//  Created by Sean Yue on 2017/3/24.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLResourceDownloader : NSObject

@property (nonatomic) BOOL isResourceReady;

QBDeclareSingletonMethod(sharedDownloader)

- (void)downloadResourceFile:(NSString *)fileURLString progress:(void (^)(CGFloat))progress completion:(QLCompletionHandler)completion;
- (void)unzipFile:(NSString *)filePath progress:(void (^)(CGFloat))progress completion:(QLCompletionHandler)completion;

@end
