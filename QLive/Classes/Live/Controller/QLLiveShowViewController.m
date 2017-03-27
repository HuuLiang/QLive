//
//  QLLiveShowViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveShowViewController.h"
#import "QLLiveGiftPanel.h"
#import "QLVideoPlayer.h"
#import "QLLiveShowTicketExportView.h"
#import "QLPaymentUIElement.h"
#import "QLPaymentViewController.h"
#import "QLLivePrivateShowContactViewController.h"

@interface QLLiveShowViewController ()
{
    UIButton *_giftButton;
    UIButton *_likeButton;
    UIImageView *_headerImageView;
    UILabel *_ticketLabel;
    UIButton *_buyTicketButton;
}
@property (nonatomic) NSUInteger remainingTickets;
@end

@implementation QLLiveShowViewController

- (instancetype)initWithLiveShow:(QLLiveShow *)liveShow {
    
//    NSString *urlString = [liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate] ? liveShow.anchorUrl2 : liveShow.anchorUrl;
    NSString *urlString = [liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow] ? liveShow.anchorUrl2 : liveShow.anchorUrl;
    self = [super initWithURL:[NSURL URLWithString:urlString]];
    if (self) {
        _liveShow = liveShow;
        self.forwardSecondsOnReplaying = 30;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow]
        || [self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
        self.loadingMessage = @"主播正在准备大秀中...";
        self.endMessage = @"大秀已结束，主播已下线！";
    } else if ([self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
        self.endMessage = @"主播已开车，您已被踢出房间";
    }
    
    _giftButton = [[UIButton alloc] init];
    [_giftButton setImage:[UIImage imageNamed:@"live_gift"] forState:UIControlStateNormal];
    [_giftButton addTarget:self action:@selector(showGiftPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_giftButton];
    {
        [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }];
    }
    
    _likeButton = [[UIButton alloc] init];
    [_likeButton setImage:[UIImage imageNamed:@"live_like"] forState:UIControlStateNormal];
    [_likeButton addTarget:self action:@selector(onLike) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_likeButton];
    {
        [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }];
    }
    
    @weakify(self);
    if ([self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
        UIImage *headerImage = [UIImage imageNamed:@"live_show_header"];
        const CGFloat headerImageHeight = 60;
        const CGFloat headerImageWidth = headerImageHeight * headerImage.size.width / headerImage.size.height;
        _headerImageView = [[UIImageView alloc] initWithImage:headerImage];
        [self.view addSubview:_headerImageView];
        {
            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).offset(10);
                make.top.equalTo(self.view).offset(10);
                make.height.mas_equalTo(headerImageHeight);
                make.width.mas_equalTo(headerImageWidth);
            }];
        }
        
        _ticketLabel = [[UILabel alloc] init];
        _ticketLabel.textColor = [QLTheme defaultTheme].themeColor;
        _ticketLabel.font = kBigBoldFont;
        _ticketLabel.textAlignment = NSTextAlignmentRight;
        if ([self hasBoughtTicket]) {
            _ticketLabel.text = @"已买票";
        } else {
            _ticketLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.liveShow.ticketInfos.count];
        }
        
        [_headerImageView addSubview:_ticketLabel];
        {
            [_ticketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_headerImageView).offset(-15);
                make.centerY.equalTo(_headerImageView);
                make.left.equalTo(_headerImageView).offset(headerImageWidth*0.25);
            }];
        }
        
        NSMutableArray *observingTimes = [NSMutableArray array];
        [self.liveShow.ticketInfos enumerateObjectsUsingBlock:^(QLLiveShowTicketInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [observingTimes addObject:@(obj.popTime.unsignedIntegerValue)];
        }];
        self.player.observingTimes = observingTimes;
        self.player.observingAction = ^(id obj) {
            @strongify(self);
            u_int64_t currentSeconds = [obj currentSeconds];
            [self showTicketAtSecond:currentSeconds];
            [self updateRemainingTicketsWhenPlayingAtSecond:(NSUInteger)currentSeconds];
        };
    }
    
    _buyTicketButton = [[UIButton alloc] init];
    if ([self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic] && ![self hasBoughtTicket]) {
        [_buyTicketButton setBackgroundImage:[UIImage imageNamed:@"live_show_buy_ticket"] forState:UIControlStateNormal];
        [_buyTicketButton addTarget:self action:@selector(onBuyTicket) forControlEvents:UIControlEventTouchUpInside];
    } else if (!self.liveShow.hasReadPrivateInfos.boolValue) {
        [_buyTicketButton setBackgroundImage:[UIImage imageNamed:@"live_show_private"] forState:UIControlStateNormal];
        [_buyTicketButton addTarget:self action:@selector(onPrivateShow) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view addSubview:_buyTicketButton];
    {
        [_buyTicketButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-15);
            make.width.equalTo(self.view).dividedBy(6);
            make.height.equalTo(_buyTicketButton.mas_width);
        }];
    }
    
    [self.closeButton setImage:[UIImage imageNamed:@"yellow_close"] forState:UIControlStateNormal];
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (_headerImageView) {
            make.centerY.equalTo(_headerImageView);
        } else {
            make.top.equalTo(self.view);
        }
        
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    self.shouldEndPlayingAction = ^BOOL(id obj) {
        @strongify(self);
        
        if ([self.liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
            if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
                || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket])
            {
                self.liveShow.anchorType = kQLLiveShowAnchorTypeBigShow;
                self.liveShow.lastCastSeconds = nil;
                [self.liveShow save];
                
                NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
                if (viewControllers.lastObject == self) {
                    [viewControllers removeLastObject];
                }
                
                [viewControllers addObject:[[QLLiveShowViewController alloc] initWithLiveShow:self.liveShow]];
                [self.navigationController setViewControllers:viewControllers animated:NO];
//                [self.navigationController popViewControllerAnimated:YES];
//                
//                QLLiveShowViewController *liveShowVC = [[QLLiveShowViewController alloc] initWithLiveShow:self.liveShow];
//                [self.navigationController pushViewController:liveShowVC animated:YES];
                
                return NO;
            } else {
                return YES;
            }
            
        } else {
            return YES;
        }
        
    };
    self.didEndPlayingAction = ^(id obj) {
        @strongify(self);
        [self.liveShow removeFromPersistence];
    };
    
    self.didBeginPlayingAction = ^(u_int64_t beginAtSecond, id obj) {
        @strongify(self);
        [self updateRemainingTicketsWhenPlayingAtSecond:(NSUInteger)beginAtSecond];
    };
}

- (void)play {
    self.lastPausedAtSeconds = self.liveShow.lastCastSeconds.unsignedIntegerValue;
    [super play];
}

//- (void)playAtSecond:(NSUInteger)second {
//    [super playAtSecond:second];
//    
//    [self updateRemainingTicketsWhenPlayingAtSecond:second];
//}

- (void)pause {
    [super pause];
    
    self.liveShow.lastCastSeconds = @(self.lastPausedAtSeconds);
    [self.liveShow save];
}

- (void)onLike {
    [self launchAppreciatedIconInCenterPoint:_likeButton.center];
}

- (void)setRemainingTickets:(NSUInteger)remainingTickets {
    _remainingTickets = remainingTickets;
    
    if (![self hasBoughtTicket]) {
        _ticketLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)remainingTickets];
    }
}

- (BOOL)hasBoughtTicket {
    return [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket] || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket];
}

- (void)updateRemainingTicketsWhenPlayingAtSecond:(NSUInteger)second {
    __block NSUInteger remainingTickets = 0;
    NSMutableArray *deleteTickets = [NSMutableArray array];
    [self.liveShow.ticketInfos enumerateObjectsUsingBlock:^(QLLiveShowTicketInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.popTime.unsignedIntegerValue > second) {
            ++remainingTickets;
        } else {
            [deleteTickets addObject:obj];
        }
    }];
    
    self.remainingTickets = remainingTickets;
    
    [QLLiveShowTicketInfo removeFromPersistenceWithObjects:deleteTickets];
    self.liveShow.ticketCounts = @(kQLLiveShowNumberOfTickers - remainingTickets);
    
    NSMutableArray *remainingTicketInfos = self.liveShow.ticketInfos.mutableCopy;
    [remainingTicketInfos removeObjectsInArray:deleteTickets];
    self.liveShow.ticketInfos = remainingTicketInfos;
    [self.liveShow save];
}

- (void)showTicketAtSecond:(u_int64_t)second {
    QLLiveShowTicketInfo *ticketInfo = [self.liveShow ticketInfoAtSecond:second];
    [QLLiveShowTicketExportView showTicketExportInView:self.player withName:ticketInfo.name fee:ticketInfo.fee.unsignedIntegerValue];
}

- (void)onBuyTicket {
    if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
        || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]) {
        return ;
    }
    
    [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self withContentType:QLPaymentContentTypeBookThisTicket userInfo:@{kQLPaymentLiveShowUserInfo:self.liveShow} completion:^(BOOL success, QLPayPoint *payPoint) {
        if (success) {
            [self onSuccessPaidWithPayPoint:payPoint];
        }
    }];
}

- (void)onSuccessPaidWithPayPoint:(QLPayPoint *)payPoint {

    if ([payPoint.name isEqualToString:kQLAnchorPayPointName_BookThisTicket]
        || [payPoint.name isEqualToString:kQLAnchorPayPointName_BookMonthlyTicket]) {
        
        [QLLiveShowTicketExportView showTicketExportInView:self.player withName:[QLUser currentUser].name fee:payPoint.fee.unsignedIntegerValue];
        _ticketLabel.text = @"已买票";
        
        [_buyTicketButton setBackgroundImage:[UIImage imageNamed:@"live_show_private"] forState:UIControlStateNormal];
        [_buyTicketButton removeTarget:self action:@selector(onBuyTicket) forControlEvents:UIControlEventTouchUpInside];
        [_buyTicketButton addTarget:self action:@selector(onPrivateShow) forControlEvents:UIControlEventTouchUpInside];
    } else if ([payPoint.name isEqualToString:kQLAnchorPayPointName_PrivateShow]) {
        [self readPrivateInfos];
    }
    
}

- (void)readPrivateInfos {
    if (self.liveShow.hasReadPrivateInfos.boolValue) {
        return ;
    }
    
    self.liveShow.hasReadPrivateInfos = @(YES);
    [self.liveShow save];
    
    [_buyTicketButton removeFromSuperview];
    _buyTicketButton = nil;
    
    [QLLivePrivateShowContactViewController showContactInViewController:self withLiveShow:self.liveShow];
}

- (void)onPrivateShow {
    if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.liveShow.liveId.integerValue) contentType:QLPaymentContentTypePrivateShow]) {
        [self readPrivateInfos];
        return ;
    }
    
    [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self withContentType:QLPaymentContentTypePrivateShow userInfo:@{kQLPaymentLiveShowUserInfo:self.liveShow} completion:^(BOOL success, QLPayPoint *payPoint) {
        if (success) {
            [self onSuccessPaidWithPayPoint:payPoint];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
