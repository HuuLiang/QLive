//
//  QLLiveShowTicketExportView.m
//  QLive
//
//  Created by Sean Yue on 2017/3/21.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveShowTicketExportView.h"

@interface QLLiveShowTicketExportView ()
{
    UIImageView *_exportImageView;
    UIImageView *_exportBgImageView;
    UIImageView *_ticketBgImageView;
    
    UIImageView *_successImageView;
    UILabel *_successLabel;
    UILabel *_ticketNoLabel;
    UILabel *_feeLabel;
    UILabel *_nameLabel;
}
@end

@implementation QLLiveShowTicketExportView

+ (instancetype)showTicketExportInView:(UIView *)view withName:(NSString *)name fee:(NSUInteger)fee {
    if (name.length == 0 || fee == 0) {
        return nil;
    }
    
    QLLiveShowTicketExportView *selfView = [[self alloc] init];
    selfView.name = name;
    selfView.fee = fee;
    [selfView showInView:view];
    return selfView;
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _exportImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_show_export"]];
        [self addSubview:_exportImageView];
        {
            [_exportImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self);
                make.height.equalTo(_exportImageView.mas_width).multipliedBy(_exportImageView.image.size.height/_exportImageView.image.size.width);
            }];
        }
        
        _exportBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_show_export_background"]];
        [self addSubview:_exportBgImageView];
        {
            [_exportBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_exportImageView);
            }];
        }
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"live_show_ticket" ofType:@"png"];
        _ticketBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self addSubview:_ticketBgImageView];
        {
            [_ticketBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_exportImageView.mas_centerY);
                make.centerX.equalTo(self);
                make.width.equalTo(self).multipliedBy(0.9);
                make.height.equalTo(_ticketBgImageView.mas_width).multipliedBy(_ticketBgImageView.image.size.height/_ticketBgImageView.image.size.width);
            }];
        }
        
        UIView *contentView = _ticketBgImageView;
        
        _successImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_show_export_success"]];
        [contentView addSubview:_successImageView];
        {
            [_successImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(contentView);
                make.top.equalTo(contentView).offset(15);
                make.size.mas_equalTo(CGSizeMake(37.5, 37.5));
            }];
        }
        
        _successLabel = [[UILabel alloc] init];
        _successLabel.textColor = [UIColor colorWithHexString:@"#36c55b"];
        _successLabel.text = @"出票成功";
        _successLabel.font = kBigFont;
        [contentView addSubview:_successLabel];
        {
            [_successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(contentView);
                make.top.equalTo(_successImageView.mas_bottom).offset(5);
            }];
        }
        
        _ticketNoLabel = [[UILabel alloc] init];
        _ticketNoLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _ticketNoLabel.font = kMediumFont;
        _ticketNoLabel.text = [self randomTicketNo];
        [contentView addSubview:_ticketNoLabel];
        {
            [_ticketNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(contentView.mas_centerX).dividedBy(2);
                make.top.equalTo(_successLabel.mas_bottom).offset(10);
            }];
        }
        
        _feeLabel = [[UILabel alloc] init];
        _feeLabel.textColor = _ticketNoLabel.textColor;
        _feeLabel.font = _ticketNoLabel.font;
        [contentView addSubview:_feeLabel];
        {
            [_feeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_ticketNoLabel);
                make.top.equalTo(_ticketNoLabel.mas_bottom).offset(10);
            }];
        }
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = _ticketNoLabel.font;
        _nameLabel.textColor = _ticketNoLabel.textColor;
        [contentView addSubview:_nameLabel];
        {
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_feeLabel);
                make.top.equalTo(_feeLabel.mas_bottom).offset(10);
            }];
        }
        
    }
    return self;
}

- (NSString *)randomTicketNo {
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"票号：XC"];
    for (NSUInteger i = 0; i < 8; ++i) {
        [str appendFormat:@"%d", arc4random_uniform(10)];
    }
    return str;
}

- (void)setName:(NSString *)name {
    _name = name;
    
    _nameLabel.text = [NSString stringWithFormat:@"乘客：%@", name];
}

- (void)setFee:(NSUInteger)fee {
    _fee = fee;
    _feeLabel.text = [NSString stringWithFormat:@"%@：%@元", fee > 5000 ? @"包月" : @"包场", QLIntegralPrice(fee/100.)];
}

- (void)showInView:(UIView *)view {
    
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    const CGFloat width = CGRectGetWidth(view.bounds) * 0.75;
    const CGFloat height = width;
    self.frame = CGRectMake((view.bounds.size.width-width)/2, (view.bounds.size.height-height)/2, width, height);
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:8];
    }];
}

- (void)hide {
    if (self.superview) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}
@end
