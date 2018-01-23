//
//  QLBannerView.h
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "SDCycleScrollView.h"

typedef void (^QLBannerSelectionAction)(NSUInteger index, id obj);

@interface QLBannerView : SDCycleScrollView

@property (nonatomic,copy) QLBannerSelectionAction selectionAction;

@end
