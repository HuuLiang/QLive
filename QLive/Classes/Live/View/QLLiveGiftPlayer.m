//
//  QLLiveGiftPlayer.m
//  QLive
//
//  Created by Sean Yue on 2017/3/16.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveGiftPlayer.h"
#import <FLAnimatedImage.h>

@import AVFoundation;

@interface QLLiveGiftPlayer ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    UIImageView *_giftImageView;
    FLAnimatedImageView *_bigGiftImageView;
}
@property (nonatomic,retain) QLLiveGift *gift;
@property (nonatomic,retain) NSDictionary *sounds;
@property (nonatomic,retain) NSDictionary *bigGiftGifs;
@property (nonatomic,retain) NSDictionary *bigGiftShouldAnimate;

@property (nonatomic,retain) NSDictionary *bigGiftImageCount;
@property (nonatomic,retain) NSDictionary *bigGiftImagePrefix;

@property (nonatomic,retain) AVAudioPlayer *soundPlayer;
@property (nonatomic,retain) NSTimer *autoHideTimer;
@end

@implementation QLLiveGiftPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.forceRoundCorner = YES;
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_avatar"]];
        _imageView.forceRoundCorner = YES;
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.width.equalTo(_imageView.mas_height);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kSmallFont;
        _titleLabel.textColor = [UIColor redColor];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imageView.mas_right).offset(5);
                make.bottom.equalTo(self.mas_centerY);
                make.right.equalTo(self).offset(-5);
            }];
        }
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = kExtraSmallFont;
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#ffff04"];
        [self addSubview:_subtitleLabel];
        {
            [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(3);
            }];
        }
        
        _giftImageView = [[UIImageView alloc] init];
        [self addSubview:_giftImageView];
    }
    return self;
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
    [_autoHideTimer invalidate];
    [_bigGiftImageView removeFromSuperview];
}

- (void)setGift:(QLLiveGift *)gift {
    _gift = gift;
    _titleLabel.text = @"你";
    _subtitleLabel.text = [NSString stringWithFormat:@"送一个%@", gift.name];
    _giftImageView.image = gift.image;
}

- (NSDictionary *)sounds {
    return @{kQLGiftNameApplause:@"applaud",
             kQLGiftNameCar:@"car",
             kQLGiftNameFireworks:@"fireflight",
             kQLGiftNameKiss:@"kiss",
             kQLGiftNameMoney:@"hongbao",
             kQLGiftNameDiamond:@"diamond",
             kQLGiftNameCucumber:@"cucumber",
             kQLGiftNameFlower:@"flower"};
}

- (NSDictionary *)bigGiftGifs {
    return @{kQLGiftNameCar:@"gift_car_anim"};
}

- (NSDictionary *)bigGiftImageCount {
    return @{kQLGiftNameDiamond:@(20),
             kQLGiftNameFireworks:@(13)};
}

- (NSDictionary *)bigGiftImagePrefix {
    return @{kQLGiftNameDiamond:@"gift_heart_",
             kQLGiftNameFireworks:@"fireworks_"};
}

- (NSDictionary *)bigGiftShouldAnimate {
    return @{kQLGiftNameCar:@(YES)};
}

- (void)showGift:(QLLiveGift *)gift byUser:(QLUser *)user inView:(UIView *)view {
    self.gift = gift;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:user.logoUrl] placeholderImage:[UIImage imageNamed:@"mine_avatar"]];
    [_bigGiftImageView removeFromSuperview];
    
    if ([view.subviews containsObject:self]) {
        [self hideAnimated:NO];
    }
    
    [self showInView:view];
}

- (void)showInView:(UIView *)view {
    [self.autoHideTimer invalidate];
    self.autoHideTimer = nil;
    
    NSString *sound = self.sounds[self.gift.name];
    if (sound) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:sound ofType:@"mp3"];
        self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:nil];
        [self.soundPlayer play];
    }
    
    CGRect frame = CGRectMake(0, view.frame.size.height/2, 200, 44);
    self.frame = CGRectOffset(frame, -frame.size.width, 0);
    self.alpha = 0;
    
    _giftImageView.frame = CGRectMake(-44, 0, 44, 44);
    [view addSubview:self];
    
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        self.frame = frame;
    } completion:^(BOOL finished) {
        
        if (finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _giftImageView.frame = CGRectOffset(_giftImageView.frame, frame.size.width, 0);
            }];
        }
        
    }];
    
    CGSize imageSize = CGSizeZero;
    NSString *bigGift = self.bigGiftGifs[self.gift.name];
    if (bigGift) {
        
        if ([view.subviews containsObject:_bigGiftImageView]) {
            [_bigGiftImageView removeFromSuperview];
        }
        
        _bigGiftImageView = [[FLAnimatedImageView alloc] init];
        
        NSString *gifImagePath = [[NSBundle mainBundle] pathForResource:bigGift ofType:@"gif"];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:gifImagePath]];
        _bigGiftImageView.animatedImage = image;
        imageSize = image.size;
        
    } else {
        NSUInteger imageCount = [self.bigGiftImageCount[self.gift.name] unsignedIntegerValue];
        if (imageCount > 0) {
            NSString *imagePrefix = self.bigGiftImagePrefix[self.gift.name];
            
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageCount];
            for (NSUInteger i = 0; i < imageCount; ++i) {
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%ld", imagePrefix, (unsigned long)i+1] ofType:@"png"];
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                
                if (image) {
                    [images addObject:image];
                }
            }
            
            if ([view.subviews containsObject:_bigGiftImageView]) {
                [_bigGiftImageView removeFromSuperview];
            }
            
            _bigGiftImageView = [[FLAnimatedImageView alloc] init];
            _bigGiftImageView.animationImages = images;
            _bigGiftImageView.animationDuration = 2;
            _bigGiftImageView.animationRepeatCount = 2;
            
            imageSize = [(UIImage *)images.firstObject size];
            
        } else {
            [_bigGiftImageView removeFromSuperview];
            _bigGiftImageView = nil;
        }
    }
    
    if (_bigGiftImageView) {
        
        BOOL animated = [self.bigGiftShouldAnimate[self.gift.name] boolValue];
        if (animated) {
            const CGFloat imageWidth = view.bounds.size.width * 0.5;
            const CGFloat imageHeight = imageSize.width == 0 ? 0 : imageWidth * imageSize.height / imageSize.width;
            _bigGiftImageView.frame = CGRectMake(-imageWidth, frame.origin.y-imageHeight, imageWidth, imageHeight);
            [view addSubview:_bigGiftImageView];
            
            [UIView animateWithDuration:5 animations:^{
                _bigGiftImageView.frame = CGRectOffset(_bigGiftImageView.frame, view.bounds.size.width+_bigGiftImageView.frame.size.width, 0);
            } completion:^(BOOL finished) {
                [_bigGiftImageView removeFromSuperview];
            }];
        } else {
            _bigGiftImageView.frame = CGRectMake((view.bounds.size.width-imageSize.width)/2,
                                                 (view.bounds.size.height-imageSize.height)/2,
                                                 imageSize.width, imageSize.height);
            [view addSubview:_bigGiftImageView];
            [_bigGiftImageView startAnimating];
        }
        
    }

    
    self.autoHideTimer = [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
        @strongify(self);
        [self hideAnimated:YES];
    } repeats:NO];
}

- (void)hideAnimated:(BOOL)animated {
    [self.autoHideTimer invalidate];
    self.autoHideTimer = nil;
    
    [_bigGiftImageView removeFromSuperview];
    _bigGiftImageView = nil;
    
    if (!self.superview) {
        return ;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectOffset(self.frame, self.superview.frame.size.width, 0);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
    
}
@end
