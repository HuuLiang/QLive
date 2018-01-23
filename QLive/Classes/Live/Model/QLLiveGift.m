//
//  QLLiveGift.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveGift.h"

NSString *const kQLGiftNameApplause = @"鼓掌";
NSString *const kQLGiftNameFlower = @"玫瑰花";
NSString *const kQLGiftNameKiss = @"飞吻";
NSString *const kQLGiftNameCucumber = @"小黄瓜";
NSString *const kQLGiftNameDiamond = @"求爱钻戒";
NSString *const kQLGiftNameMoney = @"开心红包";
NSString *const kQLGiftNameFireworks = @"礼花";
NSString *const kQLGiftNameCar = @"法拉利";

@implementation QLLiveGift

+ (instancetype)giftWithName:(NSString *)name image:(UIImage *)image cost:(NSUInteger)cost {
    QLLiveGift *gift = [[self alloc] init];
    gift.name = name;
    gift.image = image;
    gift.cost = cost;
    return gift;
}

+ (NSArray<QLLiveGift *> *)allGifts {
    return @[[QLLiveGift giftWithName:kQLGiftNameApplause image:[UIImage imageNamed:@"live_gift_applaud"] cost:30],
             [QLLiveGift giftWithName:kQLGiftNameFlower image:[UIImage imageNamed:@"live_gift_flower"] cost:50],
             [QLLiveGift giftWithName:kQLGiftNameKiss image:[UIImage imageNamed:@"live_gift_kiss"] cost:99],
             [QLLiveGift giftWithName:kQLGiftNameCucumber image:[UIImage imageNamed:@"live_gift_cucumber"] cost:99],
             [QLLiveGift giftWithName:kQLGiftNameDiamond image:[UIImage imageNamed:@"live_gift_diamond"] cost:199],
             [QLLiveGift giftWithName:kQLGiftNameMoney image:[UIImage imageNamed:@"live_gift_money"] cost:288],
             [QLLiveGift giftWithName:kQLGiftNameFireworks image:[UIImage imageNamed:@"live_gift_fireworks"] cost:888],
             [QLLiveGift giftWithName:kQLGiftNameCar image:[UIImage imageNamed:@"live_gift_car"] cost:999]];
}

@end
