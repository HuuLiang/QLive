//
//  QLVideoPlayer.m
//  QLive
//
//  Created by Sean Yue on 2017/3/9.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLVideoPlayer.h"

@import AVFoundation;

@interface QLVideoPlayer ()
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic,retain) AVPlayer *player;
@property (nonatomic) u_int64_t startSeconds;
@property (nonatomic,retain) dispatch_queue_t observingQueue;
@property (nonatomic,retain) id timeObserver;
@end

@implementation QLVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioHardwareRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEndPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)play {
    [self playAtSecond:0];
}

- (void)playAtSecond:(u_int64_t)second {
    QBLog(@"Start to play video: %@", self.url.absoluteString);
    _startSeconds = second;
    
    if (!self.player) {
        AVAsset *asset = [AVAsset assetWithURL:self.url];
        long length = (float)asset.duration.value / (float)asset.duration.timescale;
        if (length == 0) {
            QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventFailed, self);
            return ;
        }
        
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
        [self.currentPlayerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:0 context:nil];
        
        self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
        
        if (self.observingTimes.count > 0) {
            [self observePlayingTimes:self.observingTimes];
        }
    }
    
    if (second > 0) {
        CMTime targetTime = CMTimeMakeWithSeconds(second, self.currentPlayerItem.asset.duration.timescale);
        
        if (CMTIME_COMPARE_INLINE(targetTime, >=, self.currentPlayerItem.asset.duration)) {
            QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventEndPlaying, self);
            return ;
        }
        
        @weakify(self);
        //        [self.player seekToTime:targetTime completionHandler:^(BOOL finished) {
        //            @strongify(self);
        //            if (finished) {
        //                [self.player play];
        //                QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventReadyToPlay, self);
        //            } else {
        //                QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventFailed, self);
        //            }
        //
        //        }];
        [self.player seekToTime:targetTime toleranceBefore:CMTimeMake(2, self.currentPlayerItem.asset.duration.timescale) toleranceAfter:CMTimeMake(2, self.currentPlayerItem.asset.duration.timescale) completionHandler:^(BOOL finished) {
            @strongify(self);
            if (finished) {
                [self.player play];
                QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventReadyToPlay, self);
            } else {
                QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventFailed, self);
            }
        }];
    } else {
        [self.player play];
    }
}

- (void)pause {
    [self.player pause];
}

- (u_int64_t)currentSeconds {
    return CMTimeGetSeconds(self.currentPlayerItem.currentTime);
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
    
    [self.currentPlayerItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.currentPlayerItem && [keyPath isEqualToString:NSStringFromSelector(@selector(status))]) {
        switch (self.currentPlayerItem.status) {
            case AVPlayerItemStatusReadyToPlay:
                if (_startSeconds == 0) {
                    QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventReadyToPlay, self);
                }
                
                break;
                
            default:
                QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventFailed, self);
                break;
        }
    }
}

- (void)onEndPlaying {
    if ([NSThread currentThread].isMainThread) {
        QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventEndPlaying, self);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            QBSafelyCallBlock(self.eventAction, QLVideoPlayerEventEndPlaying, self);
        });
    }
    
}

- (void)audioHardwareRouteChanged:(NSNotification *)notification {
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // if we're here, the player has been stopped, so play again!
        [self.player play];
    }
}

- (dispatch_queue_t)observingQueue {
    if (_observingQueue) {
        return _observingQueue;
    }
    
    _observingQueue = dispatch_queue_create("com.qlive.queue.videoplayer.observing", nil);
    return _observingQueue;
}

- (void)observePlayingTimes:(NSArray *)observingTimes {
    @weakify(self);
    
    NSMutableArray *cmTimes = [NSMutableArray array];
    [observingTimes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CMTime time = CMTimeMakeWithSeconds([obj unsignedIntegerValue], self.currentPlayerItem.asset.duration.timescale);
        if (CMTIME_IS_NUMERIC(time)) {
            [cmTimes addObject:[NSValue valueWithCMTime:time]];
        }
    }];
    
    if (cmTimes.count == 0) {
        return ;
    }
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
    
    self.timeObserver = [self.player addBoundaryTimeObserverForTimes:cmTimes queue:self.observingQueue usingBlock:^{
        @strongify(self);
        
        if (self.observingAction) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.observingAction(self);
            });
        }
    }];
}
@end
