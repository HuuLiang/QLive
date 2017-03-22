//
//  QLNewestViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/28.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLNewestViewController.h"
#import "QLNewestAnchorCell.h"
#import "QLCollectionHeaderFooterView.h"
#import "QLBannerView.h"

static NSString *const kCellReusableIdentifier = @"CellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";

@interface QLNewestViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,DBPersistentObserver>
{
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) NSMutableArray<QLAnchor *> *pendingAnchors;
@property (nonatomic,retain) NSMutableArray<QLAnchor *> *displayAnchors;
@property (nonatomic,retain) NSDate *lastLoadDate;
@end

@implementation QLNewestViewController

QBDefineLazyPropertyInitialization(NSMutableArray, pendingAnchors)
QBDefineLazyPropertyInitialization(NSMutableArray, displayAnchors)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(layout.minimumInteritemSpacing, 0, 0, 0);
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[QLNewestAnchorCell class] forCellWithReuseIdentifier:kCellReusableIdentifier];
    [_layoutCollectionView registerClass:[QLCollectionHeaderFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCollectionView QBS_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadDataForRefresh:NO];
    }];
    
    [QLAnchor registerObserver:self];
}

- (void)dealloc {
    [QLAnchor removeObserver:self];
}

- (void)loadDataForRefresh:(BOOL)isRefresh {

    void (^Handler)(void) = ^(void) {
        self.lastLoadDate = [NSDate date];
        [_layoutCollectionView QBS_endPullToRefresh];
        
        NSArray *displayingAnchors = [self.pendingAnchors QL_arrayByPickingRandomCount:10];
        [self.displayAnchors addObjectsFromArray:displayingAnchors];
        [self.pendingAnchors removeObjectsInArray:displayingAnchors];
        [_layoutCollectionView reloadData];
        
        if (self.pendingAnchors.count == 0) {
            [_layoutCollectionView QBS_pagingRefreshNoMoreData];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.lastLoadDate || [[NSDate date] timeIntervalSinceDate:self.lastLoadDate] > 15) {
        [self loadDataForRefresh:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBPersistentObserver

- (void)DBPersistentClass:(Class)class didFinishOperation:(DBPersistenceOperation)operation {
    if (operation == DBPersistenceOperationRemove) {
        [self loadDataForRefresh:YES];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.displayAnchors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QLNewestAnchorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReusableIdentifier forIndexPath:indexPath];
    
    QLAnchor *anchor = indexPath.item < self.displayAnchors.count ? self.displayAnchors[indexPath.item] : nil;
    cell.imageURL = [NSURL URLWithString:anchor.imgCover];
    cell.star = anchor.anchorRank.unsignedIntegerValue;
    cell.numberOfAudience = anchor.onlineUsers.unsignedIntegerValue;
    cell.typeString = [anchor.anchorType isEqualToString:kQLAnchorTypeShow] ? @"秀场" : @"直播";
    cell.typeStringColor = [anchor.anchorType isEqualToString:kQLAnchorTypeShow] ? [UIColor redColor] : [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QLCollectionHeaderFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderReusableIdentifier forIndexPath:indexPath];
    if (!headerView.backgroundView) {
        QLBannerView *bannerView = [[QLBannerView alloc] init];
        bannerView.imageURLStringsGroup = @[@"newest_banner_1",@"newest_banner_2",@"newest_banner_3"];
        bannerView.titlesGroup = @[@"多看多互动，热力涨不停！",@"等级系统，全新上线！",@"绿色直播，拒绝违规！"];
        headerView.backgroundView = bannerView;
    }

    return headerView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat interItemSpacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    const CGFloat itemWidth = (CGRectGetWidth(collectionView.bounds) - interItemSpacing)/2;
    return CGSizeMake(itemWidth, itemWidth);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, CGRectGetWidth(collectionView.bounds) / 3);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QLAnchor *anchor = indexPath.item < self.displayAnchors.count ? self.displayAnchors[indexPath.item] : nil;
    [self startLiveCastWithAnchor:anchor];
}
@end
