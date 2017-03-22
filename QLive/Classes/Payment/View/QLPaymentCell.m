//
//  QLPaymentCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPaymentCell.h"

@interface QLPaymentCell ()
{
    UIImageView *_imageView;
    UILabel *_textLabel;
    UIButton *_actionButton;
}
@end

@implementation QLPaymentCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(15);
                make.height.equalTo(self).multipliedBy(0.6);
                make.width.equalTo(_imageView.mas_height);
            }];
        }
        
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = kMediumFont;
        _actionButton.forceRoundCorner = YES;
        _actionButton.layer.borderColor = [UIColor redColor].CGColor;
        _actionButton.layer.borderWidth = 0.5;
        [_actionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self addSubview:_actionButton];
        {
            [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self).offset(-15);
                make.size.mas_equalTo(CGSizeMake(80, 35));
            }];
        }
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 5;
        _textLabel.font = kSmallFont;
        [self addSubview:_textLabel];
        {
            [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imageView.mas_right).offset(10);
                make.centerY.equalTo(_imageView);
                make.right.equalTo(_actionButton.mas_left).offset(-5);
            }];
        }
    }
    return self;
}

- (instancetype)initWithUIElement:(QLPaymentUIElement *)UIElement owner:(id)owner {
    self = [self init];
    if (self) {
        self.owner = owner;
        self.UIElement = UIElement;
    }
    return self;
}

- (void)setUIElement:(QLPaymentUIElement *)UIElement {
    _UIElement = UIElement;
    
    if (UIElement.imageURL) {
        [_imageView sd_setImageWithURL:UIElement.imageURL placeholderImage:UIElement.image];
    } else {
        _imageView.image = UIElement.image;
    }
    
    if (_imageView.forceRoundCorner != UIElement.imageIsRound) {
        _imageView.forceRoundCorner = UIElement.imageIsRound;
    }
    _imageView.contentMode = UIElement.imageContentMode;
    
    _textLabel.attributedText = UIElement.attributedText;
    [_actionButton setTitle:UIElement.actionName forState:UIControlStateNormal];
}

- (void)doAction {
    QBSafelyCallBlock(self.UIElement.action, self.owner);
}
@end
