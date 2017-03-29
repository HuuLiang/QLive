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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_layoutTableView reloadData];
}

- (void)dealloc {
    [QLLiveShow removeObserver:self];
}

- (void)loadLiveShows {
    
    [QLLiveShow objectsFromPersistenceAsync:^(NSArray *liveShows) {
        
        [QLLiveShowTicketInfo objectsFromPersistenceAsync:^(NSArray *tickets) {
            
            [QLLiveShow mapLiveShows:liveShows withTicketInfos:tickets];
            
            self.allShows = liveShows;
            
            [self updateShows];
        }];
        
    }];
    
}

- (void)updateShows {
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
//    
//    NSArray<QLLiveShow *> *unpaidPublicShows = [self.allShows bk_select:^BOOL(QLLiveShow *obj) {
//        return [obj.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]
//        && ![[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
//        && ![[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket];
//    }];
    

//    self.privateShows = [self.allShows bk_select:^BOOL(QLLiveShow *obj) {
//        return [obj.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate];
//    }].mutableCopy;
//    
//    self.bigShows = [self.allShows bk_select:^BOOL(QLLiveShow *obj) {
//        return [obj.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow];
//    }].mutableCopy;
//    
//    NSArray *publicShows = [self.publicShows QL_arrayByPickingRandomCount:2];
//    NSArray *privateShows = [self.privateShows QL_arrayByPickingRandomCount:3];
//    
//    NSArray *paidPublicShows = [self.allShows bk_select:^BOOL(QLLiveShow *obj) {
//        return [obj.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]
//        && ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
//            || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]);
//    }];
    
    [self.currentLiveShows removeAllObjects];
    [self.currentLiveShows addObjectsFromArray:[unpaidPublicShows QL_arrayByPickingRandomCount:2]];
    [self.currentLiveShows addObjectsFromArray:paidPublicShows];
    [self.currentLiveShows addObjectsFromArray:bigShows];
    [self.currentLiveShows addObjectsFromArray:[privateShows QL_arrayByPickingRandomCount:3]];
    
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
        [self updateShows];
//        __block NSUInteger numberOfPublicShows = 0;
//        __block NSUInteger numberOfPrivateShows = 0;
//        [self.currentLiveShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]
//                && ![[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
//                && ![[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(obj.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]) {
//                ++numberOfPublicShows;
//            } else if ([obj.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
//                ++numberOfPrivateShows;
//            }
//        }];
//        
//        if (numberOfPublicShows < 2) {
//            NSArray *publicShows = [self.publicShows QL_arrayByPickingRandomCount:2-numberOfPublicShows];
//            if (publicShows.count > 0) {
//                [self.currentLiveShows insertObjects:publicShows atIndexes:[NSIndexSet indexSetWithIndex:0]];
//                [self.publicShows removeObjectsInArray:publicShows];
//            }
//            
//        }
//        
//        if (numberOfPrivateShows < 3) {
//            NSArray *privateShows = [self.privateShows QL_arrayByPickingRandomCount:3-numberOfPrivateShows];
//            if (privateShows.count > 0) {
//                [self.currentLiveShows insertObjects:privateShows atIndexes:[NSIndexSet indexSetWithIndex:self.currentLiveShows.count-numberOfPrivateShows]];
//                [self.privateShows removeObjectsInArray:privateShows];
//            }
//        }
//        
//        [self.currentLiveShows sortUsingComparator:^NSComparisonResult(QLLiveShow * _Nonnull obj1, QLLiveShow * _Nonnull obj2) {
//            return [obj2.anchorType compare:obj1.anchorType];
//        }];
//        [_layoutTableView reloadData];
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
    if (!headerView.backgroundView) {
        QLBannerView *bannerView = [[QLBannerView alloc] init];
        bannerView.imageURLStringsGroup = @[@"newest_banner_1",@"newest_banner_2",@"newest_banner_3"];
        bannerView.titlesGroup = @[@"多看多互动，热力涨不停！",@"等级系统，全新上线！",@"绿色直播，拒绝违规！"];
        headerView.backgroundView = bannerView;
    }
    return headerView;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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
