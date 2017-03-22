//
//  QLLaunchViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/6.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLaunchViewController.h"
#import "QLTabBarController.h"
#import <YLProgressBar.h>

@interface QLLaunchViewController ()
@property (nonatomic,retain) dispatch_group_t dispatchGroup;
@end

@implementation QLLaunchViewController

- (dispatch_group_t)dispatchGroup {
    if (_dispatchGroup) {
        return _dispatchGroup;
    }
    
    _dispatchGroup = dispatch_group_create();
    return _dispatchGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"launch_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = kMediumFont;
    textLabel.text = @"正在登录...";
    [self.view addSubview:textLabel];
    {
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view).multipliedBy(1.75);
        }];
    }
    
    YLProgressBar *progressBar = [[YLProgressBar alloc] init];
    progressBar.progress = 1;
    progressBar.behavior = YLProgressBarBehaviorWaiting;
    
    NSArray *rainbowColors = @[[UIColor colorWithRed:126/255.0f green:26/255.0f blue:36/255.0f alpha:1.0f],
                               [UIColor colorWithRed:149/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f],
                               [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                               [UIColor colorWithRed:245/255.0f green:166/255.0f blue:35/255.0f alpha:1.0f],
                               [UIColor colorWithRed:165/255.0f green:202/255.0f blue:60/255.0f alpha:1.0f],
                               [UIColor colorWithRed:202/255.0f green:217/255.0f blue:54/255.0f alpha:1.0f],
                               [UIColor colorWithRed:111/255.0f green:188/255.0f blue:84/255.0f alpha:1.0f],
                               [UIColor colorWithRed:33/255.0f green:180/255.0f blue:162/255.0f alpha:1.0f],
                               [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
                               [UIColor colorWithRed:91/255.0f green:63/255.0f blue:150/255.0f alpha:1.0f],
                               [UIColor colorWithRed:87/255.0f green:26/255.0f blue:70/255.0f alpha:1.0f]];
    progressBar.progressTintColors = rainbowColors;
    [self.view addSubview:progressBar];
    {
        [progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textLabel.mas_bottom).offset(5);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(10);
            make.width.equalTo(self.view).multipliedBy(0.5);
        }];
    }
    
    @weakify(self);
    [NSTimer bk_scheduledTimerWithTimeInterval:2 block:^(NSTimer *timer) {
        @strongify(self);
        [self prepareData];
    } repeats:NO];
}

- (void)prepareData {
    
    const NSUInteger dataRequestCount = 3;
    for (NSUInteger i = 0; i < dataRequestCount; ++i) {
        dispatch_group_enter(self.dispatchGroup);
    }
    
    @weakify(self);
    __block BOOL anchorSuccess = NO;
    [QLAnchor objectsFromPersistenceAsync:^(NSArray *objects) {
        if (objects.count > 0) {
            anchorSuccess = YES;
            dispatch_group_leave(self.dispatchGroup);
        } else {
            [[QLRESTManager sharedManager] request_queryAnchorsWithCompletionHandler:^(id obj, NSError *error) {
                @strongify(self);
                if (obj) {
                    NSArray<QLAnchor *> *anchors = [(QLAnchorResponse *)obj anchors];
                    if (anchors.count > 0) {
                        [QLAnchor saveObjects:anchors];
                        anchorSuccess = YES;
//                    } else {
//                        [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"无主播信息"];
                    }
//                } else {
//                    [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:error.qlErrorMessage];
                }
                
                dispatch_group_leave(self.dispatchGroup);
            }];
        }
    }];
    
    __block BOOL liveSuccess = NO;
    [QLLiveShow objectsFromPersistenceAsync:^(NSArray *objects) {
        if (objects.count > 0) {
            liveSuccess = YES;
            dispatch_group_leave(self.dispatchGroup);
        } else {
            [[QLRESTManager sharedManager] request_queryLiveShowsWithCompletionHandler:^(id obj, NSError *error) {
                @strongify(self);
                
                if (obj) {
                    NSArray<QLLiveShow *> *liveShows = [(QLLiveShowResponse *)obj shows];
                    if (liveShows.count > 0) {
                        [QLLiveShow saveObjects:liveShows];
                        
                        [liveShows enumerateObjectsUsingBlock:^(QLLiveShow * _Nonnull liveShow, NSUInteger showIdx, BOOL * _Nonnull stop) {
                            [liveShow.ticketInfos enumerateObjectsUsingBlock:^(QLLiveShowTicketInfo * _Nonnull ticketInfo, NSUInteger ticketInfoIdx, BOOL * _Nonnull stop) {
                                ticketInfo.ownerId = @(liveShow.liveId.integerValue);
                            }];
                            
                            [QLLiveShowTicketInfo saveObjects:liveShow.ticketInfos];
                        }];
                        
                        liveSuccess = YES;
                    }
                }
                
                dispatch_group_leave(self.dispatchGroup);
            }];
        }
    }];
    
    __block BOOL payPointSuccess = NO;
    if ([QLPayPoints sharedPayPoints]) {
        payPointSuccess = YES;
        dispatch_group_leave(self.dispatchGroup);
    } else {
        [[QLRESTManager sharedManager] request_queryPayPointsWithCompletionHandler:^(id obj, NSError *error) {
            @strongify(self);
            
            if (obj) {
                QLPayPoints *payPoints = [(QLPayPointsResponse *)obj points];
                if (payPoints) {
                    [payPoints save];
                    payPointSuccess = YES;
                }
            }
            
            dispatch_group_leave(self.dispatchGroup);
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (anchorSuccess && liveSuccess) {
                self.view.window.rootViewController = [QLTabBarController sharedController];
            } else {
                [[QLAlertManager sharedManager] alertWithTitle:@"错误" message:@"获取数据错误" OKButton:@"确定" cancelButton:@"取消" OKAction:^(id obj) {
                    @strongify(self);
                    [self prepareData];
                } cancelAction:^(id obj) {
                    exit(1);
                }];
            }
        });
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self bk_performBlock:^(id obj) {
//        UIViewController *thisVC = obj;
//        thisVC.view.window.rootViewController = [QLTabBarController sharedController];
//    } afterDelay:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
