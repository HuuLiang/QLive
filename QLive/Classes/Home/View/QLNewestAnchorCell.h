//
//  QLNewestAnchorCell.h
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLNewestAnchorCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSUInteger star;
@property (nonatomic) NSString *typeString;
//@property (nonatomic) UIColor *typeStringColor;
@property (nonatomic) NSUInteger numberOfAudience;

@end
