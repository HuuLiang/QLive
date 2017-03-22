//
//  QLTextFieldViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/4.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLTextFieldViewController.h"

@interface QLTextFieldViewController () <UITextFieldDelegate>
{
    UITextField *_inputTextField;
}
@end

@implementation QLTextFieldViewController

- (instancetype)initWithText:(NSString *)text
                 placeholder:(NSString *)placeholder
                   maxLength:(NSUInteger)maxLength
             didFinishAction:(QLTextFieldDidFinishAction)didFinishAction
{
    self = [super init];
    if (self) {
        _text = text;
        _placeHolder = placeholder;
        _maxLength = maxLength;
        _didFinishAction = didFinishAction;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(onOK)];
    self.navigationItem.rightBarButtonItem.enabled = self.text.length > 0;
    
    UITableViewCell *editCell = [[UITableViewCell alloc] init];
    editCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cells = @{[NSIndexPath indexPathForRow:0 inSection:0]:editCell};
    self.headerHeights = @{@(0):@(10)};
    
    _inputTextField = [[UITextField alloc] init];
    _inputTextField.text = self.text;
    _inputTextField.placeholder = self.placeHolder;
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.delegate = self;
    [editCell addSubview:_inputTextField];
    {
        [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(editCell).insets(UIEdgeInsetsMake(5, 15, 5, 15));
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFieldChangedNotification) name:UITextFieldTextDidChangeNotification object:_inputTextField];
}

- (void)onTextFieldChangedNotification {
    self.navigationItem.rightBarButtonItem.enabled = _inputTextField.text.length > 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_inputTextField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onOK {
    [_inputTextField resignFirstResponder];
    
    _text = _inputTextField.text;
    
    if (self.didFinishAction && self.didFinishAction(self.text, self)) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onOK];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if (self.maxLength > 0 && textField.text.length + string.length - range.length > self.maxLength) {
        return NO;
    }
    
    return YES;
}
@end
