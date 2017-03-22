//
//  UIScrollView+Refresh.m
//  QBStoreSDK
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>

static const void *kQBSRefreshViewAssociatedKey = &kQBSRefreshViewAssociatedKey;
static const void *kQBSShowLastUpdatedTimeAssociatedKey = &kQBSShowLastUpdatedTimeAssociatedKey;
static const void *kQBSShowStateAssociatedKey = &kQBSShowStateAssociatedKey;

@implementation UIScrollView (Refresh)

- (UIColor *)QBS_refreshTextColor {
    return [UIColor colorWithWhite:0.5 alpha:1];
}

- (BOOL)isRefreshing {
    if ([self.QBS_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.QBS_refreshView;
        return refresh.state == MJRefreshStateRefreshing;
    }
    return NO;
}

- (UIView *)QBS_refreshView {
    return objc_getAssociatedObject(self, kQBSRefreshViewAssociatedKey);
}

- (void)setQBS_showLastUpdatedTime:(BOOL)QBS_showLastUpdatedTime {
    objc_setAssociatedObject(self, kQBSShowLastUpdatedTimeAssociatedKey, @(QBS_showLastUpdatedTime), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.mj_header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        header.lastUpdatedTimeLabel.hidden = !QBS_showLastUpdatedTime;
    }
}

- (BOOL)QBS_showLastUpdatedTime {
    NSNumber *value = objc_getAssociatedObject(self, kQBSShowLastUpdatedTimeAssociatedKey);
    return value.boolValue;
}

- (void)setQBS_showStateLabel:(BOOL)QBS_showStateLabel {
    objc_setAssociatedObject(self, kQBSShowStateAssociatedKey, @(QBS_showStateLabel), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.mj_header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        header.stateLabel.hidden = !QBS_showStateLabel;
    }
}

- (BOOL)QBS_showStateLabel {
    NSNumber *value = objc_getAssociatedObject(self, kQBSShowStateAssociatedKey);
    return value.boolValue;
}

- (void)QBS_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_header) {
            MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
//            refreshHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            refreshHeader.lastUpdatedTimeLabel.textColor = [self QBS_refreshTextColor];
            refreshHeader.stateLabel.textColor = [self QBS_refreshTextColor];
            refreshHeader.lastUpdatedTimeLabel.hidden = !self.QBS_showLastUpdatedTime;
        self.mj_header = refreshHeader;
        
        objc_setAssociatedObject(self, kQBSRefreshViewAssociatedKey, refreshHeader, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)QBS_triggerPullToRefresh {
    
    if ([self.QBS_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.QBS_refreshView;
        [refresh beginRefreshing];
    }
}

- (void)QBS_endPullToRefresh {
    if ([self.QBS_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.QBS_refreshView;
        [refresh endRefreshing];
    }
    
    [self.mj_footer resetNoMoreData];
}

- (void)QBS_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        refreshFooter.automaticallyHidden = YES;
        refreshFooter.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        refreshFooter.stateLabel.textColor = [self QBS_refreshTextColor];
        self.mj_footer = refreshFooter;
    }
}

- (void)QBS_pagingRefreshNoMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)QBS_setPagingRefreshText:(NSString *)text {
    if ([self.mj_footer isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.mj_footer;
        [footer setTitle:text forState:MJRefreshStateIdle];
    }
}

- (void)QBS_setPagingNoMoreDataText:(NSString *)text {
    if ([self.mj_footer isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.mj_footer;
        [footer setTitle:text forState:MJRefreshStateNoMoreData];
    }
}
@end
