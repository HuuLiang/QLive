//
//  QLAppDelegate.m
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLAppDelegate.h"
#import "QLLaunchViewController.h"
//#import <UMMobClick/MobClick.h>
#import "QLActivateModel.h"

@interface QLAppDelegate ()

@end

@implementation QLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [QBNetworkInfo sharedInfo].reachabilityChangedAction = ^(BOOL reachable) {
        if (reachable && ![QLUtil isRegistered]) {
            [[QLActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
                if (success) {
                    [QLUtil setRegisteredWithUserId:userId];
                }
            }];
        }
    };
    [[QBNetworkInfo sharedInfo] startMonitoring];
    
//    [[QLPaymentManager sharedManager] setup];
    [self setupMobAnalytics];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[QLLaunchViewController alloc] init];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setupMobAnalytics {
    
//#ifdef DEBUG
//    [MobClick setLogEnabled:YES];
//#endif
//    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
//    if (bundleVersion) {
//        [MobClick setAppVersion:bundleVersion];
//    }
//    
//    UMConfigInstance.appKey = @"58d226f0f43e4865af0000fc";
//    UMConfigInstance.secret = nil;
//    UMConfigInstance.channelId = kQLChannelNo;
//    [MobClick startWithConfigure:UMConfigInstance];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    [[QLPaymentManager sharedManager] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    [[QLPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//    [[QLPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    [[QLPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}
@end
