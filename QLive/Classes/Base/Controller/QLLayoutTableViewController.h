//
//  QLLayoutTableViewController.h
//  QLive
//
//  Created by Sean Yue on 2017/3/4.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLBaseViewController.h"

@class QLLayoutTableViewController;

typedef void (^QLLayoutDidSelectCellAction)(NSIndexPath *indexPath, UITableViewCell *cell);

typedef CGFloat (^QLLayoutTableViewCellHeightBlock)(NSIndexPath *indexPath, UITableView *tableView);

@interface QLLayoutTableViewController : QLBaseViewController

@property (nonatomic,retain,readonly) UITableView *layoutTableView;

// Cell
@property (nonatomic,retain) NSDictionary<NSIndexPath *, UITableViewCell *> *cells;
@property (nonatomic,retain) NSDictionary<NSIndexPath *, NSNumber *> *cellHeights;
@property (nonatomic,copy) QLLayoutTableViewCellHeightBlock cellHeightBlock;

@property (nonatomic) CGFloat defaultCellHeight;

// Header
@property (nonatomic,retain) NSDictionary<NSNumber *, NSNumber *> *headerHeights;

// Footer
@property (nonatomic,retain) NSDictionary<NSNumber *, NSNumber *> *footerHeights;

// Action
@property (nonatomic,copy) QLLayoutDidSelectCellAction didSelectCellAction;

- (void)reloadData;

@end
