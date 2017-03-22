//
//  QLCommonDefines.h
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#ifndef QLCommonDefines_h
#define QLCommonDefines_h

#import <Foundation/Foundation.h>

#define kExExHugeFont [UIFont systemFontOfSize:MIN(50,roundf(kScreenWidth*0.15))]
#define kExExHugeBoldFont [UIFont boldSystemFontOfSize:MIN(50,roundf(kScreenWidth*0.15))]

#define kExtraHugeFont [UIFont systemFontOfSize:MIN(40,roundf(kScreenWidth*0.12))]
#define kExtraHugeBoldFont [UIFont boldSystemFontOfSize:MIN(40,roundf(kScreenWidth*0.12))]
#define kHugeFont     [UIFont systemFontOfSize:MIN(26,roundf(kScreenWidth*0.075))]
#define kHugeBoldFont [UIFont boldSystemFontOfSize:MIN(26,roundf(kScreenWidth*0.075))]
#define kExtraBigFont [UIFont systemFontOfSize:MIN(20,roundf(kScreenWidth*0.055))]
#define kExtraBigBoldFont [UIFont boldSystemFontOfSize:MIN(20,roundf(kScreenWidth*0.055))]
#define kBigFont  [UIFont systemFontOfSize:MIN(18,roundf(kScreenWidth*0.05))]
#define kBigBoldFont [UIFont boldSystemFontOfSize:MIN(18,roundf(kScreenWidth*0.05))]
#define kMediumFont [UIFont systemFontOfSize:MIN(16, roundf(kScreenWidth*0.045))]
#define kMediumBoldFont [UIFont boldSystemFontOfSize:MIN(16, roundf(kScreenWidth*0.045))]
#define kSmallFont [UIFont systemFontOfSize:MIN(14, roundf(kScreenWidth*0.04))]
#define kExtraSmallFont [UIFont systemFontOfSize:MIN(12, roundf(kScreenWidth*0.035))]
#define kExExSmallFont [UIFont systemFontOfSize:MIN(10, roundf(kScreenWidth*0.03))]
#define kTinyFont [UIFont systemFontOfSize:MIN(8, roundf(kScreenWidth*0.025))]

#define kExtraBigVerticalSpacing roundf(kScreenHeight * 0.016)
#define kBigVerticalSpacing roundf(kScreenHeight * 0.012)
#define kMediumVerticalSpacing roundf(kScreenHeight * 0.008)
#define kSmallVerticalSpacing roundf(kScreenHeight * 0.004)

#define kExtraBigHorizontalSpacing  roundf(kScreenWidth * 0.04)
#define kBigHorizontalSpacing       roundf(kScreenWidth * 0.024)
#define kMediumHorizontalSpacing    roundf(kScreenWidth * 0.016)
#define kSmallHorizontalSpacing     roundf(kScreenWidth * 0.008)

#define kLeftRightContentMarginSpacing kExtraBigHorizontalSpacing
#define kTopBottomContentMarginSpacing kExtraBigVerticalSpacing

typedef void (^QLSelectionAction)(NSUInteger idx, id obj);
typedef void (^QLCompletionHandler)(id obj, NSError *error);

static NSString *const kDefaultDateTimeFormat = @"yyyyMMddHHmmss";

static NSString *const kDebugNotification = @"com.qlive.notification.debug";
static NSString *const kFastFollowingNotification = @"com.qlive.notification.fastfollowing";

#endif /* QLCommonDefines_h */
