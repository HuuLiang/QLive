//
//  QLHotViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/28.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLHotViewController.h"
#import "QLAnchorNormalCell.h"

static NSString *const kCellReusableIdentifier = @"CellReusableIdentifier";
static const NSUInteger kAnchorsPerPage = 10;

@interface QLHotViewController () <UITableViewDelegate,UITableViewDataSource,DBPersistentObserver>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) NSMutableArray<QLAnchor *> *pendingAnchors;
@property (nonatomic,retain) NSMutableArray<QLAnchor *> *displayAnchors;
@end

@implementation QLHotViewController

QBDefineLazyPropertyInitialization(NSMutableArray, pendingAnchors)
QBDefineLazyPropertyInitialization(NSMutableArray, displayAnchors)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[QLAnchorNormalCell class] forCellReuseIdentifier:kCellReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutTableView QBS_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadAnchorsForRefresh:YES];
    }];
    [_layoutTableView QBS_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadAnchorsForRefresh:NO];
    }];
    [_layoutTableView QBS_triggerPullToRefresh];
    
    [QLAnchor registerObserver:self];
}

- (void)loadAnchorsForRefresh:(BOOL)isRefresh {
    
    void (^Handler)(void) = ^{
        [_layoutTableView QBS_endPullToRefresh];
        
        NSArray *displayingAnchors = [self.pendingAnchors QL_arrayByPickingRandomCount:kAnchorsPerPage];
        [self.displayAnchors addObjectsFromArray:displayingAnchors];
        [self.pendingAnchors removeObjectsInArray:displayingAnchors];
        [_layoutTableView reloadData];
        
        if (self.pendingAnchors.count == 0) {
            [_layoutTableView QBS_pagingRefreshNoMoreData];
        }
    };
    
    if (isRefresh) {
        [QLAnchor objectsFromPersistenceAsync:^(NSArray *objects) {
            self.pendingAnchors = objects.mutableCopy;
            [self.displayAnchors removeAllObjects];
            Handler();
        }];
    } else {
        Handler();
    }
}

- (void)dealloc {
    [QLAnchor removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBPersistentObserver

- (void)DBPersistentClass:(Class)class didFinishOperation:(DBPersistenceOperation)operation {
    if (operation == DBPersistenceOperationRemove) {
        [self loadAnchorsForRefresh:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayAnchors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QLAnchorNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReusableIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    QLAnchor *anchor = indexPath.row < self.displayAnchors.count ? self.displayAnchors[indexPath.row] : nil;
    cell.anchor = anchor;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetWidth(tableView.bounds) + 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QLAnchor *anchor = indexPath.row < self.displayAnchors.count ? self.displayAnchors[indexPath.row] : nil;
    [self startLiveCastWithAnchor:anchor];
}
@end
