//
//  NSError+QLError.h
//  Pods
//
//  Created by Sean Yue on 16/8/2.
//
//

#import <Foundation/Foundation.h>

@interface NSError (QLError)

@property (nonatomic) NSString *qlErrorMessage;
@property (nonatomic,readonly) NSInteger logicCode;

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code errorMessage:(NSString *)errorMessage;
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code errorMessage:(NSString *)errorMessage logicCode:(NSInteger)logicCode;

@end

extern NSString *const kQLErrorMessageKeyName;
extern NSString *const kQLLogicErrorCodeKeyName;
extern const NSInteger kQLInvalidLogicErrorCode;
