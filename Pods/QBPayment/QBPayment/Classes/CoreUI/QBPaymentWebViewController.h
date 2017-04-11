//
//  QBPaymentWebViewController.h
//  Pods
//
//  Created by Sean Yue on 2016/10/21.
//
//

#import <UIKit/UIKit.h>

@interface QBPaymentWebViewController : UIViewController

@property (nonatomic,copy) void (^closeAction)(void);
@property (nonatomic,copy) void (^capturedAlipayRequest)(NSURL *url, id obj);

- (instancetype)initWithHTMLString:(NSString *)htmlString;
- (instancetype)initWithURL:(NSURL *)url;

@end
