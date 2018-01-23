//
//  QLShowTimeViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/28.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLShowTimeViewController.h"
#import "QLShowTimeCell.h"
#import "QLBannerView.h"
#import "QLLiveShowViewController.h"
#import "QLLiveShowJumpQueuePopView.h"

static NSString *const kCellReusableIdentifier = @"CellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";

@interface QLShowTimeViewController () <UITableViewDataSource,UITableViewDelegate,DBPersistentObserver>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) NSArray<QLLiveShow *> *allShows;
//@property (nonatomic,retain) NSMutableArray<QLLiveShow *> *publicShows;
//@property (nonatomic,retain) NSMutableArray<QLLiveShow *> *privateShows;
//@property (nonatomic,retain) NSMutableArray<QLLiveShow *> *bigShows;
@property (nonatomic,retain) NSMutableArray<QLLiveShow *> *currentLiveShows;
@property (nonatomic,retain) NSArray<QLAdInfo *> *adInfos;
@end

@implementation QLShowTimeViewController

//QBDefineLazyPropertyInitialization(NSMutableArray, publicShows)
//QBDefineLazyPropertyInitialization(NSMutableArray, privateShows)
//QBDefineLazyPropertyInitialization(NSMutableArray, bigShows)
QBDefineLazyPropertyInitialization(NSMutableArray, currentLiveShows)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[QLShowTimeCell class] forCellReuseIdentifier:kCellReusableIdentifier];
    [_layoutTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kHeaderReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self loadLiveShows];
    
    [QLLiveShow registerObserver:self];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [_layoutTableView reloadData];
//}

- (void)dealloc {
    [QLLiveShow removeObserver:self];
}

- (void)loadLiveShows {
    
    [QLLiveShow objectsFromPersistenceAsync:^(NSArray *liveShows) {
        
        [QLLiveShowTicketInfo objectsFromPersistenceAsync:^(NSArray *tickets) {
            
            [QLLiveShow mapLiveShows:liveShows withTicketInfos:tickets];
            
            self.allShows = liveShows;
            
            [self updateCurrentLiveShows];
        }];
        
    }];
    
    @weakify(self);
    [[QLRESTManager sharedManager] request_queryAdInfosWithCompletionHandler:^(id obj, NSError *error) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (obj) {
            self.adInfos = [(QLAdInfos *)obj adInfos];
            [self->_layoutTableView reloadData];
        }
    }];
    
}

- (void)updateCurrentLiveShows {
    NSMutableArray<QLLiveShow *> *unpaidPublicShows = [NSMutableArray array];
    NSMutableArray<QLLiveShow *> *paidPublicShows = [NSMutableArray array];
    NSMutableArray<QLLiveShow *> *privateShows = [NSMutableArray array];
    NSMutableArray<QLLiveShow *> *bigShows = [NSMutableArray array];
    
    [self.allShows bk_each:^(QLLiveShow *obj) {
        if ([obj.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
            if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
                || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]) {
                [paidPublicShows addObject:obj];
            } else {
                [unpaidPublicShows addObject:obj];
            }
        } else if ([obj.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
            [privateShows addObject:obj];
        } else if ([obj.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow]) {
            [bigShows addObject:obj];
        }
    }];
    
    NSMutableArray<QLLiveShow *> *currentLiveShows = [NSMutableArray array];
    
    __block NSUInteger numberOfUnpaidLiveShows = 0;
    __block NSUInteger numberOfPrivateLiveShows = 0;
    [self.currentLiveShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([unpaidPublicShows containsObject:obj]) {
            ++numberOfUnpaidLiveShows;
        } else if ([privateShows containsObject:obj]) {
            ++numberOfPrivateLiveShows;
        }
        
        if ([self.allShows containsObject:obj]) {
            [currentLiveShows addObject:obj];
        }
    }];
    
    if (numberOfUnpaidLiveShows < 2) {
        [currentLiveShows addObjectsFromArray:[unpaidPublicShows QL_arrayByPickingRandomCount:2-numberOfUnpaidLiveShows]];
    }
    
    if (numberOfPrivateLiveShows < 3) {
        [currentLiveShows addObjectsFromArray:[privateShows QL_arrayByPickingRandomCount:3-numberOfPrivateLiveShows]];
    }
    
    // Add paid public shows and big shows that NOT in current live shows
    [paidPublicShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![currentLiveShows containsObject:obj]) {
            [currentLiveShows addObject:obj];
        }
    }];
    
    [bigShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![currentLiveShows containsObject:obj]) {
            [currentLiveShows addObject:obj];
        }
    }];

    NSArray *sortedKeys = @[kQLLiveShowAnchorTypePublic,kQLLiveShowAnchorTypeBigShow,kQLLiveShowAnchorTypePrivate];
    [currentLiveShows sortUsingComparator:^NSComparisonResult(QLLiveShow * _Nonnull obj1, QLLiveShow * _Nonnull obj2) {
        NSUInteger index1 = [sortedKeys indexOfObject:obj1.anchorType];
        NSUInteger index2 = [sortedKeys indexOfObject:obj2.anchorType];
        if (index1 == 0 && index2 == 0) {
            NSUInteger order1 = obj1.isPaidPublicShow ? 1 : 0;
            NSUInteger order2 = obj2.isPaidPublicShow ? 1 : 0;
            return order1 - order2;
        } else {
            return [@(index1) compare:@(index2)];
        }
    }];
    
    self.currentLiveShows = currentLiveShows;
    [_layoutTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBPersistentObserver

- (void)DBPersistentClass:(Class)class didFinishOperation:(DBPersistenceOperation)operation {
    if (operation == DBPersistenceOperationRemove) {
        [self loadLiveShows];
    } else {
        [self updateCurrentLiveShows];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentLiveShows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QLShowTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReusableIdentifier forIndexPath:indexPath];
    
    QLLiveShow *liveShow = indexPath.row < self.currentLiveShows.count ? self.currentLiveShows[indexPath.row] : nil;
    cell.liveShow = liveShow;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderReusableIdentifier];
    
    static const void *kBannerViewAssociatedKey = &kBannerViewAssociatedKey;
    QLBannerView *bannerView = objc_getAssociatedObject(headerView, kBannerViewAssociatedKey);
    if (!bannerView) {
        bannerView = [[QLBannerView alloc] init];
        objc_setAssociatedObject(headerView, kBannerViewAssociatedKey, bannerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [headerView addSubview:bannerView];
        {
            [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(headerView);
            }];
        }
    }
    
    if (self.adInfos.count == 0) {
        bannerView.imageURLStringsGroup = @[@"newest_banner_1",@"newest_banner_2",@"newest_banner_3"];
        bannerView.titlesGroup = @[@"多看多互动，热力涨不停！",@"等级系统，全新上线！",@"绿色直播，拒绝违规！"];
        bannerView.selectionAction = nil;
        bannerView.hideText = NO;
        bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    } else {
        NSMutableArray *imageURLStrings = [NSMutableArray array];
        [self.adInfos enumerateObjectsUsingBlock:^(QLAdInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.imgCover) {
                [imageURLStrings addObject:obj.imgCover];
            }
        }];
        bannerView.imageURLStringsGroup = imageURLStrings;
        bannerView.hideText = YES;
        bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        
        @weakify(self);
        bannerView.selectionAction = ^(NSUInteger index, id obj) {
            @strongify(self);
            QLAdInfo *adInfo = index < self.adInfos.count ? self.adInfos[index] : nil;
            if (adInfo.adUrl.length) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adInfo.adUrl]];
            }
        };
    }
    return headerView;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetWidth(tableView.bounds) / 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QLLiveShow *liveShow = indexPath.row < self.currentLiveShows.count ? self.currentLiveShows[indexPath.row] : nil;
    if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
        if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeJumpQueue]) {
            QLLiveShowViewController *playerVC = [[QLLiveShowViewController alloc] initWithLiveShow:liveShow];
            [self.navigationController pushViewController:playerVC animated:YES];
        } else {
            @weakify(self);
            [QLLiveShowJumpQueuePopView popInView:self.view withLiveShow:liveShow jumpQueueAction:^(id obj) {
                @strongify(self);
                [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self
                                                                            withContentType:QLPaymentContentTypeJumpQueue
                                                                                   userInfo:@{kQLPaymentLiveShowUserInfo:liveShow}
                                                                                 completion:^(BOOL success, QLPayPoint *payPoint)
                {
                    @strongify(self);
                    if (success) {
                        liveShow.anchorType = kQLLiveShowAnchorTypeBigShow;
                        liveShow.anchorUrl2 = liveShow.anchorUrl;
                        [liveShow save];
                        
                        QLLiveShowViewController *playerVC = [[QLLiveShowViewController alloc] initWithLiveShow:liveShow];
                        [self.navigationController pushViewController:playerVC animated:YES];
                    }
                }];
            }];
        }
//    } else if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow]) {
//        if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
//            || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]) {
//            QLLiveShowViewController *playerVC = [[QLLiveShowViewController alloc] initWithLiveShow:liveShow];
//            [self.navigationController pushViewController:playerVC animated:YES];
//        } else {
//            @weakify(self);
//            [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self withContentType:QLPaymentContentTypeBookThisTicket userInfo:@{kQLPaymentLiveShowUserInfo:liveShow} completion:^(BOOL success, QLPayPoint *payPoint) {
//                if (success) {
//                    @strongify(self);
//                    QLLiveShowViewController *playerVC = [[QLLiveShowViewController alloc] initWithLiveShow:liveShow];
//                    [self.navigationController pushViewController:playerVC animated:YES];
//                }
//            }];
//        }
    } else {
        QLLiveShowViewController *playerVC = [[QLLiveShowViewController alloc] initWithLiveShow:liveShow];
        [self.navigationController pushViewController:playerVC animated:YES];
    }
}

@end
