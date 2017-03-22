//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAlbumModel;
@interface TZPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) TZAlbumModel *model;
// By SeanYue
@property (nonatomic) BOOL allowPreview;

// End by SeanYue

@property (nonatomic, copy) void (^backButtonClickHandle)(TZAlbumModel *model);

@end


@interface TZCollectionView : UICollectionView

@end
