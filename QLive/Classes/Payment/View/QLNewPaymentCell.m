//
//  QLNewPaymentCell.m
//  QLive
//
//  Created by ylz on 2017/4/26.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLNewPaymentCell.h"

@interface QLNewPaymentCell ()
{
    UIImageView *_imageView;
    UIImageView *_headerImageView;
    UILabel *_titleLabel;
    UILabel *_textLabel;
    UIButton *_actionButton;
}

@end

@implementation QLNewPaymentCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.mas_equalTo(self);
                make.height.mas_equalTo(self.mas_width).multipliedBy(1/kBannerCellWidthToHeight);
            }];
        }
        
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.backgroundColor = [UIColor lightGrayColor];
        _headerImageView.layer.borderWidth = 2.5;
        _headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:_headerImageView];
        {
            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(_imageView.mas_bottom).mas_offset(-5);
                make.centerX.mas_equalTo(self);
                make.size.mas_equalTo(CGSizeMake(75, 75));
            }];
        }
        
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = kMediumFont;
        _actionButton.forceRoundCorner = YES;
//        _actionButton.layer.borderColor = [UIColor colorWithHexString:@"#5AC8FA"].CGColor;
//        _actionButton.layer.borderWidth = 1.5;
        [_actionButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#5AC8FA"]] forState:UIControlStateNormal];
        [self addSubview:_actionButton];
        {
            [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.mas_equalTo(self).mas_offset(-13);
                make.size.mas_equalTo(CGSizeMake(160, 32));
            }];
        }
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 5;
        _titleLabel.font = kSmallFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_headerImageView.mas_bottom).mas_offset(5);
                make.left.equalTo(self).offset(10);
                make.right.equalTo(self).offset(-10);
            }];
        }
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 5;
        _textLabel.font = kSmallFont;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        {
            [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(10);
                make.right.equalTo(self).offset(-10);
                make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(10);
                //                make.bottom.mas_equalTo(_actionButton.mas_top).mas_offset(13);
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
        [_headerImageView sd_setImageWithURL:UIElement.imageURL placeholderImage:UIElement.image];
    } else {
        _headerImageView.image = UIElement.image;
    }
    
    if (_headerImageView.forceRoundCorner != UIElement.imageIsRound) {
        _headerImageView.forceRoundCorner = UIElement.imageIsRound;
    }
    _headerImageView.contentMode = UIElement.imageContentMode;
    NSString *string = UIElement.attributedText.string;
    NSRange range = [string rangeOfString:@"|"];
    NSAttributedString *title = [UIElement.attributedText attributedSubstringFromRange:NSMakeRange(0, range.location)];
    _titleLabel.attributedText = title;
    _textLabel.attributedText = [UIElement.attributedText attributedSubstringFromRange:NSMakeRange(range.location+1,string.length-range.location-1)];
    [_actionButton setTitle:UIElement.actionName forState:UIControlStateNormal];
}

- (void)setBannerImage:(UIImage *)bannerImage {
    _bannerImage = bannerImage;
    _imageView.image = bannerImage;
}

- (void)doAction {
    QBSafelyCallBlock(self.UIElement.action, self.owner);
}
@end
