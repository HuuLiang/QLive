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
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.forceRoundCorner = YES;
        [self addSubview:_avatarImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _nameLabel.font = kMediumFont;
        [self addSubview:_nameLabel];
        
        _locIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_location"]];
        _locIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_locIconImageView];
        
        _cityLabel = [[UILabel alloc] init];
        _cityLabel.textColor = _nameLabel.textColor;
        _cityLabel.font = _nameLabel.font;
        [self addSubview:_cityLabel];
        
        _roomIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_icon"]];
        _roomIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_roomIconImageView];
        
        _roomLabel = [[UILabel alloc] init];
        _roomLabel.font = _nameLabel.font;
        _roomLabel.textColor = _nameLabel.textColor;
        _roomLabel.text = @"一对多房间";
        [self addSubview:_roomLabel];
        
        _ticketIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_person"]];
        _ticketIconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_ticketIconImageView];
        
        _ticketLabel = [[UILabel alloc] init];
        _ticketLabel.font = _roomLabel.font;
        _ticketLabel.textColor = _roomLabel.textColor;
        [self setCurrentTicketCount:0 withTotalCount:0];
        [self addSubview:_ticketLabel];
        
        _statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private_show_waiting"]];
        _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_statusImageView];
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor colorWithHexString:@"#d6d6d6"];
        [self addSubview:_separator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat fullWidth = CGRectGetWidth(self.bounds);
    const CGFloat fullHeight = CGRectGetHeight(self.bounds);
    
    const CGFloat avatarHeight = fullHeight * 0.4;
    const CGFloat avatarWidth = avatarHeight;
    const CGFloat avatarX = 10;
    const CGFloat avatarY = fullHeight/2 - avatarHeight;
    _avatarImageView.frame = CGRectMake(avatarX, avatarY, avatarWidth, avatarHeight);
    
    const CGFloat nameHeight = _nameLabel.font.pointSize;
    const CGFloat nameX = CGRectGetMaxX(_avatarImageView.frame)+8;
    const CGFloat nameY = _avatarImageView.center.x - nameHeight / 2;
    const CGFloat nameWidth = fullWidth/2 - nameX;
    _nameLabel.frame = CGRectMake(nameX, nameY, nameWidth, nameHeight);
    
    const CGFloat locImageX = fullWidth / 2 + 5;
    const CGFloat locImageHeight = _cityLabel.font.pointSize;
    const CGFloat locImageY = _nameLabel.center.y - locImageHeight/2;
    const CGFloat locImageWidth = locImageHeight;
    _locIconImageView.frame = CGRectMake(locImageX, locImageY, locImageWidth, locImageHeight);
    
    const CGFloat cityX = CGRectGetMaxX(_locIconImageView.frame) + 5;
    const CGFloat cityY = nameY;
    const CGFloat cityWidth = fullWidth - cityX - 15;
    const CGFloat cityHeight = _cityLabel.font.pointSize;
    _cityLabel.frame = CGRectMake(cityX, cityY, cityWidth, cityHeight);
    
    const CGFloat roomIconWidth = _avatarImageView.frame.size.width * 0.4;
    const CGFloat roomIconHeight = roomIconWidth;
    const CGFloat roomIconX = _avatarImageView.center.x - roomIconWidth / 2;
    const CGFloat roomIconY = CGRectGetMaxY(_avatarImageView.frame) + 10;
    _roomIconImageView.frame = CGRectMake(roomIconX, roomIconY, roomIconWidth, roomIconHeight);
    
    const CGFloat roomX = nameX;
    const CGFloat roomHeight = _roomLabel.font.pointSize;
    const CGFloat roomWidth = nameWidth;
    const CGFloat roomY = _roomIconImageView.center.y - roomHeight / 2;
    _roomLabel.frame = CGRectMake(roomX, roomY, roomWidth, roomHeight);
    
    const CGFloat ticketImageHeight = roomHeight;
    const CGFloat ticketImageWidth = ticketImageHeight;
    const CGFloat ticketImageX = locImageX;
    const CGFloat ticketImageY = _roomLabel.center.y - ticketImageHeight/2;
    _ticketIconImageView.frame = CGRectMake(ticketImageX, ticketImageY, ticketImageWidth, ticketImageHeight);
    
    const CGFloat ticketX = cityX;
    const CGFloat ticketHeight = _ticketLabel.font.pointSize;
    const CGFloat ticketWidth = cityWidth;
    const CGFloat ticketY = _ticketIconImageView.center.y - ticketHeight/2;
    _ticketLabel.frame = CGRectMake(ticketX, ticketY, ticketWidth, ticketHeight);
    
    const CGFloat statusHeight = 27;
    const CGFloat statusWidth = statusHeight * 3;
    const CGFloat statusX = fullWidth - 10 - statusWidth;
    const CGFloat statusY = (fullHeight - statusHeight)/2;
    _statusImageView.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    
    _separator.frame = CGRectMake(0, fullHeight-1, fullWidth, 1);
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
    NSString *totalCountString = [NSString stringWithFormat:@"%ld", (unsigned long)totalCount];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%@", (unsigned long)currentTicketCount, totalCountString]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attrString.length-totalCountString.length, totalCountString.length)];
    _ticketLabel.attributedText = attrString;
}

- (void)setLiveShow:(QLLiveShow *)liveShow {
    _liveShow = liveShow;
    
    self.avatarURL = [NSURL URLWithString:liveShow.logoUrl];
    self.name = liveShow.name;
    self.city = liveShow.city;
    
    if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePublic]) {
        _statusImageView.image = [UIImage imageNamed:@"private_show_waiting"];
    } else if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypePrivate]) {
        if ([[QLPaymentManager sharedManager] contentIsPaidWithContentId:@(liveShow.liveId.integerValue) contentType:QLPaymentContentTypeJumpQueue]) {
            _statusImageView.image = [UIImage imageNamed:@"live_big_show"];
        } else {
            _statusImageView.image = [UIImage imageNamed:@"private_showing"];
        }
    } else if ([liveShow.anchorType isEqualToString:kQLLiveShowAnchorTypeBigShow]) {
        _statusImageView.image = [UIImage imageNamed:@"live_big_show"];
    } else {
        _statusImageView.image = nil;
    }
    
    NSInteger currentTicketCount = kQLLiveShowNumberOfTickers - liveShow.ticketInfos.count;
    [self setCurrentTicketCount:currentTicketCount withTotalCount:kQLLiveShowNumberOfTickers];
}
@end
