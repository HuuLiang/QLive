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
#import <objc/runtime.h>

@import Photos;
@import AssetsLibrary;

//static NSString *const kSuccessSavePhotoMessage = @"二维码保存成功，是否跳转到微信app？";
static NSString *const kFailureSavePhotoMessage = @"二维码保存失败";
static NSString *const kPaymentCompletionMessage = @"如果您已经完成了支付操作，请点击【确认】";
static NSString *const kCloseConfirmMessage = @"您的支付还未完成，是否确认关闭？";
//static NSString *const kPhotoPreAuthorizationMessage = @"扫码支付将保存二维码到您的相册，这需要您开启本地相册的访问权限";
static NSString *const kPhotoAuthorityMessage = @"保存支付二维码需要您开启本地相册的访问权限";

static NSString *const kWechatButtonTitle = @"保存二维码并打开微信扫一扫";

static const void *kAlertViewAssociatedBlock = &kAlertViewAssociatedBlock;

@interface QBPaymentQRCodeViewController () <UIActionSheetDelegate,UIAlertViewDelegate>
{
    UIImageView *_imageView;
    UITextView *_textView;
//    UILabel *_textLabel;
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
        _startWorkflowWhenViewDidAppear = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫码支付";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    
    _textView = [[UITextView alloc] init];
    _textView.textColor = [UIColor colorWithWhite:0.1875 alpha:1];
    _textView.scrollEnabled = NO;
    _textView.selectable = NO;
    _textView.editable = NO;
//    _textView.font = [UIFont systemFontOfSize:16.];
    [self.view addSubview:_textView];
//    
//    _textLabel = [[UILabel alloc] init];
//    _textLabel.textColor = [UIColor colorWithWhite:0.1875 alpha:1];
//    _textLabel.font = [UIFont systemFontOfSize:16.];
////    _textLabel.text = [NSString stringWithFormat:@"步骤1：点击【%@】，您必须开启相册访问权限才能保存支付二维码，或者您也可以对本界面截屏保存支付二维码。\n\n步骤2：在【微信扫一扫】界面中，选择相册(右上角)，点击“相册”,选中二维码照片。\n\n注：如果您已经成功支付，请点击本界面右上角的【已支付】按钮，验证支付结果。", kWechatButtonTitle];
//    _textLabel.numberOfLines = 10;
//    [self.view addSubview:_textLabel];
    
    NSString *redString = @"您必须开启相册访问权限才能保存支付二维码";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"步骤1：点击【%@】，%@，或者您也可以对本界面截屏保存支付二维码。\n\n步骤2：在【微信扫一扫】界面中，点击相册（右上角），选择支付二维码并点击完成，方可支付。\n\n注：如果您已经成功支付，请点击本界面右上角的【已支付】按钮，验证支付结果。", kWechatButtonTitle, redString] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:MIN(16, roundf([[UIScreen mainScreen] bounds].size.width*0.045))]}];
    
    
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[attrString.string rangeOfString:redString]];
    _textView.attributedText = attrString;

    
//    UILongPressGestureRecognizer *gesRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressImage:)];
////    gesRec.minimumPressDuration = 1;
//    [_imageView addGestureRecognizer:gesRec];
    
    _wechatButton = [[UIButton alloc] init];
    _wechatButton.layer.cornerRadius = 8;
    _wechatButton.layer.masksToBounds = YES;
    [_wechatButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#00cc0d"]] forState:UIControlStateNormal];
    [_wechatButton setTitle:kWechatButtonTitle forState:UIControlStateNormal];
    [_wechatButton addTarget:self action:@selector(saveImageToLocalPhotos) forControlEvents:UIControlEventTouchUpInside];
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
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.startWorkflowWhenViewDidAppear) {
        [self saveImageToLocalPhotos];
    }
}

- (void)checkPhotoAuthorityWithCompletion:(void (^)(BOOL success))completion {
    if (NSClassFromString(@"PHPhotoLibrary")) {
        
        void (^onAuthStatus)(PHAuthorizationStatus photoAuthorStatus) = ^(PHAuthorizationStatus photoAuthorStatus) {
            if ([[NSThread currentThread] isMainThread]) {
                if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
                    completion(YES);
                } else {
                    completion(NO);
                };
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
                        completion(YES);
                    } else {
                        completion(NO);
                    };
                });
            }
            
        };
        
        PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
        if (photoAuthorStatus == PHAuthorizationStatusNotDetermined) {
            if (NSClassFromString(@"PHPhotoLibrary")) {
                [PHPhotoLibrary requestAuthorization:onAuthStatus];
            }
        } else {
            onAuthStatus(photoAuthorStatus);
        }
    } else {
        
        void (^onAuthStatus)(ALAuthorizationStatus status) = ^(ALAuthorizationStatus status) {
            if ([[NSThread currentThread] isMainThread]) {
                if (status == ALAuthorizationStatusAuthorized) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == ALAuthorizationStatusAuthorized) {
                        completion(YES);
                    } else {
                        completion(NO);
                    }
                });
            }
        };
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status == ALAuthorizationStatusNotDetermined) {
            [[[ALAssetsLibrary alloc] init] assetForURL:[NSURL URLWithString:@"/"] resultBlock:^(ALAsset *asset) {
                onAuthStatus(ALAuthorizationStatusAuthorized);
            } failureBlock:^(NSError *error) {
                onAuthStatus(ALAuthorizationStatusDenied);
            }];
        } else {
            onAuthStatus(status);
        }
    }
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

    
    const CGFloat imageHeight = fullHeight * 0.2 * fullHeight/480;
    const CGFloat imageWidth = imageHeight;
    const CGFloat imageX = (fullWidth - imageWidth)/2;
    const CGFloat imageY = 10;
    _imageView.frame = CGRectMake(imageX, imageY, imageWidth, imageHeight);
    
    const CGFloat textWidth = fullWidth * 0.8;
    const CGFloat textX = (fullWidth - textWidth)/2;
    CGRect textRect = [_textView.attributedText boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _textView.frame = CGRectMake(textX, CGRectGetMaxY(_imageView.frame), textWidth, textRect.size.height+20);
    
    _wechatButton.frame = CGRectMake(textX, CGRectGetMaxY(_textView.frame)+10, textWidth, 44);
    _refreshButton.frame = CGRectMake(textX, CGRectGetMaxY(_wechatButton.frame)+10, _wechatButton.frame.size.width, _wechatButton.frame.size.height);
}

//- (void)onLongPressImage:(UIGestureRecognizer *)gesRec {
//    if (gesRec.state == UIGestureRecognizerStateBegan) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存二维码", nil];
//        [actionSheet showInView:self.view];
//    }
//}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kFailureSavePhotoMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kSuccessSavePhotoMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
        [self onWeChatScan];
    }
    
}

- (void)onClose {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kCloseConfirmMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)saveImageToLocalPhotos {
    __weak typeof(self) weakSelf = self;
    [self checkPhotoAuthorityWithCompletion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            UIImageWriteToSavedPhotosAlbum(strongSelf.image, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kPhotoAuthorityMessage delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self saveImageToLocalPhotos];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if ([alertView.message isEqualToString:kSuccessSavePhotoMessage]
//        && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
//        [self onWeChatScan];
//    } else
    if ([alertView.message isEqualToString:kPaymentCompletionMessage]
               && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        if (self.paymentCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.paymentCompletion(NO, self);
            });
            
        }
    } else if ([alertView.message isEqualToString:kCloseConfirmMessage]
               && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if ([alertView.message isEqualToString:kPhotoAuthorityMessage]
               && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]) {
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
        }
        
    }
//    else if ([alertView.message isEqualToString:kPhotoPreAuthorizationMessage]) {
//        if (NSClassFromString(@"PHPhotoLibrary")) {
//            id block = objc_getAssociatedObject(alertView, kAlertViewAssociatedBlock);
//            [PHPhotoLibrary requestAuthorization:block];
//        }
//        
//    }
}

@end
