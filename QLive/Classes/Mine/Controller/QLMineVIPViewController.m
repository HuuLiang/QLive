//
//  QLMineVIPViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineVIPViewController.h"
#import "QLMineVIPGoldCell.h"
#import "QLMineVIPMemberCell.h"
#import "QLMineVIPChargeCell.h"
#import "QLMineVIPHeaderView.h"
#import "QLCustomerServiceViewController.h"
#import "QLPaymentActionSheet.h"
#import <NSString+md5.h>

typedef NS_ENUM(NSUInteger, ThisSection) {
    GoldSection,
    VIPSection,
    ChargeSection,
    ThisSectionCount
};

static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";
static NSString *const kGoldCellReusableIdentifier = @"GoldCellReusableIdentifier";
static NSString *const kVIPCellReusableIdentifier = @"VIPCellReusableIdentifier";
static NSString *const kChargeCellReusableIdentifier = @"ChargeCellReusableIdentifier";

@interface QLMineVIPViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_layoutTableView;
}
@end

@implementation QLMineVIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.title ?: @"我的账户";
    
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[QLMineVIPGoldCell class] forCellReuseIdentifier:kGoldCellReusableIdentifier];
    [_layoutTableView registerClass:[QLMineVIPMemberCell class] forCellReuseIdentifier:kVIPCellReusableIdentifier];
    [_layoutTableView registerClass:[QLMineVIPChargeCell class] forCellReuseIdentifier:kChargeCellReusableIdentifier];
    [_layoutTableView registerClass:[QLMineVIPHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _layoutTableView.tableFooterView = tableFooterView;
    
    UIButton *footerButton = [[UIButton alloc] init];
    [footerButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"联系我们" attributes:@{NSUnderlineStyleAttributeName:@1, NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"], NSFontAttributeName:kMediumFont}] forState:UIControlStateNormal];
    [footerButton addTarget:self action:@selector(onContactUs) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:footerButton];
    {
        [footerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(tableFooterView);
        }];
    }
    
}

- (void)onContactUs {
    QLCustomerServiceViewController *csVC = [[QLCustomerServiceViewController alloc] init];
    [self.navigationController pushViewController:csVC animated:YES];
}

//- (void)payWithPayPoint:(QLPayPoint *)payPoint payType:(QBOrderPayType)payType {
//    QBOrderInfo *orderInfo = [[QBOrderInfo alloc] init];
//    
//    NSString *channelNo = kQLChannelNo;
//    if (channelNo.length > 14) {
//        channelNo = [channelNo substringFromIndex:channelNo.length-14];
//    }
//    
//    channelNo = [channelNo stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
//    
//    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
//    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
//    orderInfo.orderId = orderNo;
//    
//    orderInfo.orderPrice = 1;//payPoint.fee.unsignedIntegerValue;
//    orderInfo.orderDescription = payPoint.pointDesc;
//    orderInfo.payType = payType;
//    orderInfo.reservedData = [NSString stringWithFormat:@"%@$%@", kQLRESTAppId, kQLChannelNo];
//    orderInfo.createTime = [QLUtil currentDateTimeString];
//    orderInfo.userId = [QLUser currentUser].userId;
//    orderInfo.maxDiscount = 5;
//    
//    if ([payPoint.pointType isEqualToString:kQLVIPPayPointType]) {
//        orderInfo.targetPayPointType = 1;
//    } else if ([payPoint.pointType isEqualToString:kQLChargePayPointType]) {
//        orderInfo.targetPayPointType = 2;
//    } else if ([payPoint.pointType isEqualToString:kQLAnchorPayPointType]) {
//        orderInfo.targetPayPointType = 3;
//    }
//    
//    @weakify(self);
//    [[QBPaymentManager sharedManager] startPaymentWithOrderInfo:orderInfo
//                                                    contentInfo:nil
//                                                    beginAction:nil
//                                              completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo)
//    {
//        @strongify(self);
//        if (payResult == QBPayResultSuccess) {
//            [[QLHUDManager sharedManager] showSuccess:@"支付成功"];
//            
//            if ([payPoint.pointType isEqualToString:kQLVIPPayPointType]) {
//                [QLUser currentUser].isVIP = @1;
//                [[QLUser currentUser] saveAsCurrentUser];
//            } else if ([payPoint.pointType isEqualToString:kQLChargePayPointType]) {
//                NSUInteger goldCount = payPoint.goldCount.unsignedIntegerValue;
//                if (payType == QBOrderPayTypeWeChatPay) {
//                    goldCount += 500;
//                }
//                [[QLUser currentUser] addGoldCount:goldCount];
//                [[QLUser currentUser] saveAsCurrentUser];
//            }
//            
//            if (self) {
//                [self->_layoutTableView reloadData];
//            }
//        } else if (payResult == QBPayResultCancelled) {
//            [[QLHUDManager sharedManager] showInfo:@"支付取消"];
//        } else {
//            [[QLHUDManager sharedManager] showError:@"支付失败"];
//        }
//    }];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ThisSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == GoldSection) {
        return 1;
    } else if (section == VIPSection) {
        return [QLPayPoints sharedPayPoints].VIP.count;
    } else if (section == ChargeSection) {
        return [QLPayPoints sharedPayPoints].DEPOSIT.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GoldSection) {
        QLMineVIPGoldCell *cell = [tableView dequeueReusableCellWithIdentifier:kGoldCellReusableIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.goldCount = [QLUser currentUser].goldCount.unsignedIntegerValue;
        return cell;
    } else if (indexPath.section == VIPSection) {
        QLMineVIPMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kVIPCellReusableIdentifier forIndexPath:indexPath];
        
        NSArray<QLPayPoint *> *payPoints = [QLPayPoints sharedPayPoints].VIP;
        QLPayPoint *payPoint = indexPath.row < payPoints.count ? payPoints[indexPath.row] : nil;
        cell.amount = payPoint.fee.floatValue/100;
        cell.isVIP = [QLUser currentUser].isVIP.boolValue;
        return cell;
    } else if (indexPath.section == ChargeSection) {
        QLMineVIPChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kChargeCellReusableIdentifier forIndexPath:indexPath];
        
        NSArray<QLPayPoint *> *payPoints = [QLPayPoints sharedPayPoints].DEPOSIT;
        QLPayPoint *payPoint = indexPath.row < payPoints.count ? payPoints[indexPath.row] : nil;
        NSUInteger goldCount = payPoint.fee.unsignedIntegerValue/10;
        NSUInteger bonusGolds = payPoint.goldCount.unsignedIntegerValue - goldCount;
        [cell setAmount:payPoint.fee.floatValue/100 withGoldCount:goldCount bonusGoldCount:bonusGolds];
        return cell;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QLMineVIPHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderReusableIdentifier];
    if (section == VIPSection) {
        headerView.title = @"  VIP 用户  ";
    } else if (section == ChargeSection) {
        headerView.title = @"  充值  ";
    }
    return headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GoldSection) {
        return CGRectGetHeight(tableView.bounds)/4;
    } else if (indexPath.section == VIPSection) {
        return CGRectGetHeight(tableView.bounds)/6;
    } else if (indexPath.section == ChargeSection) {
        return CGRectGetHeight(tableView.bounds)/8;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return 20;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QLPayPoint *payPoint;
    if (indexPath.section == VIPSection) {
        payPoint = indexPath.row < [QLPayPoints sharedPayPoints].VIP.count ? [QLPayPoints sharedPayPoints].VIP[indexPath.row] : nil;
    } else if (indexPath.section == ChargeSection) {
        payPoint = indexPath.row < [QLPayPoints sharedPayPoints].DEPOSIT.count ? [QLPayPoints sharedPayPoints].DEPOSIT[indexPath.row] : nil;
    }
    
    if (payPoint) {
        @weakify(self);
        [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint contentId:payPoint.id completed:^(BOOL success) {
            @strongify(self);
            if (success && self) {
                [self->_layoutTableView reloadData];
            }
        }];
//        NSMutableArray *payTypes = [NSMutableArray array];
//        if ([[QBPaymentManager sharedManager] isOrderPayTypeAvailable:QBOrderPayTypeWeChatPay]) {
//            [payTypes addObject:@(QBOrderPayTypeWeChatPay)];
//        }
//        if ([[QBPaymentManager sharedManager] isOrderPayTypeAvailable:QBOrderPayTypeAlipay]) {
//            [payTypes addObject:@(QBOrderPayTypeAlipay)];
//        }
//        
//        if (payTypes.count == 0) {
//            [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"无可用支付方式"];
//            return ;
//        }
//        
//        QLPaymentActionSheet *paymentSheet = [[QLPaymentActionSheet alloc] initWithAvailablePayTypes:payTypes payPoint:payPoint];
//        @weakify(self);
//        paymentSheet.selectionAction = ^(QBOrderPayType payType, id obj) {
//            @strongify(self);
//            [self payWithPayPoint:payPoint payType:payType];
//        };
//        [paymentSheet showInWindow];
    }
}
@end
