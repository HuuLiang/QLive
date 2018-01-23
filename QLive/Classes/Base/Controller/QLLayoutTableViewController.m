//
//  QLLayoutTableViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/4.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLayoutTableViewController.h"

@interface QLLayoutTableViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation QLLayoutTableViewController
@synthesize layoutTableView = _layoutTableView;

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultCellHeight = 44;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.layoutTableView];
}

- (UITableView *)layoutTableView {
    if (_layoutTableView) {
        return _layoutTableView;
    }
    
    _layoutTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _layoutTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    return _layoutTableView;
}

- (void)setHeaderHeights:(NSDictionary<NSNumber *,NSNumber *> *)headerHeights {
    _headerHeights = headerHeights;
    
    if ([headerHeights[@(0)] floatValue] > 0) {
        _layoutTableView.contentInset = UIEdgeInsetsZero;
    } else {
        _layoutTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
}

- (void)reloadData {
    [self.layoutTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    __block NSInteger numberOfSection = 0;
    [self.cells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, UITableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        numberOfSection = MAX(numberOfSection, key.section+1);
    }];
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    __block NSInteger numberOfRows = 0;
    [self.cells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, UITableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        if (key.section == section) {
            numberOfRows = MAX(numberOfRows, key.row+1);
        }
    }];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    return self.cells[cellIndexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSNumber *height = self.cellHeights[cellIndexPath];
    
    if (!height && self.cellHeightBlock) {
        height = @(self.cellHeightBlock(cellIndexPath, tableView));
    }
    
    return height ? height.floatValue : self.defaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSNumber *height = self.headerHeights[@(section)];
    return height.floatValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSNumber *height = self.footerHeights[@(section)];
    return height.floatValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.didSelectCellAction) {
        self.didSelectCellAction(indexPath, [tableView cellForRowAtIndexPath:indexPath]);
    }
}
@end
