//
//  QLActivateModel.h
//  PPVideo
//
//  Created by Liang on 2016/10/15.
//  Copyright © 2016年 Liang. All rights reserved.
//

#import "QBEncryptedURLRequest.h"

typedef void (^QLActivateHandler)(BOOL success, NSString *userId);

@interface QLActivateModel : QBEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)activateWithCompletionHandler:(QLActivateHandler)handler;


@end
