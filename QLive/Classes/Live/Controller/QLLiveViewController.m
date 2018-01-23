//
//  QLLiveViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveViewController.h"
#import "QLLiveShowView.h"
#import "QLButton.h"

@interface QLLiveViewController () <UITextFieldDelegate>
{
    UIButton *_closeButton;
    UITextField *_titleTextField;
    UIView *_titleUnderlineView;
    UILabel *_shareTitleLabel;
    UIView *_shareSeparator;
    
    QLButton *_wxTimelineShareButton;
    QLButton *_wxMsgShareButton;
    QLButton *_qqShareButton;
    
    UIButton *_liveButton;
}
@property (nonatomic,retain) QLLiveShowView *liveShowView;
@end

@implementation QLLiveViewController

- (QLLiveShowView *)liveShowView {
    if (_liveShowView) {
        return _liveShowView;
    }
    CGFloat height = MAX(213, kScreenHeight*0.37);
    _liveShowView = [[QLLiveShowView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight + height)];
    @weakify(self);
    _liveShowView.action = ^(id obj) {
        @strongify(self);
        [self onShare];
    };
    _liveShowView.closeAction = ^(id obj) {
        @strongify(self);
        [self onClose];
    };
    return _liveShowView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.liveShowView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    self.tabBarController.selectedIndex = 0;
    //    [self showLiveView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLiveView];
    self.tabBarController.selectedIndex = 0;
}

- (void)showLiveView {
    //    self.liveShowView.hidden = NO;
    CGFloat height = MAX(213, kScreenHeight*0.37);
    self.liveShowView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight+height);
    [UIView animateWithDuration:0.2 animations:^{
        self.liveShowView.hidden = NO;
        self.liveShowView.frame = CGRectMake(0, -height, kScreenWidth, kScreenHeight+height);
    }];
    
}


- (void)onClose {
    self.tabBarController.selectedIndex = 0;
    self.liveShowView.hidden = YES;
}

- (void)onShare {
    [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:2 complete:^{
        [[QLAlertManager sharedManager] alertWithTitle:@"提示" message:@"请在手机设置打开应用权限"];
    }];
}

- (void)onLive {
    [[QLAlertManager sharedManager] alertWithTitle:@"警告" message:@"请开启相机权限"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length + string.length - range.length <= 12) {
        return YES;
    }
    return NO;
}

@end
