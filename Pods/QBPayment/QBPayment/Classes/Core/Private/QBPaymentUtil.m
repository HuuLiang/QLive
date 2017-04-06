//
//  QBPaymentUtil.m
//  Pods
//
//  Created by Sean Yue on 2017/4/5.
//
//

#import "QBPaymentUtil.h"
#import <sys/sysctl.h>

@implementation QBPaymentUtil

+ (UIViewController *)viewControllerForPresentingPayment {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}
@end
