//
//  QLVideoPlayerViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/18.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"

@class QLLiveGiftPanel;
@class QLVideoPlayer;

typedef BOOL (^QLVideoPlayerShouldEndPlayingAction)(id obj);
typedef void (^QLVideoPlayerDidBeginPlayingAction)(u_int64_t beginAtSecond, id obj);

@interface QLVideoPlayerViewController : QLBaseViewController

@property (nonatomic,readonly) NSURL *url;

@property (nonatomic) u_int64_t lastPausedAtSeconds;
@property (nonatomic) NSUInteger forwardSecondsOnReplaying;
@property (nonatomic,copy) QLVideoPlayerDidBeginPlayingAction didBeginPlayingAction;
@property (nonatomic,copy) QBAction didEndPlayingAction;
@property (nonatomic,copy) QLVideoPlayerShouldEndPlayingAction shouldEndPlayingAction;
@property (nonatomic) BOOL shouldLoopPlayback;

@property (nonatomic,retain,readonly) QLVideoPlayer *player;
@property (nonatomic,retain,readonly) UIButton *closeButton;
@property (nonatomic,retain,readonly) QLLiveGiftPanel *giftPanel;

@property (nonatomic) NSString *loadingMessage;
@property (nonatomic) NSString *endMessage;

- (instancetype)init __attribute__((unavailable("Use -initWithURL instead!")));
- (instancetype)initWithURL:(NSURL *)url;

- (void)play;
- (void)playAtSecond:(NSUInteger)second;
- (void)pause;
- (void)close;

- (void)showGiftPanel;
- (void)hideGiftPanel;

- (void)launchAppreciatedIconInCenterPoint:(CGPoint)centerPoint;

@end
