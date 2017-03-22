//
//  QLHomeViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLHomeViewController.h"
#import "QLSegmentedControl.h"
#import "QLFollowingViewController.h"
#import "QLHotViewController.h"
#import "QLNewestViewController.h"
#import "QLShowTimeViewController.h"
#import "QLRecentMessageViewController.h"
#import "QLSearchViewController.h"

@interface QLHomeViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>
@property (nonatomic,retain) UIPageViewController *pageVC;
@property (nonatomic,retain) QLSegmentedControl *segmentedControl;
@property (nonatomic,retain) NSArray<UIViewController *> *viewControllers;
@property (nonatomic,retain) UIViewController *currentViewController;
@end

@implementation QLHomeViewController

- (QLSegmentedControl *)segmentedControl {
    if (_segmentedControl) {
        return _segmentedControl;
    }
    
    @weakify(self);
    _segmentedControl = [[QLSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.75, 44)];
    _segmentedControl.titles = @[@"关注",@"热门",@"最新",@"秀场"];
    _segmentedControl.selectionAction = ^(NSUInteger idx, id obj) {
        @strongify(self);
        [self turnToPageAtIndex:idx];
    };
    
    UIButton *button = [_segmentedControl buttonAtIndex:_segmentedControl.titles.count-1];
    [button setImage:[UIImage imageNamed:@"show_segment_icon"] forState:UIControlStateNormal];
    return _segmentedControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbaritem_search"] style:UIBarButtonItemStylePlain target:self action:@selector(onSearch)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbaritem_chat"] style:UIBarButtonItemStylePlain target:self action:@selector(onChat)];
    
    
    self.navigationItem.titleView = self.segmentedControl;
    
    self.viewControllers = @[[[QLFollowingViewController alloc] initWithSegmentedControl:self.segmentedControl],
                             [[QLHotViewController alloc] initWithSegmentedControl:self.segmentedControl],
                             [[QLNewestViewController alloc] initWithSegmentedControl:self.segmentedControl],
                             [[QLShowTimeViewController alloc] initWithSegmentedControl:self.segmentedControl]];
    
    _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageVC.delegate = self;
    _pageVC.dataSource = self;
    [_pageVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)obj).delegate = self;
        }
    }];
    [self addChildViewController:_pageVC];
    [self.view addSubview:_pageVC.view];
    [_pageVC didMoveToParentViewController:self];

    self.segmentedControl.selectedIndex = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFastFollowingNotification) name:kFastFollowingNotification object:nil];

}

- (void)onFastFollowingNotification {
    self.segmentedControl.selectedIndex = 0;
}

- (void)onSearch {
    QLSearchViewController *searchVC = [[QLSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:NO];
}

- (void)onChat {
    QLRecentMessageViewController *messageVC = [[QLRecentMessageViewController alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)turnToPageAtIndex:(NSUInteger)index {
    if (index >= self.viewControllers.count) {
        return ;
    }
    
    NSUInteger oldIndex = [self.viewControllers indexOfObject:self.currentViewController];
    UIPageViewControllerNavigationDirection navDirection = UIPageViewControllerNavigationDirectionForward;
    if (oldIndex != NSNotFound && index < oldIndex) {
        navDirection = UIPageViewControllerNavigationDirectionReverse;
    }
    self.currentViewController = [self.viewControllers objectAtIndex:index];
    [self.pageVC setViewControllers:@[self.currentViewController] direction:navDirection animated:YES completion:nil];
//    
//    if (self.segmentedControl.selectedIndex != index) {
//        self.segmentedControl.selectedIndex = index;
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound || index + 1 == self.viewControllers.count) {
        return nil;
    } else {
        return [self.viewControllers objectAtIndex:index+1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound || index == 0) {
        return nil;
    } else {
        return [self.viewControllers objectAtIndex:index-1];
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentViewController = pageViewController.viewControllers.firstObject;
        self.segmentedControl.selectedIndex = [self.viewControllers indexOfObject:self.currentViewController];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.bounds.size.width == 0 ) {
        return ;
    }
    
    if (scrollView.dragging || scrollView.decelerating) {
        CGFloat offset = (scrollView.contentOffset.x - scrollView.bounds.size.width) / scrollView.bounds.size.width;
        self.segmentedControl.indicatorOffset = offset;
    }
    
   
}
@end
