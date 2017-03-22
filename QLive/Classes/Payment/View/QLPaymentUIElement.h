//
//  QLPaymentUIElement.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLPaymentUIElement : NSObject

@property (nonatomic,retain) UIImage *image;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) BOOL imageIsRound;
@property (nonatomic) UIViewContentMode imageContentMode;

@property (nonatomic) NSAttributedString *attributedText;
@property (nonatomic) NSString *actionName;
@property (nonatomic,copy) QBAction action;
@property (nonatomic) CGFloat height;

@end
