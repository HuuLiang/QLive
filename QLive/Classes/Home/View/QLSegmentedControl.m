//
//  QLSegmentedControl.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLSegmentedControl.h"
#import "QLSegmentedButton.h"

static const CGFloat kIndicatorImageWidth = 14;
static const CGFloat kIndicatorImageHeight = 6;

@interface QLSegmentedControl ()
@property (nonatomic,retain) NSMutableArray<UIButton *> *buttons;
@property (nonatomic,retain,readonly) UIButton *selectedButton;
@property (nonatomic,retain) UIImageView *indicatorImageView;
@end

@implementation QLSegmentedControl

QBDefineLazyPropertyInitialization(NSMutableArray, buttons)

- (UIImageView *)indicatorImageView {
    if (_indicatorImageView) {
        return _indicatorImageView;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kIndicatorImageWidth, kIndicatorImageHeight), NO, 0);
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(kIndicatorImageWidth/2, 0)];
    [triangle addLineToPoint:CGPointMake(0, kIndicatorImageHeight)];
    [triangle addLineToPoint:CGPointMake(kIndicatorImageWidth, kIndicatorImageHeight)];
    [triangle closePath];
    [triangle fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    _indicatorImageView = [[UIImageView alloc] initWithImage:image];
    _indicatorImageView.hidden = YES;
    [self addSubview:_indicatorImageView];
    return _indicatorImageView;
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.buttons removeAllObjects];
    
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QLSegmentedButton *button = [[QLSegmentedButton alloc] init];
//        UIButton *button = [[UIButton alloc] init];
//        [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.84] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        button.titleLabel.font = kBigFont;
        [button setTitle:obj forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];
        
//        [button aspect_hookSelector:@selector(setSelected:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL selected){
//            UIButton *thisButton = [aspectInfo instance];
//            thisButton.titleLabel.font = thisButton.isSelected ? kExtraBigBoldFont : kBigFont;
//        } error:nil];
    }];
    [self setNeedsLayout];
}

- (UIButton *)selectedButton {
    return [self.buttons bk_match:^BOOL(UIButton *button) {
        return button.selected;
    }];
}

- (NSUInteger)selectedIndex {
    return [self.buttons indexOfObjectPassingTest:^BOOL(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    }];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    UIButton *newSelectedButton = selectedIndex < self.buttons.count ? [self.buttons objectAtIndex:selectedIndex] : nil;
    UIButton *oldSelectedButton = [self selectedButton];
    if (oldSelectedButton != newSelectedButton) {
        oldSelectedButton.selected = NO;
        newSelectedButton.selected = YES;
        
        if (newSelectedButton) {
            self.indicatorImageView.hidden = NO;
            
            if (oldSelectedButton) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.indicatorImageView.frame = [self indicatorFrameForButton:newSelectedButton];
                }];
            } else {
                self.indicatorImageView.frame = [self indicatorFrameForButton:newSelectedButton];
            }
        } else {
            self.indicatorImageView.hidden = YES;
        }
        _indicatorOffset = 0;
    }
    
    QBSafelyCallBlock(self.selectionAction, selectedIndex, self);
}

- (CGRect)indicatorFrameForButton:(UIButton *)button {
    const CGFloat indicatorX = button.frame.origin.x + (button.frame.size.width-kIndicatorImageWidth)/2;
    const CGFloat indicatorY = CGRectGetMaxY(button.frame) - kIndicatorImageHeight;
    return CGRectMake(indicatorX, indicatorY, kIndicatorImageWidth, kIndicatorImageHeight);
}

- (void)setIndicatorOffset:(CGFloat)indicatorOffset {
    _indicatorOffset = indicatorOffset;
    
    UIButton *selectedButton = [self selectedButton];
    CGRect indicatorOriginalFrame = [self indicatorFrameForButton:selectedButton];
    self.indicatorImageView.frame = CGRectOffset(indicatorOriginalFrame, selectedButton.frame.size.width * indicatorOffset, 0);
}

- (void)onButton:(UIButton *)button {
    NSUInteger index = [self.buttons indexOfObject:button];
    if (index != NSNotFound) {
        self.selectedIndex = index;
//        QBSafelyCallBlock(self.selectionAction, index, self);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.buttons.count == 0) {
        return ;
    }
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    const CGFloat fullHeight = CGRectGetHeight(self.bounds);
    const CGFloat buttonWidth = fullWidth / self.buttons.count;
    const CGRect buttonFrame = CGRectMake(0, 0, buttonWidth, fullHeight);
    [self.buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.frame = CGRectOffset(buttonFrame, idx * buttonWidth, 0);
        
        if (button.isSelected) {
            self.indicatorImageView.frame = [self indicatorFrameForButton:button];
        }
    }];
    
    if (self.selectedIndex == NSNotFound) {
        self.selectedIndex = 0;
    }
}

- (UIButton *)buttonAtIndex:(NSUInteger)index {
    return index < self.buttons.count ? self.buttons[index] : nil;
}
@end

static const void* kSegmentedControlAssociatedKey = &kSegmentedControlAssociatedKey;

@implementation UIViewController (QLSegmentedControl)

- (instancetype)initWithSegmentedControl:(QLSegmentedControl *)segmentedControl {
    self = [self init];
    if (self) {
        self.segmentedControl = segmentedControl;
    }
    return self;
}

- (QLSegmentedControl *)segmentedControl {
    return objc_getAssociatedObject(self, kSegmentedControlAssociatedKey);
}

- (void)setSegmentedControl:(QLSegmentedControl *)segmentedControl {
    objc_setAssociatedObject(self, kSegmentedControlAssociatedKey, segmentedControl, OBJC_ASSOCIATION_ASSIGN);
}

@end
