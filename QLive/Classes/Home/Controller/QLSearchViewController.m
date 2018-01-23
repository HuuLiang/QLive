//
//  QLSearchViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLSearchViewController.h"

@interface QLSearchViewController () <UISearchBarDelegate>
{
    UISearchBar *_searchBar;
    
    UIImageView *_imageView;
    UILabel *_titleLabel;
}
@end

@implementation QLSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _searchBar = [[UISearchBar alloc] init];//WithFrame:CGRectMake(0, 0, kScreenWidth * 0.75, 40)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"输入想要查找的信息";
    _searchBar.tintColor = [UIColor colorWithHexString:@"#999999"];
    self.navigationItem.titleView = _searchBar;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = kBigFont;
    _titleLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
    _titleLabel.text = @"没有搜索到你想要的信息";
    _titleLabel.hidden = YES;
    [self.view addSubview:_titleLabel];
    {
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_search"]];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
    {
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_titleLabel.mas_top).offset(-15);
            make.centerX.equalTo(self.view);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [[QLHUDManager sharedManager] showError:@"请输入搜索关键字"];
        return ;
    }
    
    [searchBar resignFirstResponder];
    
    @weakify(self);
    [[QLHUDManager sharedManager] showLoadingInfo:nil withDuration:2 complete:^{
        @strongify(self);
        if (self) {
            self->_imageView.hidden = NO;
            self->_titleLabel.hidden = NO;
        }
    }];
    
}
@end
