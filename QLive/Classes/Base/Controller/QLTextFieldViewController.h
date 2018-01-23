//
//  QLTextFieldViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/4.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLayoutTableViewController.h"

typedef BOOL (^QLTextFieldDidFinishAction)(NSString *text, id obj);

@interface QLTextFieldViewController : QLLayoutTableViewController

- (instancetype)init __attribute__((unavailable("Use -initWithText:placeholder:maxLength:didFinishAction: instead!")));
- (instancetype)initWithText:(NSString *)text
                 placeholder:(NSString *)placeholder
                   maxLength:(NSUInteger)maxLength
             didFinishAction:(QLTextFieldDidFinishAction)didFinishAction;

@property (nonatomic,readonly) NSString *placeHolder;
@property (nonatomic,readonly) NSString *text;
@property (nonatomic,readonly) NSUInteger maxLength;

@property (nonatomic,copy) QLTextFieldDidFinishAction didFinishAction;

@end
