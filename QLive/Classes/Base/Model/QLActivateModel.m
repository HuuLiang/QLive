//
//  QLActivateModel.m
//  PPVideo
//
//  Created by Liang on 2016/10/15.
//  Copyright © 2016年 Liang. All rights reserved.
//

#import "QLActivateModel.h"
#import <QBNetworkingConfiguration.h>

static NSString *const kSuccessResponse = @"SUCCESS";

@implementation QLActivateModel

+ (instancetype)sharedModel {
    static QLActivateModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QBNetworkingConfiguration *configuration = [[QBNetworkingConfiguration alloc] init];
        configuration.baseURL = @"http://spiv.jlswz.com";
        configuration.channelNo = kQLChannelNo;
        configuration.RESTAppId = kQLRESTAppId;
        configuration.RESTpV = @100;
        
        _sharedModel = [[QLActivateModel alloc] initWithConfiguration:configuration];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [NSString class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)activateWithCompletionHandler:(QLActivateHandler)handler {
    NSString *sdkV = [NSString stringWithFormat:@"%d.%d",
                      __IPHONE_OS_VERSION_MAX_ALLOWED / 10000,
                      (__IPHONE_OS_VERSION_MAX_ALLOWED % 10000) / 100];
    
    NSDictionary *params = @{@"cn":kQLChannelNo,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"sms":@"00000000000",
                             @"cw":@(kScreenWidth),
                             @"ch":@(kScreenHeight),
                             @"cm":[QLUtil deviceName],
                             @"mf":[UIDevice currentDevice].model,
                             @"sdkV":sdkV,
                             @"cpuV":@"",
                             @"appV":[QLUtil appVersion],
                             @"appVN":@"",
                             @"ccn":kPackageCertificate,
                             @"operator":[QBNetworkInfo sharedInfo].carriarName ?: @"",
                             @"systemVersion":[UIDevice currentDevice].systemVersion};
    
    BOOL success = [self requestURLPath:@"/iosvideo/activat.htm"
                             withParams:params
                        responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage) {
        NSString *userId;
        if (respStatus == QBURLResponseSuccess) {
            NSString *resp = self.response;
            NSArray *resps = [resp componentsSeparatedByString:@";"];
            
            NSString *success = resps.firstObject;
            if ([success isEqualToString:kSuccessResponse]) {
                userId = resps.count == 2 ? resps[1] : nil;
            }
        }
        
        if (handler) {
            handler(respStatus == QBURLResponseSuccess && userId, userId);
        }
    }];
    return success;
}


@end
