//
//  QLPaymentActionSheetButton.h
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLPaymentActionSheetButton : UIButton

@property (nonatomic,retain,readonly) UIImage *image;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *subtitle;

- (instancetype)init __attribute__((unavailable("Use -initWithTitle:subtitle:image: instead!")));
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image;


@end
