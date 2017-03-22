//
//  QLLiveChatPanel.m
//  QLive
//
//  Created by Sean Yue on 2017/3/15.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveChatPanel.h"
#import "QLTextField.h"

static const CGFloat kPanelHeight = 35;

@interface QLLiveChatPanel () <UITextFieldDelegate>
{
    UIButton *_barrageButton;
    QLTextField *_messageTextField;
    UIButton *_sendButton;
}
@property (nonatomic,retain) UITapGestureRecognizer *autoHideGestureRecognizer;
@end

@implementation QLLiveChatPanel

+ (instancetype)showPanelInView:(UIView *)view withSendAction:(QBAction)sendAction {
    QLLiveChatPanel *panel = [[self alloc] init];
    panel.sendAction = sendAction;
    [panel showInView:view];
    return panel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _barrageButton = [[UIButton alloc] init];
        _barrageButton.layer.cornerRadius = 5;
        _barrageButton.layer.masksToBounds = YES;
        [_barrageButton setBackgroundImage:[UIImage imageNamed:@"barrage_on"] forState:UIControlStateSelected];
        [_barrageButton setBackgroundImage:[UIImage imageNamed:@"barrage_off"] forState:UIControlStateNormal];
        [_barrageButton bk_addEventHandler:^(id sender) {
            UIButton *thisButton = sender;
            thisButton.selected = !thisButton.selected;
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_barrageButton];
        {
            CGSize imageSize = [_barrageButton backgroundImageForState:UIControlStateNormal].size;
            [_barrageButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.equalTo(self);
                make.height.mas_equalTo(kPanelHeight);
                make.width.equalTo(_barrageButton.mas_height).multipliedBy(imageSize.width/imageSize.height);
            }];
        }
        
        _sendButton = [[UIButton alloc] init];
        _sendButton.titleLabel.font = kMediumFont;
        _sendButton.layer.cornerRadius = 5;
        _sendButton.layer.masksToBounds = YES;
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#63dac4"]] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#999999"]] forState:UIControlStateDisabled];
        [self addSubview:_sendButton];
        {
            [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
                make.right.equalTo(self).offset(-5);
                make.height.equalTo(_barrageButton);
                make.width.mas_equalTo(50);
            }];
        }
        
        _messageTextField = [[QLTextField alloc] init];
        _messageTextField.placeholder = @"您想对主播说些什么";
        _messageTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
        _messageTextField.layer.cornerRadius = 5;
        _messageTextField.font = kMediumFont;
        _messageTextField.returnKeyType = UIReturnKeySend;
        _messageTextField.delegate = self;
        [self addSubview:_messageTextField];
        {
            [_messageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_barrageButton.mas_right).offset(5);
                make.bottom.equalTo(_barrageButton);
                make.height.equalTo(_barrageButton);
                make.right.equalTo(_sendButton.mas_left).offset(-5);
            }];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextChanged) name:UITextFieldTextDidChangeNotification object:_messageTextField];
    }
    return self;
}

- (void)onSendMessage {
    QBSafelyCallBlock(self.sendAction, self);
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(view.bounds)-kPanelHeight-5, CGRectGetWidth(view.bounds), kPanelHeight);
    self.frame = frame;
    [view addSubview:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [_messageTextField becomeFirstResponder];
    
    self.autoHideGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [view addGestureRecognizer:self.autoHideGestureRecognizer];
}

- (void)hide {
    [_messageTextField resignFirstResponder];
}

- (void)onKeyboardFrameChange:(NSNotification *)notification {
    CGRect bounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.frame = CGRectMake(0, CGRectGetHeight(self.superview.bounds) - bounds.size.height - kPanelHeight-5, self.frame.size.width, self.frame.size.height);
}

- (void)onTextChanged {
    _sendButton.enabled = _messageTextField.text.length > 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onSendMessage];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!self.superview) {
        return ;
    }
    
    [self.autoHideGestureRecognizer.view removeGestureRecognizer:self.autoHideGestureRecognizer];
    self.autoHideGestureRecognizer = nil;

    [self removeFromSuperview];
}
@end
