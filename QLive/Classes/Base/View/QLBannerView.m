//
//  QLBannerView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBannerView.h"

@interface QLBannerView () <SDCycleScrollViewDelegate>

@end

@implementation QLBannerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
//        self.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        self.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        self.autoScrollTimeInterval = 5;
    }
    return self;
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    QBSafelyCallBlock(self.selectionAction, index, cycleScrollView);
}

@end
