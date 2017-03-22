//
//  QLLivePrivateShowContactViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLivePrivateShowContactViewController.h"

@interface QLLivePrivateShowContactViewController ()
{
    UIImageView *_topImageView;
    
    UIView *_contentView;
    UIButton *_closeButton;
    
    UIButton *_qqButton;
    UIButton *_wechatButton;
}
@end

@implementation QLLivePrivateShowContactViewController

+ (instancetype)showContactInViewController:(UIViewController *)viewController withAnchor:(QLAnchor *)anchor {
    QLLivePrivateShowContactViewController *contactVC = [[self alloc] init];
    contactVC.anchor = anchor;
    [contactVC showInViewController:viewController];
    return contactVC;
}

+ (instancetype)showContactInViewController:(UIViewController *)viewController withLiveShow:(QLLiveShow *)liveShow {
    QLLivePrivateShowContactViewController *contactVC = [[self alloc] init];
    contactVC.liveShow = liveShow;
    [contactVC showInViewController:viewController];
    return contactVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 10;
    _contentView.layer.masksToBounds = YES;
    [self.view addSubview:_contentView];
    {
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.8);
            make.height.mas_equalTo(165);
        }];
    }
    
    _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private_show_message"]];
    _topImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_topImageView];
    {
        [_topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(_contentView.mas_top);
            make.width.equalTo(_contentView).multipliedBy(0.4);
            make.height.equalTo(_topImageView.mas_width);
        }];
    }
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"gray_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_contentView);
        }];
    }
    
    _qqButton = [[UIButton alloc] init];
    _qqButton.userInteractionEnabled = NO;
    _qqButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _qqButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_qqButton setImage:[UIImage imageNamed:@"live_private_show_qq"] forState:UIControlStateNormal];
    [_qqButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [_qqButton setTitle:self.anchor ? self.anchor.qqNum : self.liveShow.qqNum forState:UIControlStateNormal];
    [_contentView addSubview:_qqButton];
    {
        [_qqButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_topImageView.mas_bottom).offset(15);
            make.centerX.equalTo(_contentView);
            make.height.mas_equalTo(30);
            make.width.equalTo(_contentView);
        }];
    }
    
    _wechatButton = [[UIButton alloc] init];
    _wechatButton.userInteractionEnabled = NO;
    _wechatButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _wechatButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_wechatButton setImage:[UIImage imageNamed:@"live_private_show_wechat"] forState:UIControlStateNormal];
    [_wechatButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [_wechatButton setTitle:self.anchor ? self.anchor.weixinNum : self.liveShow.weiXinNum forState:UIControlStateNormal];
    [_contentView addSubview:_wechatButton];
    {
        [_wechatButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.top.equalTo(_qqButton.mas_bottom).offset(10);
            make.height.mas_equalTo(30);
            make.width.equalTo(_contentView);
        }];
    }
}

- (void)setAnchor:(QLAnchor *)anchor {
    _anchor = anchor;
    
    [_qqButton setTitle:anchor.qqNum forState:UIControlStateNormal];
    [_wechatButton setTitle:anchor.weixinNum forState:UIControlStateNormal];
}

- (void)setLiveShow:(QLLiveShow *)liveShow {
    _liveShow = liveShow;
    [_qqButton setTitle:liveShow.qqNum forState:UIControlStateNormal];
    [_wechatButton setTitle:liveShow.weiXinNum forState:UIControlStateNormal];
}

- (void)onClose {
    [self hideAnimated:YES];
}

- (void)showInViewController:(UIViewController *)viewController {
    if ([viewController.childViewControllers containsObject:self]) {
        return ;
    }
    
    if ([viewController.view.subviews containsObject:self.view]) {
        return ;
    }
    
    [viewController addChildViewController:self];
    
    self.view.frame = viewController.view.bounds;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
}

- (void)hideAnimated:(BOOL)animated {
    if (self.parentViewController) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self willMoveToParentViewController:nil];
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        } else {
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
