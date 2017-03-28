//
//  QLLiveCastViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveCastViewController.h"
#import "QLLivePrivateShowContactViewController.h"
//#import "QLLiveGiftPanel.h"
#import "QLLiveSharePanel.h"
#import "QLLiveChatPanel.h"
//#import "QLLiveGiftPlayer.h"
#import "QLLiveAvatarPanel.h"
//#import <JHChainableAnimations.h>

#import "QLPaymentViewController.h"
#import "QLPaymentActionSheet.h"
//#import "QLMineVIPViewController.h"

@interface QLLiveCastViewController ()
{
    UIButton *_avatarButton;
    UIButton *_privateShowButton;
    UIButton *_giftButton;
    UIButton *_chatButton;
    UIButton *_shareButton;
    UIButton *_likeButton;
    
    //Unlighted case
    UILabel *_unlightedLabel;
    UIButton *_unlightedButton;
}
@property (nonatomic,weak) QLLiveAvatarPanel *avatarPanel;
//@property (nonatomic,weak) QLLiveGiftPanel *giftPanel;
@property (nonatomic,weak) QLLiveChatPanel *chatPanel;
@property (nonatomic,weak) QLLiveSharePanel *sharePanel;

//@property (nonatomic,retain) QLLiveGiftPlayer *giftPlayer;
@property (nonatomic) BOOL isLighted;
@end

@implementation QLLiveCastViewController

- (instancetype)initWithAnchor:(QLAnchor *)anchor {
    NSURL *anchorUrl;
    BOOL isLighted = NO;
    NSUInteger forwardSecondsOnReplaying = 0;
    
    if ([anchor.anchorType isEqualToString:kQLAnchorTypeShow]) {
        if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(anchor.userId.integerValue) contentType:QLPaymentContentTypeLightThisCast]
            || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(anchor.userId.integerValue) contentType:QLPaymentContentTypeLightMonthlyCast]) {
            anchorUrl = [NSURL URLWithString:anchor.anchorUrl2];
            forwardSecondsOnReplaying = 60;
            isLighted = YES;
        } else {
            anchorUrl = [NSURL URLWithString:anchor.anchorUrl];
            forwardSecondsOnReplaying = 10;
        }
    } else {
        anchorUrl = [NSURL URLWithString:anchor.anchorUrl];
        forwardSecondsOnReplaying = 60;
        isLighted = YES;
    }
    
    self = [super initWithURL:anchorUrl];
    if (self) {
        self.isLighted = isLighted;
        self.forwardSecondsOnReplaying = forwardSecondsOnReplaying;
        
        if (!self.isLighted && anchor.lastCastSeconds.unsignedIntegerValue > 300) {
            anchor.lastCastSeconds = nil;
        }
        
        if (!anchor.numberOfFollowing) {
            anchor.numberOfFollowing = @(100+arc4random_uniform(2000));
        }
        
        if (!anchor.numberOfFollowed) {
            anchor.numberOfFollowed = @(1000+arc4random_uniform(9000));
        }
        
        if (!anchor.numberOfRichness) {
            anchor.numberOfRichness = @(anchor.numberOfFollowed.unsignedIntegerValue/2 + arc4random_uniform((uint32_t)(10000-anchor.numberOfFollowed.unsignedIntegerValue/2)));
        }
        
        if (!anchor.numberOfCharm) {
            anchor.numberOfCharm = @(anchor.numberOfFollowed.unsignedIntegerValue/2 + arc4random_uniform((uint32_t)(10000-anchor.numberOfFollowed.unsignedIntegerValue/2)));
        }
        
        _anchor = anchor;
        [_anchor save];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    self.shouldEndPlayingAction = ^BOOL(id obj) {
        return YES;
    };
    self.didEndPlayingAction = ^(id obj) {
        @strongify(self);
        [self.anchor removeFromPersistence];
    };
    
    if ([self.anchor.anchorType isEqualToString:kQLAnchorTypeShow]) {
        [self.closeButton setImage:[UIImage imageNamed:@"yellow_close"] forState:UIControlStateNormal];
    }
    
    if (self.isLighted) {
        if (!self.anchor.hasReadPrivateInfos.boolValue) {
            _privateShowButton = [[UIButton alloc] init];
            [_privateShowButton setBackgroundImage:[UIImage imageNamed:@"private_show"] forState:UIControlStateNormal];
            [_privateShowButton addTarget:self action:@selector(onPrivateShow) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_privateShowButton];
            {
                [_privateShowButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.bottom.equalTo(self.view).offset(-15);
                    make.width.equalTo(self.view).dividedBy(6);
                    make.height.equalTo(_privateShowButton.mas_width);
                }];
            }
        }
        
        if ([self.anchor.anchorType isEqualToString:kQLAnchorTypeLive]) {
            _avatarButton = [[UIButton alloc] init];
            [_avatarButton addTarget:self action:@selector(onAvatar) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_avatarButton];
            {
                [_avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.equalTo(self.view);
                    make.size.mas_equalTo(CGSizeMake(100, 50));
                }];
            }
            
            _giftButton = [[UIButton alloc] init];
            //        _giftButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            [_giftButton addTarget:self action:@selector(onGift) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_giftButton];
            {
                [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.bottom.equalTo(self.view);
                    make.size.mas_equalTo(CGSizeMake(52, 60));
                }];
            }
            
            _chatButton = [[UIButton alloc] init];
            //        _chatButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
            [_chatButton addTarget:self action:@selector(onChat) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_chatButton];
            {
                [_chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_giftButton.mas_right);
                    make.bottom.equalTo(self.view);
                    make.size.equalTo(_giftButton);
                }];
            }
            
            _shareButton = [[UIButton alloc] init];
            //        _shareButton.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
            [_shareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_shareButton];
            {
                [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_chatButton.mas_right);
                    make.bottom.equalTo(self.view);
                    make.size.equalTo(_chatButton);
                }];
            }
            
            _likeButton = [[UIButton alloc] init];
            //            _likeButton.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
            [_likeButton addTarget:self action:@selector(onLike) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_likeButton];
            {
                [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.equalTo(_giftButton);
                    make.right.bottom.equalTo(self.view);
                }];
            }
        }
    } else {
        _unlightedLabel = [[UILabel alloc] init];
        _unlightedLabel.text = @"T_T对不起哟，该主播设置了点亮上车可见";
        _unlightedLabel.textColor = [UIColor colorWithHexString:@"#fff204"];
        _unlightedLabel.font = kBigBoldFont;
        [self.view addSubview:_unlightedLabel];
        {
            [_unlightedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
            }];
        }
        
        _unlightedButton = [[UIButton alloc] init];
        _unlightedButton.titleLabel.font = kBigBoldFont;
        _unlightedButton.layer.cornerRadius = 8;
        _unlightedButton.layer.borderColor = [UIColor colorWithHexString:@"#504100"].CGColor;
        _unlightedButton.layer.borderWidth = 0.5;
        [_unlightedButton setTitle:@"我要看" forState:UIControlStateNormal];
        [_unlightedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_unlightedButton addTarget:self action:@selector(onLight) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_unlightedButton];
        {
            [_unlightedButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(_unlightedLabel.mas_bottom).offset(10);
                make.size.mas_equalTo(CGSizeMake(80, 44));
            }];
        }
    }
}

- (void)play {
    self.lastPausedAtSeconds = self.anchor.lastCastSeconds.unsignedIntegerValue;
    [super play];
}

- (void)pause {
    [super pause];
    
    self.anchor.lastCastSeconds = @(self.lastPausedAtSeconds);
    [self.anchor save];
}

- (void)onAvatar {
    @weakify(self);
    [self dismissAllPanels];
    
    self.avatarPanel = [QLLiveAvatarPanel showPanelInView:self.view withAnchor:self.anchor buttonAction:^(QLLiveAvatarPanel *panel) {
        [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:2 complete:^{
            @strongify(self);
            if (self.anchor.followingTime) {
                self.anchor.followingTime = nil;
                [self.anchor save];
            } else {
                self.anchor.followingTime = [QLUtil currentDateTimeString];
                [self.anchor save];
            }
            
            panel.anchor = self.anchor;
        }];
    }];
}

- (void)dismissAllPanels {
    [self.avatarPanel hide];
    [self.chatPanel hide];
    [self.sharePanel hide];
    
    [self hideGiftPanel];
}

- (void)readPrivateInfos {
    if (self.anchor.hasReadPrivateInfos.boolValue) {
        return ;
    }

    self.anchor.hasReadPrivateInfos = @(YES);
    [self.anchor save];
    
    [_privateShowButton removeFromSuperview];
    _privateShowButton = nil;
    
    [QLLivePrivateShowContactViewController showContactInViewController:self withAnchor:self.anchor];
}

- (void)onPrivateShow {
    if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(self.anchor.userId.integerValue) contentType:QLPaymentContentTypePrivateCast]) {
        [self readPrivateInfos];
        return ;
    }
    
    @weakify(self);
    [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self withContentType:QLPaymentContentTypePrivateCast userInfo:@{kQLPaymentLiveCastAnchorUserInfo:self.anchor} completion:^(BOOL success, QLPayPoint *payPoint) {
        @strongify(self);
        if (success) {
            [self readPrivateInfos];
        }
    }];
}

- (void)onGift {
    [self dismissAllPanels];
    [self showGiftPanel];
}

- (void)onLight {
    
    @weakify(self);
    [[QLPaymentManager sharedManager] showPaymnetViewControllerInViewController:self withContentType:QLPaymentContentTypeLightThisCast userInfo:@{kQLPaymentLiveCastAnchorUserInfo:self.anchor} completion:^(BOOL success, QLPayPoint *payPoint) {
        @strongify(self);
        
        if (success) {
            [self pause];
            
            self.anchor.lastCastSeconds = nil;
            [self.anchor save];
            
            NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
            if (viewControllers.lastObject == self) {
                [viewControllers removeLastObject];
            }
            
            [viewControllers addObject:[[QLLiveCastViewController alloc] initWithAnchor:self.anchor]];
            [self.navigationController setViewControllers:viewControllers animated:NO];
        }
        
    }];
}

- (void)onChat {
    [self dismissAllPanels];
    
    self.chatPanel = [QLLiveChatPanel showPanelInView:self.view withSendAction:^(id obj) {
        QLLiveChatPanel *thisPanel = obj;
        [[QLHUDManager sharedManager] showLoadingInfo:@"发送中..." withDuration:2 isSucceeded:YES complete:^NSString *{
            [thisPanel hide];
            return @"发送成功";
        }];
    }];
}

- (void)onShare {
    [self dismissAllPanels];
    
    self.sharePanel = [QLLiveSharePanel showPanelInView:self.view withShareAction:^(id obj) {
        [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:3 complete:^{
            [[QLAlertManager sharedManager] alertWithTitle:@"提示" message:@"请在手机设置打开应用权限"];
        }];
    }];
    
}

- (void)onLike {
    [self launchAppreciatedIconInCenterPoint:_likeButton.center];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
