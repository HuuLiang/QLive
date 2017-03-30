//
//  QLConfiguration.h
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#ifndef QLConfiguration_h
#define QLConfiguration_h

#import "QLChannelNo.h"

#define kQLChannelNo [QLChannelNo defaultChannelNo].channelNo

static NSString *const kQLRESTBaseURL = @"http://sfs.dswtg.com";
static NSString *const kQLRESTAppId = @"QUBA_2028";
static const NSUInteger kQLPaymentPv = 209;
static const NSUInteger kQLContentPv = 100;
//static NSString *const kQLChannelNo = @"IOS_L00000001";
static NSString *const kQLPaymentURLScheme = @"comhoneylive2paymenturlscheme";
static NSString *const kPackageCertificate = @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd.";

static NSString *const kQLAvatarImage = @"qlive_avatar.jpg";
static NSString *const kQLResourceZipFile = @"http://oiiw1v71t.bkt.clouddn.com/live/zy/Resources.zip";

#endif /* QLConfiguration_h */
