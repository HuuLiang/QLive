//
//  QLFollowingViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/28.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLFollowingViewController.h"
#import "QLAnchorNormalCell.h"
#import "QLFollowingHeaderView.h"
#import "QLFollowingPlaceholderCell.h"
#import "QLSegmentedControl.h"

static NSString *const kCellReusableIdentifier = @"CellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReuableIdentifier";
static NSString *const kPlaceholderReusableIdentifier = @"PlaceholderReusableIdentifier";

@interface QLFollowingViewController () <DBPersistentObserver, UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) NSArray<QLAnchor *> *followingAnchors;
@end

@implementation QLFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[QLAnchorNormalCell class] forCellReuseIdentifier:kCellReusableIdentifier];
    [_layoutTableView registerClass:[QLFollowingPlaceholderCell class] forCellReuseIdentifier:kPlaceholderReusableIdentifier];
    [_layoutTableView registerClass:[QLFollowingHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [QLAnchor registerObserver:self];
    [self reloadFolowingUsers];
}

- (void)reloadFolowingUsers {
    @weakify(self);
    [QLAnchor objectsFromPersistenceAsync:^(NSArray *objects) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        NSArray<QLAnchor *> *followingAnchors = [objects bk_select:^BOOL(QLAnchor *obj) {
            return obj.followingTime.length > 0;
        }];
        
        self.followingAnchors = [followingAnchors sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[(QLAnchor *)obj1 followingTime] compare:[(QLAnchor *)obj2 followingTime]];
        }];
        [self->_layoutTableView reloadData];
        
    }];
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
    [self reloadFolowingUsers];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followingAnchors.count ?: 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.followingAnchors.count == 0) {
        QLFollowingPlaceholderCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaceholderReusableIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.title = @"你的好友静悄悄\n此时还没有直播";
        cell.buttonTitle = @"去看看最新精彩直播";
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"following_placeholder_banner" ofType:@"jpg"];
        UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imagePath];
        cell.backgroundImage = backgroundImage;
        return cell;
    } else {
        QLAnchorNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReusableIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        QLAnchor *anchor = indexPath.row < self.followingAnchors.count ? self.followingAnchors[indexPath.row] : nil;
        cell.anchor = anchor;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QLFollowingHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderReusableIdentifier];
    headerView.title = @"关注好友的直播";
    return headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.followingAnchors.count > 0 ? CGRectGetWidth(tableView.bounds) + 70 : CGRectGetWidth(tableView.bounds)/2.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[QLFollowingPlaceholderCell class]]) {
        self.segmentedControl.selectedIndex = 2;
    } else if ([cell isKindOfClass:[QLAnchorNormalCell class]]) {
        QLAnchor *anchor = indexPath.row < self.followingAnchors.count ? self.followingAnchors[indexPath.row] : nil;
        [self startLiveCastWithAnchor:anchor];
    }
}
@end
