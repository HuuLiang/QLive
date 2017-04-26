//
//  QLShowTimeCell.m
//  QLive
//
//  Created by Sean Yue on 2017/3/8.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLShowTimeCell.h"

@interface QLShowTimeCell ()
{
    UIImageView *_avatarImageView;
    UILabel *_nameLabel;
    
    UIImageView *_locIconImageView;
    UILabel *_cityLabel;
    
    UIImageView *_roomIconImageView;
    UILabel *_roomLabel;
    
    UIImageView *_ticketIconImageView;
    UILabel *_ticketLabel;
    
    UIImageView *_statusImageView;
    UIView *_separator;
//    UIView *_lineView;
}
@property (nonatomic) NSURL *avatarURL;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *city;

- (void)setCurrentTicketCount:(NSUInteger)currentTicketCount withTotalCount:(NSUInteger)totalCount;
@end

@implementation QLShowTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.forceRoundCorner = YES;
        [self addSubview:_avatarImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _nameLabel.font = kSmallFont;
        [self addSubview:_nameLabel];
        
        _locIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray_location"]];
        _locIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_locIconImageView];
        
        _cityLabel = [[UILabel alloc] init];
        _cityLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _cityLabel.font = kExtraSmallFont;
        [self addSubview:_cityLabel];
        
        _roomIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_icon"]];
        _roomIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_roomIconImageView];
        
        _roomLabel = [[UILabel alloc] init];
        _roomLabel.font = _nameLabel.font;
        _roomLabel.textColor = _nameLabel.textColor;
        _roomLabel.text = @"一对多房间";
        [self addSubview:_roomLabel];
        
        _ticketIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greay_person"]];
        _ticketIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_ticketIconImageView];
        
        _ticketLabel = [[UILabel alloc] init];
        _ticketLabel.font = _cityLabel.font;
        _ticketLabel.textColor = _cityLabel.textColor;
        [self setCurrentTicketCount:0 withTotalCount:0];
        [self addSubview:_ticketLabel];
        
        _statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private_show_waiting"]];
        _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_statusImageView];
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [self addSubview:_separator];
       
//        _lineView = [UIView new];
//        _lineView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
//        [self addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    const CGFloat fullHeight = CGRectGetHeight(self.bounds) - 10;
    
    const CGFloat avatarHeight = fullHeight * 0.4;
    const CGFloat avatarWidth = avatarHeight;
    const CGFloat avatarX = 40;
    const CGFloat avatarY = 15;//fullHeight/2 - avatarHeight;
    _avatarImageView.frame = CGRectMake(avatarX, avatarY, avatarWidth, avatarHeight);
    
    const CGFloat nameHeight = _nameLabel.font.pointSize;
    const CGFloat nameX = CGRectGetMaxX(_avatarImageView.frame)+8;
    const CGFloat nameY = CGRectGetMinY(_avatarImageView.frame) + nameHeight/2;
    const CGFloat nameWidth = fullWidth/2 - nameX;
    _nameLabel.frame = CGRectMake(nameX, nameY, nameWidth, nameHeight);
    
    const CGFloat locImageX = nameX;
    const CGFloat locImageHeight = _cityLabel.font.pointSize;
    const CGFloat locImageY = CGRectGetMaxY(_nameLabel.frame) + 8;
    const CGFloat locImageWidth = locImageHeight;
    _locIconImageView.frame = CGRectMake(locImageX, locImageY, locImageWidth, locImageHeight);
    
    const CGFloat cityX = CGRectGetMaxX(_locIconImageView.frame) + 5;
    const CGFloat cityY = locImageY ;
    const CGFloat cityWidth = fullWidth - cityX - 15;
    const CGFloat cityHeight = _cityLabel.font.pointSize;
    _cityLabel.frame = CGRectMake(cityX, cityY, cityWidth, cityHeight);
    
    const CGFloat roomIconWidth = _avatarImageView.frame.size.width * 0.4;
    const CGFloat roomIconHeight = roomIconWidth;
    const CGFloat roomIconX = self.center.x + 40;
    const CGFloat roomIconY = nameY -2;//CGRectGetMaxY(_avatarImageView.frame) + 10;
    _roomIconImageView.frame = CGRectMake(roomIconX, roomIconY, roomIconWidth, roomIconHeight);
    
    const CGFloat roomX = CGRectGetMaxX(_roomIconImageView.frame) + 6;
    const CGFloat roomHeight = _roomLabel.font.pointSize;
    const CGFloat roomWidth = nameWidth;
    const CGFloat roomY = _roomIconImageView.center.y - roomHeight / 2;
    _roomLabel.frame = CGRectMake(roomX, roomY, roomWidth, roomHeight);

    const CGFloat ticketImageHeight = roomHeight;
    const CGFloat ticketImageWidth = ticketImageHeight;
    const CGFloat ticketImageX = roomIconX;
    const CGFloat ticketImageY = CGRectGetMaxY(_roomIconImageView.frame) + 6;//_cityLabel.center.y - ticketImageHeight/2;
    _ticketIconImageView.frame = CGRectMake(ticketImageX, ticketImageY, ticketImageWidth, ticketImageHeight);
    
    const CGFloat ticketX = CGRectGetMaxX(_ticketIconImageView.frame) + 6;;
    const CGFloat ticketHeight = _ticketLabel.font.pointSize;
    const CGFloat ticketWidth = cityWidth;
    const CGFloat ticketY = _ticketIconImageView.center.y - ticketHeight/2;
    _ticketLabel.frame = CGRectMake(ticketX, ticketY, ticketWidth, ticketHeight);
//
    const CGFloat statusHeight = 30;
    const CGFloat statusWidth = MIN(140, kScreenWidth *0.37);//statusHeight * 3;
    const CGFloat statusX = self.center.x - statusWidth/2;//fullWidth - 10 - statusWidth;
    const CGFloat statusY = fullHeight - statusHeight -15;
    _statusImageView.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
//
    _separator.frame = CGRectMake(0, fullHeight, fullWidth, 10);
}

- (void)setAvatarURL:(NSURL *)avatarURL {
    _avatarURL = avatarURL;
    [_avatarImageView sd_setImageWithURL:avatarURL];
}

- (void)setName:(NSString *)name {
    _name = name;
    _nameLabel.text = name;
}

- (void)setCity:(NSString *)city {
    _city = city;
    _cityLabel.text = city;
}

- (void)setCurrentTicketCount:(NSUInteger)currentTicketCount withTotalCount:(NSUInteger)totalCount {
//    NSString *totalCountString = [NSString stringWithFormat:@"%ld", (unsigned long)totalCount];
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%@", (unsigned long)currentTicketCount, totalCountString]];
//    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attrString.length-totalCountString.length, totalCountString.length)];
//    _ticketLabel.attributedText = attrString;
    _ticketLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)currentTicketCount, (unsigned long)totalCount];
}

- (void)setLiveShow:(QLLiveShow *)liveShow {
    _liveShow = liveShow;
    
    self.avatarURL = [NSURL URLWithString:liveShow.logoUrl];
    self.name = liveShow.name;
    self.city = liveShow.city;
    
    if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
        if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookThisTicket]
            || [[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeBookMonthlyTicket]) {
            _statusImageView.image = [UIImage imageNamed:@"live_show_bought_ticket"];
        } else {
            _statusImageView.image = [UIImage imageNamed:@"private_show_waiting"];
        }
    } else if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
        _statusImageView.image = [UIImage imageNamed:@"private_showing"];
    } else if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow]) {
        _statusImageView.image = [UIImage imageNamed:@"live_big_show"];
    } else {
        _statusImageView.image = nil;
    }
    
    NSInteger currentTicketCount = kQLLiveShowNumberOfTickers - liveShow.ticketInfos.count;
    [self setCurrentTicketCount:currentTicketCount withTotalCount:kQLLiveShowNumberOfTickers];
}
@end
