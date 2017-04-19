//
//  QLPaymentManager.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPaymentManager.h"
#import "QLPaymentActionSheet.h"
#import <QBPaymentManager.h>
#import <QBPaymentInfo.h>
#import <QBPaymentConfig.h>
#import <NSString+md5.h>
#import "QLMineVIPViewController.h"
#import "QLPaymentUIElement.h"
#import "QLPaymentViewController.h"

NSString *const kQLPaymentLiveCastAnchorUserInfo = @"LIVE_CAST_ANCHOR";
NSString *const kQLPaymentLiveShowUserInfo = @"LIVE_SHOW";

@implementation QLPaymentManager

QBSynthesizeSingletonMethod(sharedManager)

- (void)setup {
    QBPaymentConfig *config = [[QBPaymentConfig alloc] init];
    
    QBPaymentConfigDetail *configDetails = [[QBPaymentConfigDetail alloc] init];
    //爱贝默认配置
//    QBIAppPayConfig * iAppPayConfig = [[QBIAppPayConfig alloc] init];
//    iAppPayConfig.appid = @"3006339410";
//    iAppPayConfig.privateKey = @"MIICWwIBAAKBgQCHEQCLCZujWicF6ClEgHx4L/OdSHZ1LdKi/mzPOIa4IRfMOS09qDNV3+uK/zEEPu1DgO5Cl1lsm4xpwIiOqdXNRxLE9PUfgRy4syiiqRfofAO7w4VLSG4S0VU5F+jqQzKM7Zgp3blbc5BJ5PtKXf6zP3aCAYjz13HHH34angjg0wIDAQABAoGASOJm3aBoqSSL7EcUhc+j2yNdHaGtspvwj14mD0hcgl3xPpYYEK6ETTHRJCeDJtxiIkwfxjVv3witI5/u0LVbFmd4b+2jZQ848BHGFtZFOOPJFVCylTy5j5O79mEx0nJN0EJ/qadwezXr4UZLDIaJdWxhhvS+yDe0e0foz5AxWmkCQQDhd9U1uUasiMmH4WvHqMfq5l4y4U+V5SGb+IK+8Vi03Zfw1YDvKrgv1Xm1mdzYHFLkC47dhTm7/Ko8k5Kncf89AkEAmVtEtycnSYciSqDVXxWtH1tzsDeIMz/ZlDGXCAdUfRR2ZJ2u2jrLFunoS9dXhSGuERU7laasK0bDT4p0UwlhTwJAVF+wtPsRnI1PxX6xA7WAosH0rFuumax2SFTWMLhGduCZ9HEhX97/sD7V3gSnJWRsDJTasMEjWtrxpdufvPOnDQJAdsYPVGMItJPq5S3n0/rv2Kd11HdOD5NWKsa1mMxEjZN5lrfhoreCb7694W9pI31QWX6+ZUtvcR0fS82KBn3vVQJAa0fESiiDDrovKHBm/aYXjMV5anpbuAa5RJwCqnbjCWleZMwHV+8uUq9+YMnINZQnvi+C62It4BD+KrJn5q4pwg==";
//    iAppPayConfig.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbNQyxdpLeMwE0QMv/dB3Jn1SRqYE/u3QT3ig2uXu4yeaZo4f7qJomudLKKOgpa8+4a2JAPRBSueDpiytR0zN5hRZKImeZAu2foSYkpBqnjb5CRAH7roO7+ervoizg6bhAEx2zlltV9wZKQZ0Di5wCCV+bMSEXkYqfASRplYUvHwIDAQAB";
//    iAppPayConfig.notifyUrl = @"http://phas.zcqcmj.com/pd-has/notifyIpay.json";
//    iAppPayConfig.waresid = @(1);
//    configDetails.iAppPayConfig = iAppPayConfig;
    
//    //盾行天下
//    QBDXTXPayConfig *dxtxPayConfig = [[QBDXTXPayConfig alloc] init];
//    dxtxPayConfig.appKey = @"90F8AE207145CE2E5747B15DBAF075ABE69F356FE3C9700D";
//    dxtxPayConfig.appid = @"8";
//    dxtxPayConfig.waresid = @8;
//    dxtxPayConfig.notifyUrl = @"http://phas.zcqcmj.com/pd-has/notifyDxtxios.json";
//    configDetails.dxtxPayConfig = dxtxPayConfig;
    
    //雷胜
    QBLSPayConfig *lsPayConfig = [[QBLSPayConfig alloc] init];
    lsPayConfig.key = @"5a5259202a1863eb6c2f7d2b26a11e68";
    lsPayConfig.mchId = @"1031";
    lsPayConfig.notifyUrl = @"http://phas.ayyygs.com/pd-has/notifyLsPay.json";
    configDetails.lsPayConfig = lsPayConfig;
  
    QBYiPayConfig *yiPayConfig = [[QBYiPayConfig alloc] init];
    yiPayConfig.appId = @"1065";
    yiPayConfig.key = @"ZLZTS9tpMk03gCPFMlf7WU2j";
    yiPayConfig.mchId = @"QBKJ";
    configDetails.yiPayConfig = yiPayConfig;
    
    //支付方式
    QBPaymentConfigSummary *payConfig = [[QBPaymentConfigSummary alloc] init];
    payConfig.wechat = kQBLSPayConfigName;
    payConfig.alipay = kQBYiPayConfigName;
    
    config.configDetails = configDetails;
    config.payConfig = payConfig;
    config.contact = @"QQ:3324615224";
    [config setAsCurrentConfig];
    
    [[QBPaymentManager sharedManager] registerPaymentWithAppId:kQLRESTAppId
                                                     paymentPv:@(kQLPaymentPv)
                                                     channelNo:kQLChannelNo
                                                     urlScheme:kQLPaymentURLScheme
                                                 defaultConfig:config
                                                defaultTimeOut:5];
}

- (void)showPaymnetViewControllerInViewController:(UIViewController *)viewController
                                  withContentType:(QLPaymentContentType)contentType
                                         userInfo:(NSDictionary *)userInfo
                                       completion:(void (^)(BOOL success, QLPayPoint *payPoint))completion
{
    if (contentType == QLPaymentContentTypeVIP || contentType == QLPaymentContentTypeCharge) {
        QLMineVIPViewController *vipVC = [[QLMineVIPViewController alloc] init];
        [viewController.navigationController pushViewController:vipVC animated:YES];
    } else if (contentType == QLPaymentContentTypePrivateCast) {
        QLAnchor *anchor = userInfo[kQLPaymentLiveCastAnchorUserInfo];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[QLResourceDownloader sharedDownloader] pathForResource:@"private_show_payment_banner" ofType:@"jpg"]];
        
        QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_PrivateCast];
        }];
        
        QLPaymentUIElement *element = [[QLPaymentUIElement alloc] init];
        element.imageURL = [NSURL URLWithString:anchor.logoUrl];
        element.imageIsRound = YES;
        element.actionName = @"私播";
        element.height = 120;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"来与我交给朋友吧❤️\n主播QQ/微信号\n" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"心动价 ¥%@\n", QLIntegralPrice(payPoint.fee.floatValue/100)] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"一对一交友私播\n" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"赠送%ld金币", (unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        element.attributedText = attrString;
        
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(anchor.userId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
//                     [self readPrivateInfos];
                     QBSafelyCallBlock(completion, YES, payPoint);
                     [obj hideAnimated:NO];
                 } else {
                     QBSafelyCallBlock(completion, NO, payPoint);
                 }
             }];
        };
        [QLPaymentViewController showPaymentInViewController:viewController bannerImage:image UIElements:@[element]];
    } else if (contentType == QLPaymentContentTypeLightThisCast || contentType == QLPaymentContentTypeLightMonthlyCast) {
        QLAnchor *anchor = userInfo[kQLPaymentLiveCastAnchorUserInfo];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[QLResourceDownloader sharedDownloader] pathForResource:@"light_room_payment_banner" ofType:@"jpg"]];
        
        NSMutableArray *elements = [NSMutableArray arrayWithCapacity:2];
        // Light once
        QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_LightThisCast];
        }];
        
        QLPaymentUIElement *element = [[QLPaymentUIElement alloc] init];
        element.image = [UIImage imageNamed:@"light_this_cast_payment_logo"];
        element.actionName = @"点亮";
        element.height = 70;
        element.imageContentMode = UIViewContentModeScaleAspectFit;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"本场点亮 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动价 ¥%@\n赠送%ld金币", QLIntegralPrice(payPoint.fee.floatValue/100),(unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        element.attributedText = attrString;
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(anchor.userId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:NO];
                 }
                 
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [elements addObject:element];
        
        // Light monthly
        payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_LightMonthlyCast];
        }];
        
        element = [[QLPaymentUIElement alloc] init];
        element.image = [UIImage imageNamed:@"light_monthly_cast_payment_logo"];
        element.actionName = @"点亮";
        element.height = 70;
        element.imageContentMode = UIViewContentModeScaleAspectFit;
        
        attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"本场点亮 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动价 ¥%@\n赠送%ld金币", QLIntegralPrice(payPoint.fee.floatValue/100),(unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n包月观看秀场" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}]];
        element.attributedText = attrString;
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(anchor.userId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:NO];
                 }
                 
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [elements addObject:element];
        
        [QLPaymentViewController showPaymentInViewController:viewController bannerImage:image UIElements:elements];
    } else if (contentType == QLPaymentContentTypePrivateShow) {
        QLLiveShow *liveShow = userInfo[kQLPaymentLiveShowUserInfo];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[QLResourceDownloader sharedDownloader] pathForResource:@"live_private_show_banner" ofType:@"jpg"]];
        
        QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_PrivateShow];
        }];
        
        QLPaymentUIElement *element = [[QLPaymentUIElement alloc] init];
        element.imageURL = [NSURL URLWithString:liveShow.logoUrl];
        element.imageIsRound = YES;
        element.imageContentMode = UIViewContentModeScaleAspectFill;
        element.actionName = @"私秀";
        element.height = 100;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"喜欢我，就来加我吧❤️\n主播QQ/微信号 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"心动价 ¥%@\n", QLIntegralPrice(payPoint.fee.floatValue/100)] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"一对一激情私秀 " attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"赠送%ld金币", (unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        element.attributedText = attrString;
        
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(liveShow.liveId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:YES];
                 }
                 
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [QLPaymentViewController showPaymentInViewController:viewController bannerImage:image UIElements:@[element]];
    } else if (contentType == QLPaymentContentTypeJumpQueue) {

        QLLiveShow *liveShow = userInfo[kQLPaymentLiveShowUserInfo];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[QLResourceDownloader sharedDownloader] pathForResource:@"live_show_jump_queue_banner" ofType:@"jpg"]];
        
        QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_JumpQueue];
        }];
        
        QLPaymentUIElement *element = [[QLPaymentUIElement alloc] init];
        element.imageURL = [NSURL URLWithString:liveShow.logoUrl];
        element.imageIsRound = YES;
        element.imageContentMode = UIViewContentModeScaleAspectFill;
        element.actionName = @"插队";
        element.height = 100;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"该房间正在秘播中\n" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"插队上车观看 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动价¥%@\n赠送%ld金币", QLIntegralPrice(payPoint.fee.floatValue/100),(unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        element.attributedText = attrString;
        
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(liveShow.liveId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:YES];
                 }
                 
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [QLPaymentViewController showPaymentInViewController:viewController bannerImage:image UIElements:@[element]];
    } else if (contentType == QLPaymentContentTypeBookThisTicket || contentType == QLPaymentContentTypeBookMonthlyTicket) {
        QLLiveShow *liveShow = userInfo[kQLPaymentLiveShowUserInfo];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[QLResourceDownloader sharedDownloader] pathForResource:@"live_show_ticket_banner" ofType:@"jpg"]];
        
        NSMutableArray *elements = [NSMutableArray array];
        // 本场
        QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_BookThisTicket];
        }];
        
        QLPaymentUIElement *element = [[QLPaymentUIElement alloc] init];
        element.image = [UIImage imageNamed:@"light_this_cast_payment_logo"];
        element.imageIsRound = NO;
        element.imageContentMode = UIViewContentModeScaleAspectFit;
        element.actionName = @"上车";
        element.height = 80;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"本场观看 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动价 ¥%@\n赠送%ld金币", QLIntegralPrice(payPoint.fee.floatValue/100),(unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        element.attributedText = attrString;

        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(liveShow.liveId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:YES];
                 }
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [elements addObject:element];
        
        // 包月
        payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
            return [obj.name isEqualToString:kQLAnchorPayPointName_BookMonthlyTicket];
        }];
        
        element = [[QLPaymentUIElement alloc] init];
        element.image = [UIImage imageNamed:@"vip_icon"];
        element.imageIsRound = NO;
        element.imageContentMode = UIViewContentModeScaleAspectFit;
        element.actionName = @"上车";
        element.height = 80;
        
        attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"包月观看 " attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动价 ¥%@\n", QLIntegralPrice(payPoint.fee.floatValue/100)] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"(30天不限场)" attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"赠送%ld金币", (unsigned long)payPoint.goldCount.unsignedIntegerValue] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}]];
        
        element.attributedText = attrString;
        
        element.action = ^(id obj) {
            [[QLPaymentManager sharedManager] showPaymentActionSheetWithPayPoint:payPoint
                                                                       contentId:@(liveShow.liveId.integerValue)
                                                                       completed:^(BOOL success)
             {
                 if (success) {
                     [obj hideAnimated:YES];
                 }
                 
                 QBSafelyCallBlock(completion, success, payPoint);
             }];
        };
        [elements addObject:element];
        
        [QLPaymentViewController showPaymentInViewController:viewController bannerImage:image UIElements:elements];
    }
}

- (void)showPaymentActionSheetWithPayPoint:(QLPayPoint *)payPoint
                                 contentId:(NSNumber *)contentId
                                 completed:(void (^)(BOOL success))completed {
    if (!payPoint) {
        QBSafelyCallBlock(completed, QBPayResultUnknown);
        return ;
    }
    
    NSMutableArray *payTypes = [NSMutableArray array];
    if ([[QBPaymentManager sharedManager] isOrderPayTypeAvailable:QBOrderPayTypeWeChatPay]) {
        [payTypes addObject:@(QBOrderPayTypeWeChatPay)];
    }
    if ([[QBPaymentManager sharedManager] isOrderPayTypeAvailable:QBOrderPayTypeAlipay]) {
        [payTypes addObject:@(QBOrderPayTypeAlipay)];
    }
    
    if (payTypes.count == 0) {
        [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"无可用支付方式"];
        return ;
    }
    
    QLPaymentActionSheet *paymentSheet = [[QLPaymentActionSheet alloc] initWithAvailablePayTypes:payTypes payPoint:payPoint];
    @weakify(self);
    paymentSheet.selectionAction = ^(QBOrderPayType payType, id obj) {
        @strongify(self);
        [self payWithPayPoint:payPoint payType:payType contentId:contentId completed:completed];
    };
    [paymentSheet showInWindow];
}

- (void)payWithPayPoint:(QLPayPoint *)payPoint
                payType:(QBOrderPayType)payType
              contentId:(NSNumber *)contentId
              completed:(void (^)(BOOL success))completed {
    QBOrderInfo *orderInfo = [[QBOrderInfo alloc] init];
    
    NSString *channelNo = kQLChannelNo;
    if (channelNo.length > 14) {
        channelNo = [channelNo substringFromIndex:channelNo.length-14];
    }
    
    channelNo = [channelNo stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    orderInfo.orderId = orderNo;
    
#ifdef DEBUG
    orderInfo.orderPrice = payType == QBOrderPayTypeAlipay ? 200 : 1;//payPoint.fee.unsignedIntegerValue; //
#else
    orderInfo.orderPrice = payPoint.fee.unsignedIntegerValue; //payType == QBOrderPayTypeAlipay ? 200 : 1;//
#endif
    orderInfo.orderDescription = payPoint.pointDesc;
    orderInfo.payType = payType;
    orderInfo.reservedData = [NSString stringWithFormat:@"%@$%@", kQLRESTAppId, kQLChannelNo];
    orderInfo.createTime = [QLUtil currentDateTimeString];
    orderInfo.userId = [QLUtil userId] ?: [QLUser currentUser].userId ?: @"anonymous";
    orderInfo.maxDiscount = 5;
    
    if ([payPoint.pointType isEqualToString:kQLVIPPayPointType]) {
        orderInfo.targetPayPointType = 1;
    } else if ([payPoint.pointType isEqualToString:kQLChargePayPointType]) {
        orderInfo.targetPayPointType = 2;
    } else if ([payPoint.pointType isEqualToString:kQLAnchorPayPointType]) {
        orderInfo.targetPayPointType = 3;
    }
    
    QBContentInfo *contentInfo = [[QBContentInfo alloc] init];
    contentInfo.contentId = contentId;
    contentInfo.contentType = @([self contentTypeFromPayPoint:payPoint]);
    
    [[QBPaymentManager sharedManager] startPaymentWithOrderInfo:orderInfo
                                                    contentInfo:contentInfo
                                                    beginAction:nil
                                              completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo)
     {
         if (payResult == QBPayResultSuccess) {
             [[QLHUDManager sharedManager] showSuccess:@"支付成功"];
             
             if ([payPoint.pointType isEqualToString:kQLVIPPayPointType]) {
                 [QLUser currentUser].isVIP = @1;
                 if (payType == QBOrderPayTypeWeChatPay) {
                     [[QLUser currentUser] addGoldCount:500];
                 }
                 [[QLUser currentUser] saveAsCurrentUser];
             } else if (payPoint.goldCount.unsignedIntegerValue > 0) {
                 NSUInteger goldCount = payPoint.goldCount.unsignedIntegerValue;
                 if (payType == QBOrderPayTypeWeChatPay) {
                     goldCount += 500;
                 }
                 [[QLUser currentUser] addGoldCount:goldCount];
                 [[QLUser currentUser] saveAsCurrentUser];
             }
         } else if (payResult == QBPayResultCancelled) {
             [[QLHUDManager sharedManager] showInfo:@"支付取消"];
         } else {
             [[QLHUDManager sharedManager] showError:@"支付失败"];
         }
         
         QBSafelyCallBlock(completed, payResult == QBPayResultSuccess);
     }];
}

- (QLPaymentContentType)contentTypeFromPayPoint:(QLPayPoint *)payPoint {
    QLPaymentContentType contentType = QLPaymentContentTypeNone;
    if ([payPoint.pointType isEqualToString:kQLVIPPayPointType]) {
        contentType = QLPaymentContentTypeVIP;
    } else if ([payPoint.pointType isEqualToString:kQLChargePayPointType]) {
        contentType = QLPaymentContentTypeCharge;
    } else if ([payPoint.pointType isEqualToString:kQLAnchorPayPointType]) {
        NSDictionary *typeMapping = @{kQLAnchorPayPointName_PrivateCast:@(QLPaymentContentTypePrivateCast),
                                      kQLAnchorPayPointName_LightThisCast:@(QLPaymentContentTypeLightThisCast),
                                      kQLAnchorPayPointName_LightMonthlyCast:@(QLPaymentContentTypeLightMonthlyCast),
                                      kQLAnchorPayPointName_PrivateShow:@(QLPaymentContentTypePrivateShow),
                                      kQLAnchorPayPointName_JumpQueue:@(QLPaymentContentTypeJumpQueue),
                                      kQLAnchorPayPointName_BookThisTicket:@(QLPaymentContentTypeBookThisTicket),
                                      kQLAnchorPayPointName_BookMonthlyTicket:@(QLPaymentContentTypeBookMonthlyTicket)};
        
        contentType = [typeMapping[payPoint.name] unsignedIntegerValue];
    }
    return contentType;
}

- (BOOL)contentIsPaidWithContentId:(NSNumber *)contentId contentType:(QLPaymentContentType)contentType {
    return [[QBPaymentInfo allPaymentInfos] bk_any:^BOOL(QBPaymentInfo *obj) {
        return obj.paymentResult == QBPayResultSuccess && obj.contentType.unsignedIntegerValue == contentType && [contentId isEqualToNumber:obj.contentId];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QBPaymentManager sharedManager] applicationWillEnterForeground:application];
}

- (void)handleOpenUrl:(NSURL *)url {
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
}

- (void)activateUnsuccessfulPayments {
    [[QLHUDManager sharedManager] showLoading];
    
    NSArray<QBPaymentInfo *> *unsuccessfulPaymentInfos = [[QBPaymentInfo allPaymentInfos] bk_select:^BOOL(QBPaymentInfo *obj) {
        return obj.paymentResult != QBPayResultSuccess;
    }];
    
    [[QBPaymentManager sharedManager] activatePaymentInfos:unsuccessfulPaymentInfos withCompletionHandler:^(BOOL success, id obj) {
        [[QLHUDManager sharedManager] hide];
        
        if (success) {
            
            QBPaymentInfo *successfulPaymentInfo = obj;
            
            const NSUInteger contentId = successfulPaymentInfo.contentId.unsignedIntegerValue;
            const QLPaymentContentType contentType = successfulPaymentInfo.contentType.unsignedIntegerValue;
            
//            QLPaymentContentTypeVIP,
//            QLPaymentContentTypeCharge,
//            QLPaymentContentTypePrivateCast, //私播
//            QLPaymentContentTypeLightThisCast, //本场点亮
//            QLPaymentContentTypeLightMonthlyCast, //包月点亮
//            QLPaymentContentTypePrivateShow, //私秀
//            QLPaymentContentTypeJumpQueue, //插队
//            QLPaymentContentTypeBookThisTicket, //本场观看，上车
//            QLPaymentContentTypeBookMonthlyTicket //包月观看，上车
            
            if (contentType == QLPaymentContentTypeVIP) {
                [QLUser currentUser].isVIP = @1;
                if (successfulPaymentInfo.paymentSubType == QBPaySubTypeWeChat) {
                    [[QLUser currentUser] addGoldCount:500];
                }
                [[QLUser currentUser] saveAsCurrentUser];
            } else if (contentType == QLPaymentContentTypeCharge) {
                QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].DEPOSIT bk_match:^BOOL(QLPayPoint *obj) {
                    return obj.id.unsignedIntegerValue == contentId;
                }];
                NSUInteger goldCount = payPoint.goldCount.unsignedIntegerValue;
                if (successfulPaymentInfo.paymentSubType == QBPaySubTypeWeChat) {
                    goldCount += 500;
                }
                [[QLUser currentUser] addGoldCount:goldCount];
                [[QLUser currentUser] saveAsCurrentUser];
            } else if (contentType != QLPaymentContentTypeNone) {
                QLPayPoint *payPoint = [[QLPayPoints sharedPayPoints].ANCHOR bk_match:^BOOL(QLPayPoint *obj) {
                    return obj.id.unsignedIntegerValue == contentId;
                }];
                
                if (payPoint) {
                    NSUInteger goldCount = payPoint.goldCount.unsignedIntegerValue;
                    if (successfulPaymentInfo.paymentSubType == QBPaySubTypeWeChat) {
                        goldCount += 500;
                    }
                    [[QLUser currentUser] addGoldCount:goldCount];
                    [[QLUser currentUser] saveAsCurrentUser];
                }
            }
            
            NSDictionary *payTypeStrings = @{@(QLPaymentContentTypeVIP):@"开通VIP类型",
                                             @(QLPaymentContentTypeCharge):@"充值金币",
                                             @(QLPaymentContentTypePrivateCast):@"私播",
                                             @(QLPaymentContentTypeLightThisCast):@"主播本场点亮",
                                             @(QLPaymentContentTypeLightMonthlyCast):@"主播本月点亮",
                                             @(QLPaymentContentTypePrivateShow):@"私秀",
                                             @(QLPaymentContentTypeJumpQueue):@"秀场插队",
                                             @(QLPaymentContentTypeBookThisTicket):@"秀场本场车票",
                                             @(QLPaymentContentTypeBookMonthlyTicket):@"秀场包月车票"};
            
            [[QLAlertManager sharedManager] alertWithTitle:@"激活成功" message:[NSString stringWithFormat:@"激活的支付类型为：%@", payTypeStrings[successfulPaymentInfo.contentType]]];
        } else {
            [[QLAlertManager sharedManager] alertWithTitle:@"激活失败" message:@"未找到支付成功的订单"];
        }
    }];
}
@end
