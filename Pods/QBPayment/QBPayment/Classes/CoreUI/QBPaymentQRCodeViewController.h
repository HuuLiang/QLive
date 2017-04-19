//
//  QBPaymentQRCodeViewController.h
//  Pods
//
//  Created by Sean Yue on 2017/4/19.
//
//

#import <UIKit/UIKit.h>

@interface QBPaymentQRCodeViewController : UIViewController

@property (nonatomic,retain,readonly) UIImage *image;
@property (nonatomic,copy) void (^paymentCompletion)(id obj);

+ (instancetype)presentQRCodeInViewController:(UIViewController *)viewController
                                    withImage:(UIImage *)image
                            paymentCompletion:(void (^)(id obj))paymentCompletion;

- (instancetype)initWithImage:(UIImage *)image;

@end
