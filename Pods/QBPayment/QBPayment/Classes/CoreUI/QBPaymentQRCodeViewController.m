//
//  QBPaymentQRCodeViewController.m
//  Pods
//
//  Created by Sean Yue on 2017/4/19.
//
//

#import "QBPaymentQRCodeViewController.h"
#import "UIColor+hexColor.h"
#import "UIImage+color.h"

static NSString *const kSuccessSavePhotoMessage = @"图片保存成功，是否跳转到微信app？";
static NSString *const kFailureSavePhotoMessage = @"图片保存失败";
static NSString *const kPaymentCompletionMessage = @"如果您已经完成了支付操作，请点击【确认】";
static NSString *const kCloseConfirmMessage = @"您的支付还未完成，是否确认关闭？";

@interface QBPaymentQRCodeViewController () <UIActionSheetDelegate,UIAlertViewDelegate>
{
    UIImageView *_imageView;
    UILabel *_textLabel;
    UIButton *_wechatButton;
    UIButton *_refreshButton;
}
@end

@implementation QBPaymentQRCodeViewController

+ (instancetype)presentQRCodeInViewController:(UIViewController *)viewController
                                    withImage:(UIImage *)image
                            paymentCompletion:(void (^)(BOOL isManual, id obj))paymentCompletion
                                refreshAction:(void (^)(id obj))refreshAction {
    QBPaymentQRCodeViewController *qrVC = [[self alloc] initWithImage:image];
    qrVC.paymentCompletion = paymentCompletion;
    qrVC.refreshAction = refreshAction;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:qrVC];
    [viewController presentViewController:nav animated:YES completion:nil];
    return qrVC;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
        _enableCheckPayment = YES;
        _enableRefreshQRCode = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫码支付";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = [UIColor colorWithWhite:0.1875 alpha:1];
    _textLabel.font = [UIFont systemFontOfSize:16.];
    _textLabel.text = @"步骤1：长按二维码保存图片到手机相册或者截图本界面;\n步骤2：打开微信，选择“扫一扫”，然后在选择相册(右上角)，点击“相册”,选中二维码的界面。";
    _textLabel.numberOfLines = 5;
    [self.view addSubview:_textLabel];
    
    UILongPressGestureRecognizer *gesRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressImage:)];
//    gesRec.minimumPressDuration = 1;
    [_imageView addGestureRecognizer:gesRec];
    
    _wechatButton = [[UIButton alloc] init];
    _wechatButton.layer.cornerRadius = 8;
    _wechatButton.layer.masksToBounds = YES;
    [_wechatButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#00cc0d"]] forState:UIControlStateNormal];
    [_wechatButton setTitle:@"打开微信扫一扫" forState:UIControlStateNormal];
    [_wechatButton addTarget:self action:@selector(onWeChatScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wechatButton];
    
    _refreshButton = [[UIButton alloc] init];
    _refreshButton.layer.cornerRadius = _wechatButton.layer.cornerRadius;
//    _refreshButton.layer.masksToBounds = YES;
    _refreshButton.layer.borderWidth = 1;
    _refreshButton.layer.borderColor = [UIColor colorWithHexString:@"#00cc0d"].CGColor;
    [_refreshButton setTitle:@"刷新二维码" forState:UIControlStateNormal];
    [_refreshButton setTitleColor:[UIColor colorWithHexString:@"#00cc0d"] forState:UIControlStateNormal];
    [_refreshButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateDisabled];
    [_refreshButton addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventTouchUpInside];
    _refreshButton.hidden = self.refreshAction == nil;
    [self.view addSubview:_refreshButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"已支付" style:UIBarButtonItemStylePlain target:self action:@selector(onPaid)];
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}
#endif

- (void)onPaid {
    if (self.paymentCompletion) {
        self.paymentCompletion(YES,self);
    }
}

- (void)onWeChatScan {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://scanqrcode"]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kPaymentCompletionMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)onRefresh {
    if (self.refreshAction) {
        self.refreshAction(self);
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

- (void)setEnableCheckPayment:(BOOL)enableCheckPayment {
    _enableCheckPayment = enableCheckPayment;
    self.navigationItem.rightBarButtonItem.enabled = enableCheckPayment;
}

- (void)setEnableRefreshQRCode:(BOOL)enableRefreshQRCode {
    _enableRefreshQRCode = enableRefreshQRCode;
    _refreshButton.enabled = enableRefreshQRCode;
    
    if (enableRefreshQRCode) {
        _refreshButton.layer.borderColor = [UIColor colorWithHexString:@"#00cc0d"].CGColor;
    } else {
        _refreshButton.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGFloat fullWidth = self.view.bounds.size.width;
    const CGFloat fullHeight = self.view.bounds.size.height;
    
    const CGFloat imageHeight = fullHeight * 0.25;
    const CGFloat imageWidth = imageHeight;
    const CGFloat imageX = (fullWidth - imageWidth)/2;
    const CGFloat imageY = (fullHeight - imageHeight)/2 *0.5;
    _imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
    
    const CGFloat textWidth = fullWidth * 0.8;
    const CGFloat textX = (fullWidth - textWidth)/2;
    CGRect textRect = [_textLabel.text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textLabel.font} context:nil];
    _textLabel.frame = CGRectMake(textX, CGRectGetMaxY(_imageView.frame)+15, textWidth, textRect.size.height);
    
    _wechatButton.frame = CGRectMake(textX, CGRectGetMaxY(_textLabel.frame)+15, textWidth, 44);
    _refreshButton.frame = CGRectMake(textX, CGRectGetMaxY(_wechatButton.frame)+15, _wechatButton.frame.size.width, _wechatButton.frame.size.height);
}

- (void)onLongPressImage:(UIGestureRecognizer *)gesRec {
    if (gesRec.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存二维码", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kFailureSavePhotoMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kSuccessSavePhotoMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
}

- (void)onClose {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kCloseConfirmMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:kSuccessSavePhotoMessage]
        && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        [self onWeChatScan];
    } else if ([alertView.message isEqualToString:kPaymentCompletionMessage]
               && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        if (self.paymentCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.paymentCompletion(NO, self);
            });
            
        }
    } else if ([alertView.message isEqualToString:kCloseConfirmMessage]
               && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
