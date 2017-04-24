//
//  QLBaseViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/2/27.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLBaseViewController : UIViewController

- (void)startLiveCastWithAnchor:(QLAnchor *)anchor;
@property (nonatomic) BOOL hasCreatSearchView;

@end
