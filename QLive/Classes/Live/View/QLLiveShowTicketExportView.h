//
//  QLLiveShowTicketExportView.h
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLLiveShowTicketExportView : UIView

@property (nonatomic) NSString *name;
@property (nonatomic) NSUInteger fee;

+ (instancetype)showTicketExportInView:(UIView *)view withName:(NSString *)name fee:(NSUInteger)fee;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
