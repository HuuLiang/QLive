//
//  QLVideoPlayerViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLVideoPlayerViewController.h"
#import "QLVideoPlayer.h"
#import "QLLiveGiftPanel.h"
#import "QLMineVIPViewController.h"
#import "QLLiveGiftPlayer.h"
#import <JHChainableAnimations.h>

@interface QLVideoPlayerViewController ()
@property (nonatomic,retain) UIImageView *placeholderImageView;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic,retain) QLLiveGiftPlayer *giftPlayer;
@end

@implementation QLVideoPlayerViewController
@synthesize closeButton = _closeButton;

QBDefineLazyPropertyInitialization(QLLiveGiftPlayer, giftPlayer)

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _loadingMessage = @"主播正在赶来...";
        _endMessage = @"直播已结束，主播已下线！";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.navigationBarHidden = YES;
    
    @weakify(self);
    _player = [[QLVideoPlayer alloc] initWithURL:self.url];
    _player.eventAction = ^(QLVideoPlayerEvent event, id obj) {
        @strongify(self);
        
        if (event == QLVideoPlayerEventReadyToPlay) {
            [self performSelector:@selector(hidePlaceholderImage) withObject:nil afterDelay:1];
            QBSafelyCallBlock(self.didBeginPlayingAction, self.player.currentSeconds, self);
            return ;
        }
        
        [[QLHUDManager sharedManager] hide];
        if (event == QLVideoPlayerEventFailed) {
            [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"主播暂时不在服务区，请稍后再来~" action:^(id obj) {
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else if (event == QLVideoPlayerEventEndPlaying) {
            @strongify(self);
            if (self.shouldEndPlayingAction && self.shouldEndPlayingAction(self)) {
                self.isPlaying = NO;
                QBSafelyCallBlock(self.didEndPlayingAction, self);
                
                [[QLAlertManager sharedManager] alertWithTitle:@"提示" message:self.endMessage action:^(id obj) {
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            
        }
    };
    [self.view addSubview:_player];
    {
        [_player mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self.view addSubview:self.closeButton];
    {
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationdidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)showPlaceholderImage {
    [[QLHUDManager sharedManager] showLoadingInfo:self.loadingMessage];
    
    if (!_placeholderImageView) {
        NSString *imagePath = [[QLResourceDownloader sharedDownloader] pathForResource:@"live_placeholder_image" ofType:@"jpg"];
        _placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        //    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
        //    _placeholderImageView.clipsToBounds = YES;
        [self.view addSubview:_placeholderImageView];
        {
            [_placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }
    _placeholderImageView.hidden = NO;
}

- (void)hidePlaceholderImage {
    _placeholderImageView.hidden = YES;
    [[QLHUDManager sharedManager] hide];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isPlaying) {
        [self showPlaceholderImage];
    }
    
    if (self.giftPanel) {
        self.giftPanel.goldCount = [QLUser currentUser].goldCount.unsignedIntegerValue;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self play];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIButton *)closeButton {
    if (_closeButton) {
        return _closeButton;
    }
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    return _closeButton;
}

- (void)play {
    NSUInteger playingSecond = self.lastPausedAtSeconds > 0 ? self.lastPausedAtSeconds + self.forwardSecondsOnReplaying : 0;
    [self playAtSecond:playingSecond];
}

- (void)playAtSecond:(NSUInteger)second {
    if (second > 0) {
        [self.player playAtSecond:second];
    } else {
        [self.player play];
    }
    self.isPlaying = YES;
}

- (void)pause {
    self.lastPausedAtSeconds = self.player.currentSeconds;
    [self.player pause];
}

- (void)close {
    if (self.isPlaying) {
        [self pause];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onApplicationWillResignActiveNotification {
    if (self.isPlaying) {
        [self pause];
    }
}

- (void)onApplicationdidBecomeActiveNotification {
    if (self.isPlaying && self.navigationController.visibleViewController == self) {
        [self play];
    }
    
}

- (void)showGiftPanel {
    @weakify(self);
    
    if (_giftPanel) {
        _giftPanel.goldCount = [QLUser currentUser].goldCount.unsignedIntegerValue;
        [_giftPanel showInView:self.view];
    } else {
        _giftPanel = [QLLiveGiftPanel showPanelInView:self.view
                                            withGifts:[QLLiveGift allGifts]
                                            goldCount:[QLUser currentUser].goldCount.unsignedIntegerValue
                                      didSelectAction:^(QLLiveGift *selectedGift, id obj)
                      {
                          @strongify(self);
                          [self sendGift:selectedGift];
                      } chargeAction:^(id obj) {
                          @strongify(self);
                          [self onCharge];
                      }];
    }
}

- (void)hideGiftPanel {
    [_giftPanel hide];
}

- (void)sendGift:(QLLiveGift *)gift {
    if ([QLUser currentUser].goldCount.unsignedIntegerValue < gift.cost) {
        @weakify(self);
        [[QLAlertManager sharedManager] alertWithTitle:@"金币不足" message:@"您的金币不足，是否去充值？" OKButton:@"确定" cancelButton:@"取消" OKAction:^(id obj) {
            @strongify(self);
            [self onCharge];
        } cancelAction:nil];
    } else {
        [QLUser currentUser].goldCount = @([QLUser currentUser].goldCount.unsignedIntegerValue - gift.cost);
        [[QLUser currentUser] saveAsCurrentUser];
        
        self.giftPanel.goldCount = [QLUser currentUser].goldCount.unsignedIntegerValue;
        [self.giftPlayer showGift:gift byUser:[QLUser currentUser] inView:self.player];
    }
}

- (void)onCharge {
    [self pause];
    
    QLMineVIPViewController *mineVIP = [[QLMineVIPViewController alloc] init];
    [self.navigationController pushViewController:mineVIP animated:YES];
}

- (void)launchAppreciatedIconInCenterPoint:(CGPoint)centerPoint {
    NSString *imageName = [NSString stringWithFormat:@"heart%ld", (unsigned long)arc4random_uniform(6)+1];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.center = centerPoint;
    imageView.bounds = CGRectMake(0, 0, 35, 35);
    [self.view insertSubview:imageView aboveSubview:self.player];
    
    
    UIBezierPath *bezierPath = imageView.bezierPathForAnimation;
    
    const CGFloat xRange = self.view.bounds.size.width /4;
    CGPoint finalPoint = CGPointMake(imageView.center.x + xRange/2-arc4random_uniform(xRange+1), self.view.bounds.size.height * 0.4);
    
    const CGFloat pathYLength = imageView.center.y - finalPoint.y;
    CGPoint controlPoint1 = CGPointMake(imageView.center.x + xRange/2-arc4random_uniform(xRange+1), imageView.center.y-pathYLength/3);
    CGPoint controlPoint2 = CGPointMake(imageView.center.x + xRange/2-arc4random_uniform(xRange+1), controlPoint1.y-pathYLength/3);
    
    [bezierPath addCurveToPoint:finalPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    @weakify(imageView);
    imageView.moveOnPath(bezierPath).makeOpacity(0.2).easeInExpo.animateWithCompletion(1.5, ^{
        @strongify(imageView);
        [imageView removeFromSuperview];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
