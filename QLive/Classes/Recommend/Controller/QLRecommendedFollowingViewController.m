//
//  QLRecommendedFollowingViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLRecommendedFollowingViewController.h"
#import "QLRecommendCell.h"
#import "QLRecommendFooterView.h"

static NSString *const kAvatarCellReusableIdentifier = @"AvatarCellReusableIdentifier";
static NSString *const kFooterReusableIdentifier = @"FooterReusableIdentifier";
static NSString *const kShowViewControllerDateKey = @"com.qlive.config.date.showrecommend";
static const void *kRecommendAssociatedKey = &kRecommendAssociatedKey;

static const CGFloat kCellTitlHeight = 30;
static const CGFloat kInterItemSpacing = 15;
static const CGFloat kFooterViewHeight = 44;

@interface QLAnchor (QLRecommendSelection)
@property (nonatomic) BOOL isRecommended;
@end

@implementation QLAnchor (QLRecommendSelection)

- (BOOL)isRecommended {
    NSNumber *value = objc_getAssociatedObject(self, kRecommendAssociatedKey);
    return value.boolValue;
}

- (void)setIsRecommended:(BOOL)isRecommended {
    objc_setAssociatedObject(self, kRecommendAssociatedKey, @(isRecommended), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end

@interface QLRecommendedFollowingViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
    UIButton *_closeButton;
}
@property (nonatomic,retain,readonly) NSArray<QLAnchor *> *anchors;
@end

@implementation QLRecommendedFollowingViewController

- (instancetype)initWithAnchors:(NSArray<QLAnchor *> *)anchors {
    self = [super init];
    if (self) {
        _anchors = anchors;
        
        [_anchors bk_each:^(QLAnchor *obj) {
            obj.isRecommended = YES;
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kInterItemSpacing;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(kInterItemSpacing, kInterItemSpacing, kInterItemSpacing, kInterItemSpacing);
    
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((kScreenWidth-[self contentViewSize].width)/2, kScreenHeight, [self contentViewSize].width, [self contentViewSize].height) collectionViewLayout:layout];
    _layoutCollectionView.layer.cornerRadius = 15;
    _layoutCollectionView.backgroundColor = [UIColor whiteColor];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[QLRecommendCell class] forCellWithReuseIdentifier:kAvatarCellReusableIdentifier];
    [_layoutCollectionView registerClass:[QLRecommendFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    
    _closeButton = [[UIButton alloc] init];
//    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [_closeButton setImage:[UIImage imageNamed:@"yellow_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.hidden = YES;
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_layoutCollectionView.mas_top).offset(5);
            make.centerX.equalTo(_layoutCollectionView.mas_right).offset(-5);//.offset(-15);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    
//    for (NSUInteger i = 0; i < 9; ++i) {
//        QLUser *user = [[QLUser alloc] init];
//        user.userId = @(i).stringValue;
//        user.logoUrl = @"http://v1.qzone.cc/avatar/201407/15/09/00/53c47d2962bce014.jpg%21200x200.jpg";
//        user.name = @"你好吗";
//        user.isRecommended = YES;
//        [self.users addObject:user];
//    }
}

- (CGSize)contentViewSize {
    const CGFloat width = kScreenWidth * 0.8;
    const CGFloat height = width + kCellTitlHeight * 3 + kFooterViewHeight;
    return CGSizeMake(width, height);
}

- (void)onClose {
    if (!self.view.superview) {
        return ;
    }
    
    _closeButton.hidden = YES;
    
    CGRect frame = CGRectOffset(_layoutCollectionView.frame, 0, kScreenHeight - _layoutCollectionView.frame.origin.y);
    [UIView animateWithDuration:0.25 animations:^{
        _layoutCollectionView.frame = frame;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showContentViewAnimated {
    const CGSize size = [self contentViewSize];
    CGRect frame = CGRectMake(_layoutCollectionView.frame.origin.x, (kScreenHeight-size.height)/2, size.width, size.height);
    if (!CGRectEqualToRect(frame, _layoutCollectionView.frame)) {
        [UIView animateWithDuration:0.25 animations:^{
            _layoutCollectionView.frame = frame;
        } completion:^(BOOL finished) {
            _closeButton.hidden = NO;
        }];
    }
}

- (void)showInViewController:(UIViewController *)viewController {
    if ([viewController.childViewControllers containsObject:self]) {
        return ;
    }
    
    if ([viewController.view.subviews containsObject:self.view]) {
        return ;
    }
    
    [viewController addChildViewController:self];
    
    self.view.frame = viewController.view.bounds;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    
    [self showContentViewAnimated];
}

+ (void)showViewControllerIfNeededInViewController:(UIViewController *)viewController {
    NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:kShowViewControllerDateKey];
    if (dateString.length > 0) {
        NSDate *date = [QLUtil dateFromString:dateString];
        if ([date isToday]) {
            return ;
        }
    }
    
    [QLAnchor objectsFromPersistenceAsync:^(NSArray *objects) {
        if (objects.count == 0) {
            return ;
        }
        
        NSArray<QLAnchor *> *unfollowedAnchors = [objects bk_select:^BOOL(QLAnchor *obj) {
            return obj.followingTime.length == 0;
        }];
        
        if (unfollowedAnchors.count == 0) {
            return ;
        }
        
        NSArray<QLAnchor *> *displayAnchors = [unfollowedAnchors QL_arrayByPickingRandomCount:9];
        QLRecommendedFollowingViewController *followingVC = [[self alloc] initWithAnchors:displayAnchors];
        [followingVC showInViewController:viewController];
        
        [[NSUserDefaults standardUserDefaults] setObject:[QLUtil currentDateTimeString] forKey:kShowViewControllerDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QLRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAvatarCellReusableIdentifier forIndexPath:indexPath];
    
    QLAnchor *anchor = indexPath.item < self.anchors.count ? self.anchors[indexPath.item] : nil;
    cell.avatarURL = [NSURL URLWithString:anchor.logoUrl];
    cell.name = anchor.name;
    cell.selected = anchor.isRecommended;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    QLRecommendFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFooterReusableIdentifier forIndexPath:indexPath];
    
    footerView.title = @"一键关注";
    
    @weakify(self);
    footerView.action = ^(id obj) {
        @strongify(self);
        NSString *currentDateString = [QLUtil currentDateTimeString];
        NSArray *recommendedUsers = [self.anchors bk_select:^BOOL(QLAnchor *obj) {
            if (obj.isRecommended) {
                obj.followingTime = currentDateString;
            }
            return obj.isRecommended;
        }];
        
        [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:1 complete:^{
            [QLAnchor saveObjects:recommendedUsers withCompletion:^(BOOL success) {
                @strongify(self);
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFastFollowingNotification object:recommendedUsers];
                    [self onClose];
                } else {
                    [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"无法关注选中的用户"];
                }
            }];
        }];
        
    };
    
    return footerView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    const CGFloat interItemSpacing = layout.minimumInteritemSpacing;
    const UIEdgeInsets sectionInsets = layout.sectionInset;
    const CGFloat itemWidth = (CGRectGetWidth(collectionView.bounds) - sectionInsets.left - sectionInsets.right - interItemSpacing * 2)/3;
    return CGSizeMake(itemWidth, itemWidth+kCellTitlHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, kFooterViewHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.anchors.count) {
        QLAnchor *anchor = self.anchors[indexPath.item];
        anchor.isRecommended = !anchor.isRecommended;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}
@end
