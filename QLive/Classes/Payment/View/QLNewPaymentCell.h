//
//  QLNewPaymentCell.h
//  QLive
//
//  Created by ylz on 2017/4/26.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLPaymentUIElement.h"

#define kBannerCellWidthToHeight (6.1/3.1)

@interface QLNewPaymentCell : UITableViewCell

@property (nonatomic,retain) QLPaymentUIElement *UIElement;
@property (nonatomic,weak) id owner;
@property (nonatomic) UIImage *bannerImage;

- (instancetype)initWithUIElement:(QLPaymentUIElement *)UIElement owner:(id)owner;

@end
