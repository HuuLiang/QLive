//
//  QLLiveGiftPanel.m
//  QLive
//
//  Created by Sean Yue on 2017/3/14.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLLiveGiftPanel.h"
#import "QLLiveGiftCell.h"

static NSString *const kCellReusableIdentifier = @"CellReusableIdentifiers";

@interface QLLiveGiftPanel () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    UICollectionView *_giftCV;
    
    UIView *_footerView;
    UILabel *_remainLabel;
    UIButton *_chargeButton;
}
@property (nonatomic,retain) UITapGestureRecognizer *autoHideGestureRecognizer;
@end

@implementation QLLiveGiftPanel

+ (instancetype)showPanelInView:(UIView *)view
                      withGifts:(NSArray<QLLiveGift *> *)gifts
                      goldCount:(NSUInteger)goldCount
                didSelectAction:(QLLiveGiftDidSelectAction)didSelectAction
                   chargeAction:(QBAction)chargeAction
{
    QLLiveGiftPanel *panel = [[self alloc] init];
    panel.gifts = gifts;
    panel.goldCount = goldCount;
    panel.didSelectAction = didSelectAction;
    panel.chargeAction = chargeAction;
    [panel showInView:view];
    return panel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        
        _giftCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _giftCV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        _giftCV.delegate = self;
        _giftCV.dataSource = self;
        [_giftCV registerClass:[QLLiveGiftCell class] forCellWithReuseIdentifier:kCellReusableIdentifier];
        [self addSubview:_giftCV];
        {
            [_giftCV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self);
                make.height.equalTo(_giftCV.mas_width).multipliedBy(0.5).offset(10);
            }];
        }
        
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = _giftCV.backgroundColor;
        [self addSubview:_footerView];
        {
            [_footerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self);
                make.top.equalTo(_giftCV.mas_bottom);
            }];
        }
        
        _remainLabel = [[UILabel alloc] init];
        _remainLabel.font = kHugeFont;
        _remainLabel.textColor = [UIColor whiteColor];
        self.goldCount = 0;
        [_footerView addSubview:_remainLabel];
        {
            [_remainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(_footerView);
                make.left.equalTo(_footerView).offset(15);
                make.width.equalTo(_footerView).multipliedBy(0.75).offset(-30);
            }];
        }
        
        _chargeButton = [[UIButton alloc] init];
        _chargeButton.titleLabel.font = kExtraBigFont;
        [_chargeButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#ffff04"]] forState:UIControlStateNormal];
        [_chargeButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [_chargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [_chargeButton addTarget:self action:@selector(onCharge) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_chargeButton];
        {
            [_chargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.top.equalTo(_footerView);
                make.left.equalTo(_remainLabel.mas_right).offset(15);
            }];
        }
    }
    return self;
}

- (void)onCharge {
    QBSafelyCallBlock(self.chargeAction, self);
}

- (void)dealloc {
    QBLog(@"%@ dealloc", [self class]);
}

- (void)setGifts:(NSArray<QLLiveGift *> *)gifts {
    _gifts = gifts;
    [_giftCV reloadData];
}

- (void)setGoldCount:(NSUInteger)goldCount {
    _goldCount = goldCount;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"余额 %ld", (unsigned long)goldCount]];
    [attrString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ffff04"],
                                NSFontAttributeName:kHugeBoldFont} range:NSMakeRange(3, attrString.length-3)];
    _remainLabel.attributedText = attrString;
}

- (void)showInView:(UIView *)view {
    if ([view.subviews containsObject:self]) {
        return ;
    }
    
    const CGFloat width = view.bounds.size.width;
    const CGFloat height = width/2 + 54;
    CGRect frame = CGRectMake(0, CGRectGetHeight(view.bounds)-height, width, height);
    self.frame = CGRectOffset(frame, 0, frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    }];
    
    self.autoHideGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    self.autoHideGestureRecognizer.delegate = self;
    [view addGestureRecognizer:self.autoHideGestureRecognizer];
}

- (void)hide {
    if (!self.superview) {
        return ;
    }
    
    [self.autoHideGestureRecognizer.view removeGestureRecognizer:self.autoHideGestureRecognizer];
    self.autoHideGestureRecognizer = nil;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gifts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QLLiveGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReusableIdentifier forIndexPath:indexPath];
    
    QLLiveGift *gift = indexPath.item < self.gifts.count ? self.gifts[indexPath.item] : nil;
    cell.gift = gift;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat interItemSpacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    const CGFloat itemWidth = (CGRectGetWidth(collectionView.bounds) - interItemSpacing * 3)/4;
    return CGSizeMake(itemWidth, itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.gifts.count) {
        QBSafelyCallBlock(self.didSelectAction, self.gifts[indexPath.item], self);
    }
}
@end
