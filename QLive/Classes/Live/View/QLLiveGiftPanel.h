//
//  QLLiveGiftPanel.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLLiveGift.h"

typedef void (^QLLiveGiftDidSelectAction)(QLLiveGift *selectedGift, id obj);

@interface QLLiveGiftPanel : UIView

@property (nonatomic,retain) NSArray<QLLiveGift *> *gifts;
@property (nonatomic) NSUInteger goldCount;
@property (nonatomic,copy) QLLiveGiftDidSelectAction didSelectAction;
@property (nonatomic,copy) QBAction chargeAction;

+ (instancetype)showPanelInView:(UIView *)view withGifts:(NSArray<QLLiveGift *> *)gifts goldCount:(NSUInteger)goldCount didSelectAction:(QLLiveGiftDidSelectAction)didSelectAction chargeAction:(QBAction)chargeAction;
- (void)showInView:(UIView *)view;
- (void)hide;

@end
