//
//  NSError+QLError.m
//  Pods
//
//  Created by Sean Yue on 16/8/2.
//
//

#import "NSError+QLError.h"
#import <NSMutableDictionary+SafeCoding.h>
#import <objc/runtime.h>

NSString *const kQLErrorMessageKeyName = @"com.qlive.errordomian.errormessage";
NSString *const kQLLogicErrorCodeKeyName = @"com.qlive.errordomain.logicerrorcode";
const NSInteger kQLInvalidLogicErrorCode = NSIntegerMax;

static const void *kQLErrorMessageAssociatedKey = &kQLErrorMessageAssociatedKey;

@implementation NSError (QLError)

- (NSString *)qlErrorMessage {
    NSString *errorMessage = objc_getAssociatedObject(self, kQLErrorMessageAssociatedKey);
    if (errorMessage) {
        return errorMessage;
    }
    
    return self.userInfo[kQLErrorMessageKeyName];
}

- (NSInteger)logicCode {
    NSNumber *logicCode = self.userInfo[kQLLogicErrorCodeKeyName];
    if (logicCode) {
        return logicCode.integerValue;
    }
    
    return kQLInvalidLogicErrorCode;
}

- (void)setQlErrorMessage:(NSString *)qlErrorMessage {
    objc_setAssociatedObject(self, kQLErrorMessageAssociatedKey, qlErrorMessage, OBJC_ASSOCIATION_COPY);
}

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code errorMessage:(NSString *)errorMessage {
    return [self errorWithDomain:domain code:code errorMessage:errorMessage logicCode:kQLInvalidLogicErrorCode];
}

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code errorMessage:(NSString *)errorMessage logicCode:(NSInteger)logicCode {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo safelySetObject:errorMessage forKey:kQLErrorMessageKeyName];
    if (logicCode != kQLInvalidLogicErrorCode) {
        [userInfo setObject:@(logicCode) forKey:kQLLogicErrorCodeKeyName];
    }
    
    return [self errorWithDomain:domain code:code userInfo:userInfo.count > 0 ? userInfo : nil];
}
@end
