//
//  QLPaymentCell.h
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLPaymentUIElement.h"

@interface QLPaymentCell : UITableViewCell

@property (nonatomic,retain) QLPaymentUIElement *UIElement;
@property (nonatomic,weak) id owner;

- (instancetype)initWithUIElement:(QLPaymentUIElement *)UIElement owner:(id)owner;

@end
