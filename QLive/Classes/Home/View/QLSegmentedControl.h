//
//  QLSegmentedControl.h
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLSegmentedControl : UIView

@property (nonatomic) NSArray *titles;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic,copy) QLSelectionAction selectionAction;
@property (nonatomic) CGFloat indicatorOffset;  // 0 ~ 1

- (UIButton *)buttonAtIndex:(NSUInteger)index;

@end

@interface UIViewController (QLSegmentedControl)

@property (nonatomic,weak) QLSegmentedControl *segmentedControl;

- (instancetype)initWithSegmentedControl:(QLSegmentedControl *)segmentedControl;

@end
