//
//  QLPaymentActionSheet.m
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLPaymentActionSheet.h"
#import "QLPaymentActionSheetButton.h"

static const CGFloat kWeChatButtonHeight = 70;
static const CGFloat kAlipayButtonHeight = 50;

@interface QLPaymentActionSheet ()
{
    UIView *_contentView;
    QLPaymentActionSheetButton *_wechatButton;
    QLPaymentActionSheetButton *_alipayButton;
    UILabel *_footerLabel;
}
@property (nonatomic,readonly) CGSize sheetSize;
@end

@implementation QLPaymentActionSheet

- (instancetype)initWithAvailablePayTypes:(NSArray *)payTypes payPoint:(QLPayPoint *)payPoint {
    self = [super init];
    if (self) {
        _availablePayTypes = payTypes;
        
        @weakify(self);
        [self bk_whenTapped:^{
            @strongify(self);
            [self hide];
        }];
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        
        if ([payTypes containsObject:@(QBOrderPayTypeWeChatPay)]) {
            UIImage *wechatImage = [UIImage imageNamed:@"pay_wx_icon"];
            _wechatButton = [[QLPaymentActionSheetButton alloc] initWithTitle:@"微信支付(官方活动指定渠道)"
                                                                     subtitle:@"(充值额外赠送500金币)"
                                                                        image:wechatImage];
            _wechatButton.layer.cornerRadius = 10;
            _wechatButton.layer.masksToBounds = YES;
            [_wechatButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#efefef"]] forState:UIControlStateNormal];
            [_wechatButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
            [_contentView addSubview:_wechatButton];
            {
                [_wechatButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_contentView).offset(15);
                    make.right.equalTo(_contentView).offset(-15);
                    make.top.equalTo(_contentView).offset(20);
                    make.height.mas_equalTo(kWeChatButtonHeight);
                }];
            }
        }
        
        if ([payTypes containsObject:@(QBOrderPayTypeAlipay)]) {
            UIImage *alipayImage = [UIImage imageNamed:@"pay_ali_icon"];
            _alipayButton = [[QLPaymentActionSheetButton alloc] initWithTitle:@"支付宝" subtitle:nil image:alipayImage];
            _alipayButton.layer.cornerRadius = 10;
            _alipayButton.layer.masksToBounds = YES;
            [_alipayButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#efefef"]] forState:UIControlStateNormal];
            [_alipayButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
            [_contentView addSubview:_alipayButton];
            {
                [_alipayButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_contentView).offset(15);
                    make.right.equalTo(_contentView).offset(-15);
                    make.top.equalTo(_wechatButton ? _wechatButton.mas_bottom : _contentView).offset(20);
                    make.height.mas_equalTo(kAlipayButtonHeight);
                }];
            }
        }
        
        _footerLabel = [[UILabel alloc] init];
        _footerLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        _footerLabel.font = kSmallFont;
        _footerLabel.text = @"账户安全保障中";
        [_contentView addSubview:_footerLabel];
        {
            [_footerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentView);
                make.bottom.equalTo(_contentView).offset(-15);
            }];
        }
    }
    return self;
}

- (void)onButton:(id)button {
    QBOrderPayType payType = QBOrderPayTypeNone;
    if (button == _wechatButton) {
        payType = QBOrderPayTypeWeChatPay;
    } else if (button == _alipayButton) {
        payType = QBOrderPayTypeAlipay;
    }
    
    if (payType != QBOrderPayTypeNone) {
        QBSafelyCallBlock(self.selectionAction, payType, self);
    }
    
    [self hide];
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (CGSize)sheetSize {
    CGFloat sheetHeight = 80;
    if ([self.availablePayTypes containsObject:@(QBOrderPayTypeWeChatPay)]) {
        sheetHeight += kWeChatButtonHeight;
    }
    if ([self.availablePayTypes containsObject:@(QBOrderPayTypeAlipay)]) {
        sheetHeight += kAlipayButtonHeight;
    }
    return CGSizeMake(kScreenWidth, sheetHeight);
}

- (void)showInWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if ([window.subviews containsObject:self]) {
        return ;
    }
    
    self.frame = window.bounds;
    _contentView.frame = CGRectMake(0, kScreenHeight, self.sheetSize.width, self.sheetSize.height);
    _contentView.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        _contentView.frame = CGRectOffset(_contentView.frame, 0, -_contentView.frame.size.height);
        _contentView.alpha = 1;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }];
    
}

- (void)hide {
    if (!self.superview) {
        return ;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _contentView.frame = CGRectOffset(_contentView.frame, 0, _contentView.frame.size.height);
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
