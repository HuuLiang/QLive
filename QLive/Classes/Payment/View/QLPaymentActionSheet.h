//
//  QLPaymentActionSheet.h
//  QLive
//
//  Created by Sean Yue on 2017/3/13.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QBOrderInfo.h>

typedef void (^QLPaymentSheetSelectionAction)(QBOrderPayType payType, id obj);

@interface QLPaymentActionSheet : UIView

@property (nonatomic,retain,readonly) NSArray *availablePayTypes;
@property (nonatomic,copy) QLPaymentSheetSelectionAction selectionAction;

- (instancetype)init __attribute__((unavailable("Use -initWithAvailablePayTypes: instead !")));
- (instancetype)initWithAvailablePayTypes:(NSArray *)payTypes payPoint:(QLPayPoint *)payPoint;
- (void)showInWindow;
- (void)hide;

@end
