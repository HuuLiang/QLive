//
//  QBPaymentQRCodeViewController.h
//  Pods
//
//  Created by Sean Yue on 2017/4/19.
//
//

#import <UIKit/UIKit.h>

@interface QBPaymentQRCodeViewController : UIViewController

@property (nonatomic,retain) UIImage *image;
@property (nonatomic,copy) void (^paymentCompletion)(BOOL isManual, id obj);
@property (nonatomic,copy) void (^refreshAction)(id obj);

@property (nonatomic) BOOL enableCheckPayment;
@property (nonatomic) BOOL enableRefreshQRCode;

@property (nonatomic) BOOL startWorkflowWhenViewDidAppear;

+ (instancetype)presentQRCodeInViewController:(UIViewController *)viewController
                                    withImage:(UIImage *)image
                            paymentCompletion:(void (^)(BOOL isManual, id obj))paymentCompletion
                                refreshAction:(void (^)(id obj))refreshAction;

- (instancetype)initWithImage:(UIImage *)image;

@end
