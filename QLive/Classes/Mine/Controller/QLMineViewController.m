//
//  QLMineViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineViewController.h"
#import "QLMineProfileViewController.h"
#import "QLMineZoneViewController.h"
#import "QLMineVIPViewController.h"
#import "QLMineIncomeViewController.h"
#import "QLMineLatestVisitorViewController.h"
#import "QLCustomerServiceViewController.h"
#import "QLDebugViewController.h"
#import "QLMineAvatarCell.h"

typedef NS_ENUM(NSUInteger, MineSection) {
    ProfileSection,
    ZoneSection,
    PaymentSection,
    LatestVisitorSection,
    //CustomerServiceSection,
    DebugSection,
    MineSectionCount = DebugSection
};

typedef NS_ENUM(NSUInteger, PaymentSectionRow) {
    VIPRow,
    IncomeRow,
    ActivateRow,
    PaymentSectionRowCount
};

static NSString *const kProfileCellReusableIdentifier = @"ProfileCellReusableIdentifier";
static NSString *const kMineCellReusableIdentifier = @"MineCellReusableIdentifier";

@interface QLMineViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UIView *_statusBarBgView;
    UITableView *_layoutTableView;
}
@property (nonatomic) BOOL debugMode;
@end

@implementation QLMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    self.navigationItem.navigationBarHidden = YES;
    
    _statusBarBgView = [[UIView alloc] init];
    _statusBarBgView.backgroundColor = [QLTheme defaultTheme].themeColor;
    [self.view addSubview:_statusBarBgView];
    {
        [_statusBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(20);
        }];
    }
    
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _layoutTableView.backgroundColor = self.view.backgroundColor;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.sectionFooterHeight = 0;
    _layoutTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_statusBarBgView.mas_bottom);
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDebugNotification) name:kDebugNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_layoutTableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDebugNotification {
    if (self.tabBarController.selectedViewController != self.navigationController) {
        return ;
    }
    
    self.debugMode = YES;
    [_layoutTableView insertSections:[NSIndexSet indexSetWithIndex:DebugSection] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.debugMode ? MineSectionCount + 1 : MineSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PaymentSection) {
        return PaymentSectionRowCount;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ProfileSection) {
    
        QLMineAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileCellReusableIdentifier];
        if (!cell) {
            cell = [[QLMineAvatarCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kProfileCellReusableIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:[QLUser currentUser].logoUrl];
        cell.avatarImage = image ?: [UIImage imageNamed:@"mine_avatar"];
        cell.name = [QLUser currentUser].name;
        cell.userId = [QLUser currentUser].userId;
        return cell;
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMineCellReusableIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kMineCellReusableIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
            cell.textLabel.font = kMediumFont;
            cell.detailTextLabel.font = kSmallFont;
        }
        
        cell.detailTextLabel.text = nil;
        if (indexPath.section == ZoneSection) {
            cell.textLabel.text = @"我的动态";
        } else if (indexPath.section == PaymentSection) {
            if (indexPath.row == VIPRow) {
                cell.textLabel.text = @"会员注册";
                cell.detailTextLabel.text = @"开通VIP";
            } else if (indexPath.row == IncomeRow) {
                cell.textLabel.text = @"我的收益";
                cell.detailTextLabel.text = @"提现";
            } else if (indexPath.row == ActivateRow) {
                cell.textLabel.text = @"自助激活";
                cell.detailTextLabel.text = @"付费未激活服务";
            }
        } else if (indexPath.section == LatestVisitorSection) {
            cell.textLabel.text = @"最近访客";
        }
      //  else if (indexPath.section == CustomerServiceSection) {
       //     cell.textLabel.text = @"客服中心";
       // }
        else if (indexPath.section == DebugSection) {
            cell.textLabel.text = @"调试模式";
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ProfileSection) {
        return MAX(88, kScreenHeight * 0.15);
    } else {
        return MAX(44, kScreenHeight * 0.08);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == ProfileSection) {
        return 0;
    } else {
        return 10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == ProfileSection) {
        [self.navigationController pushViewController:[[QLMineProfileViewController alloc] init] animated:YES];
    } else if (indexPath.section == ZoneSection) {
        [self.navigationController pushViewController:[[QLMineZoneViewController alloc] init] animated:YES];
    } else if (indexPath.section == PaymentSection) {
        if (indexPath.row == VIPRow) {
            [self.navigationController pushViewController:[[QLMineVIPViewController alloc] init] animated:YES];
        } else if (indexPath.row == IncomeRow) {
            [self.navigationController pushViewController:[[QLMineIncomeViewController alloc] init] animated:YES];
        } else if (indexPath.row == ActivateRow) {
            [[QLPaymentManager sharedManager] activateUnsuccessfulPayments];
        }
    } else if (indexPath.section == LatestVisitorSection) {
        [[QLAlertManager sharedManager] alertWithTitle:nil message:@"最近没有访客..."];
//        [self.navigationController pushViewController:[[QLMineLatestVisitorViewController alloc] init] animated:YES];
    }
   // else if (indexPath.section == CustomerServiceSection) {
   //     [self.navigationController pushViewController:[[QLCustomerServiceViewController alloc] init] animated:YES];
    //}
    else if (indexPath.section == DebugSection) {
        [self.navigationController pushViewController:[[QLDebugViewController alloc] init] animated:YES];
    }
}
@end
