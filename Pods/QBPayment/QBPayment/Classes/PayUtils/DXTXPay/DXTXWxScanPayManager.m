//
//  DXTXWxScanPayManager.m
//  Pods
//
//  Created by Sean Yue on 2017/4/20.
//
//

#import "DXTXWxScanPayManager.h"
#import "QBPaymentInfo.h"
#import "QBDefines.h"
#import "AFNetworking.h"
#import "QBPaymentUtil.h"
#import "MBProgressHUD.h"
#import "NSString+md5.h"
#import "QBPaymentQRCodeViewController.h"
#import "QBPaymentManager.h"
#import "RACEXTScope.h"

static NSString *const kPayURL = @"https://zf.q0.cc/Pay.ashx";

@interface DXTXWxScanPayManager () <NSXMLParserDelegate>
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) QBPaymentInfo *paymentInfo;
@property (nonatomic,copy) QBPaymentCompletionHandler completionHandler;

@property (nonatomic,copy) QBAction didFindQRImageAction;
@end

@implementation DXTXWxScanPayManager

+ (instancetype)sharedManager {
    static DXTXWxScanPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.requestSerializer.timeoutInterval = 30;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)payWithPaymentInfo:(QBPaymentInfo *)paymentInfo completionHandler:(QBPaymentCompletionHandler)completionHandler {
    if (QBP_STRING_IS_EMPTY(self.appKey) || QBP_STRING_IS_EMPTY(self.notifyUrl) || !self.waresid
        || QBP_STRING_IS_EMPTY(paymentInfo.orderId) || paymentInfo.orderPrice == 0 || paymentInfo.paymentType != QBPayTypeDXTXScanPay
        || paymentInfo.paymentSubType != QBPaySubTypeWeChat) {
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
        return ;
    }
    
    NSDictionary *params = @{@"o_bizcode":paymentInfo.orderId,
                             @"o_appkey":self.appKey,
                             @"o_term_key":[QBPaymentUtil IPAddress].md5,
                             @"o_address":self.notifyUrl,
                             @"o_paymode_id":@6,
                             @"o_goods_id":self.waresid,
                             @"o_goods_name":paymentInfo.orderDescription ?: @"VIP",
                             @"o_price":@(paymentInfo.orderPrice/100.),
                             @"o_privateinfo":paymentInfo.reservedData ?: @""};
    
    NSString *paramString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    [self.sessionManager POST:kPayURL
                   parameters:@{@"Pay":paramString?:@""}
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task,
                                id  _Nullable responseObject)
    {
        
        self.didFindQRImageAction = ^(id obj) {
            [QBPaymentQRCodeViewController presentQRCodeInViewController:[QBPaymentUtil viewControllerForPresentingPayment] withImage:obj paymentCompletion:^(BOOL isManual, id qrVC) {
                QBPaymentQRCodeViewController *thisVC = qrVC;
                [MBProgressHUD showHUDAddedTo:thisVC.view animated:YES];
                [qrVC setEnableCheckPayment:NO];
                
                [[QBPaymentManager sharedManager] activatePaymentInfo:paymentInfo withRetryTimes:3 shouldCommitFailureResult:!isManual completionHandler:^(BOOL success, id obj) {
                    [MBProgressHUD hideHUDForView:thisVC.view animated:YES];
                    [qrVC setEnableCheckPayment:YES];
                    
                    if (success) {
                        [qrVC dismissViewControllerAnimated:YES completion:^{
                            QBSafelyCallBlock(completionHandler, QBPayResultSuccess, paymentInfo);
                        }];
                    } else {
                        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
                    }
                }];
            } refreshAction:nil];
        };
        
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseObject];
        parser.delegate = self;
        [parser parse];
        
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        QBLog(@"%@ prepay fails: %@", [self class], error.localizedDescription);
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
        QBSafelyCallBlock(completionHandler, QBPayResultFailure, paymentInfo);
    }];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"img"]) {
        [parser abortParsing];
        
        __block NSString *imageString;
        NSString *prefix = @"base64,";
        
        NSArray<NSString *> *comps = [attributeDict[@"src"] componentsSeparatedByString:@";"];
        [comps enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:prefix]) {
                imageString = [obj substringFromIndex:prefix.length];
                *stop = YES;
            }
        }];
        
        if (imageString.length == 0) {
            return ;
        }
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image) {
                QBSafelyCallBlock(self.didFindQRImageAction, image);
            }
        }
    }
}
@end
