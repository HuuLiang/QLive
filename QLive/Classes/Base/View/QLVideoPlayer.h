//
//  QLVideoPlayer.h
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QLVideoPlayerEvent) {
    QLVideoPlayerEventReadyToPlay,
    QLVideoPlayerEventFailed,
    QLVideoPlayerEventEndPlaying
};

typedef void (^QLVideoPlayerEventAction)(QLVideoPlayerEvent event, id obj);
//typedef void (^QLVideoPlayerObservingAction)(u_int64_t seconds, id obj);

@interface QLVideoPlayer : UIView

@property (nonatomic,readonly) NSURL *url;
@property (nonatomic,copy) QLVideoPlayerEventAction eventAction;
@property (nonatomic,readonly) u_int64_t currentSeconds;

@property (nonatomic,retain) NSArray *observingTimes;
@property (nonatomic,copy) QBAction observingAction;

- (instancetype)initWithURL:(NSURL *)url;
- (void)play;
- (void)playAtSecond:(u_int64_t)second;
- (void)pause;

@end
