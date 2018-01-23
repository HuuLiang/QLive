//
//  QLLiveGift.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLLiveGift : NSObject

@property (nonatomic) NSNumber *giftId;
@property (nonatomic) NSString *name;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic) NSUInteger cost;

+ (instancetype)giftWithName:(NSString *)name image:(UIImage *)image cost:(NSUInteger)cost;
+ (NSArray<QLLiveGift *> *)allGifts;

@end

extern NSString *const kQLGiftNameApplause;
extern NSString *const kQLGiftNameFlower;
extern NSString *const kQLGiftNameKiss;
extern NSString *const kQLGiftNameCucumber;
extern NSString *const kQLGiftNameDiamond;
extern NSString *const kQLGiftNameMoney;
extern NSString *const kQLGiftNameFireworks;
extern NSString *const kQLGiftNameCar;
