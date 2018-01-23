//
//  QLPaymentViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPaymentViewController.h"
#import "QLPaymentCell.h"
#import "QLNewPaymentCell.h"

#define kContentViewWidth (kScreenWidth * 0.9)

@interface QLPaymentViewController ()
{
    UIButton *_closeButton;
}
@property (nonatomic) BOOL isNewCell;
@end

@implementation QLPaymentViewController

+ (instancetype)showPaymentInViewController:(UIViewController *)viewController
                                bannerImage:(UIImage *)bannerImage
                                 UIElements:(NSArray<QLPaymentUIElement *> *)UIElements
                                  isNewCell:(BOOL)isNewCell
{
    QLPaymentViewController *paymentVC = [[self alloc] init];
    paymentVC.bannerImage = bannerImage;
    paymentVC.UIElements = UIElements;
    paymentVC.isNewCell = isNewCell;
    [paymentVC showInViewController:viewController];
    return paymentVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    self.layoutTableView.backgroundColor = [UIColor whiteColor];
    self.layoutTableView.layer.cornerRadius = 10;
    self.layoutTableView.layer.masksToBounds = YES;
    self.layoutTableView.scrollEnabled = NO;
    //    [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.center.equalTo(self.view);
    //        make.width.equalTo(self.view).multipliedBy(0.8);
    //        make.height.equalTo(self.layoutTableView.mas_width).multipliedBy(0.72);
    //    }];
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"long_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.layoutTableView.mas_top);
            make.right.mas_equalTo(self.layoutTableView).mas_offset(-5);
            make.size.mas_equalTo(CGSizeMake(16, 40));
        }];
    }
    if (self.isNewCell) {
        NSMutableDictionary *cells = [NSMutableDictionary dictionary];
        __block CGFloat heightOfElements = 0;
        [self.UIElements enumerateObjectsUsingBlock:^(QLPaymentUIElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QLNewPaymentCell *cell = [[QLNewPaymentCell alloc] initWithUIElement:obj owner:self];
            cell.selectionStyle = 0;
            cell.bannerImage = self.bannerImage;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            heightOfElements = obj.height;
            [cells setObject:cell forKey:indexPath];
            *stop = YES;
        }];
        CGFloat height = CGRectGetWidth(self.layoutTableView.bounds) / kBannerCellWidthToHeight + heightOfElements;
        self.cells = cells;
        self.cellHeightBlock = ^CGFloat(NSIndexPath *indexPath, UITableView *tableView) {
            if (indexPath.row == 0) {
                return height;
            }
            return 0;
        };
        [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(height);
            make.width.mas_equalTo(kContentViewWidth);
        }];
        
    }else {
        NSMutableDictionary *cells = [NSMutableDictionary dictionary];
        
        UITableViewCell *bannerCell = [[UITableViewCell alloc] init];
        UIImageView *bannerImageView = [[UIImageView alloc] initWithImage:self.bannerImage];
        bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        bannerImageView.clipsToBounds = YES;
        bannerCell.backgroundView = bannerImageView;
        bannerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cells setObject:bannerCell forKey:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        __block CGFloat heightOfElements = 0;
        NSMutableDictionary *cellHeights = [NSMutableDictionary dictionary];
        [self.UIElements enumerateObjectsUsingBlock:^(QLPaymentUIElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QLPaymentCell *cell = [[QLPaymentCell alloc] initWithUIElement:obj owner:self];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:0];
            [cells setObject:cell forKey:indexPath];
            [cellHeights setObject:@(obj.height) forKey:indexPath];
            heightOfElements += obj.height;
        }];
        
        self.cells = cells;
        self.cellHeights = cellHeights;
        self.cellHeightBlock = ^CGFloat(NSIndexPath *indexPath, UITableView *tableView) {
            if (indexPath.row == 0) {
                return CGRectGetWidth(tableView.bounds) / kBannerCellWidthToHeight;
            }
            return 0;
        };
        
        [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.mas_equalTo(kContentViewWidth);
            make.height.mas_equalTo(kContentViewWidth/kBannerCellWidthToHeight+heightOfElements);
        }];
    }
}

- (void)onClose {
    [self hideAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)hideAnimated:(BOOL)animated {
    if (self.parentViewController) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self willMoveToParentViewController:nil];
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        } else {
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

@end
