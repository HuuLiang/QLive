//
//  QLDebugViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/22.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLDebugViewController.h"

@interface QLDebugViewController ()

@end

@implementation QLDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"调试模式";
    
    NSMutableDictionary *cells = [NSMutableDictionary dictionary];
    
    NSUInteger i = 0;
    [cells setObject:[self cellWithTitle:@"版本号" subtitle:[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]] forKey:[NSIndexPath indexPathForRow:i++ inSection:0]];
    [cells setObject:[self cellWithTitle:@"BundleID" subtitle:[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]] forKey:[NSIndexPath indexPathForRow:i++ inSection:0]];
    
    i = 0;
    [cells setObject:[self cellWithTitle:@"渠道号" subtitle:kQLChannelNo] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    [cells setObject:[self cellWithTitle:@"AppID" subtitle:kQLRESTAppId] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    [cells setObject:[self cellWithTitle:@"支付pV" subtitle:@(kQLPaymentPv).stringValue] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    [cells setObject:[self cellWithTitle:@"内容pV" subtitle:@(kQLContentPv).stringValue] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@****%@", [kQLRESTBaseURL substringToIndex:8], [kQLRESTBaseURL substringWithRange:NSMakeRange(kQLRESTBaseURL.length-4, 4)]];
    [cells setObject:[self cellWithTitle:@"接口地址" subtitle:baseUrl] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    [cells setObject:[self cellWithTitle:@"证书" subtitle:kPackageCertificate] forKey:[NSIndexPath indexPathForRow:i++ inSection:1]];
    
    i = 0;
    [cells setObject:[self cellWithTitle:@"UUID" subtitle:[QLUtil userId]] forKey:[NSIndexPath indexPathForRow:i++ inSection:2]];
    self.cells = cells;
}

- (UITableViewCell *)cellWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
