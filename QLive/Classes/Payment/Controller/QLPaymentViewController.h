//
//  QLPaymentViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLayoutTableViewController.h"
#import "QLPaymentUIElement.h"

@interface QLPaymentViewController : QLLayoutTableViewController

@property (nonatomic,retain) UIImage *bannerImage;
@property (nonatomic,retain) NSArray<QLPaymentUIElement *> *UIElements;

+ (instancetype)showPaymentInViewController:(UIViewController *)viewController bannerImage:(UIImage *)bannerImage UIElements:(NSArray<QLPaymentUIElement *> *)UIElements isNewCell:(BOOL)isNewCell;
- (void)showInViewController:(UIViewController *)viewController;
- (void)hideAnimated:(BOOL)animated;

@end
