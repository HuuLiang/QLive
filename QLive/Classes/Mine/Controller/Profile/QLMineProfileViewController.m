//
//  QLMineProfileViewController.m
//  QLive
//
//  Created by Sean Yue on 2017/3/2.
//  Copyright © 2017年 iqu8. All rights reserved.
//

#import "QLMineProfileViewController.h"
#import "QLMineProfileCell.h"
#import <ActionSheetStringPicker.h>
#import "QLTextFieldViewController.h"
#import "TZImagePickerController.h"

typedef NS_ENUM(NSUInteger, QLProfileRow) {
    AvatarRow,
    NicknameRow,
    GenderRow,
    ProfileRowCount
};

@interface QLMineProfileViewController ()
{
    QLMineProfileCell *_avatarCell;
    QLMineProfileCell *_nickNameCell;
    QLMineProfileCell *_genderCell;
}
@property (nonatomic,retain) QLUser *user;
@property (nonatomic,retain) UIImage *selectedAvatarImage;
@end

@implementation QLMineProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改资料";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave)];
    self.user = [QLUser currentUser].copy;
    
    _avatarCell = [[QLMineProfileCell alloc] init];
    _avatarCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _avatarCell.title = @"头像";
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.user.logoUrl];
    _avatarCell.detailImage = image ?: [UIImage imageNamed:@"mine_avatar"];
    
    _nickNameCell = [[QLMineProfileCell alloc] init];
    _nickNameCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _nickNameCell.title = @"昵称";
    _nickNameCell.subtitle = self.user.name;
    
    _genderCell = [[QLMineProfileCell alloc] init];
    _genderCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _genderCell.title = @"性别";
    _genderCell.subtitle = self.user.genderString;
    
    self.cells = @{[NSIndexPath indexPathForRow:AvatarRow inSection:0]:_avatarCell,
                   [NSIndexPath indexPathForRow:NicknameRow inSection:0]:_nickNameCell,
                   [NSIndexPath indexPathForRow:GenderRow inSection:0]:_genderCell};
    self.cellHeights = @{[NSIndexPath indexPathForRow:AvatarRow inSection:0]:@(88)};
    self.defaultCellHeight = MAX(44, kScreenHeight * 0.08);
    
    @weakify(self);
    self.didSelectCellAction = ^(NSIndexPath *indexPath, UITableViewCell *cell) {
        @strongify(self);
        QLMineProfileCell *profileCell = (QLMineProfileCell *)cell;
        if (indexPath.row == AvatarRow) {
            TZImagePickerController *pickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
            pickerController.allowPickingOriginalPhoto = NO;

            pickerController.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto) {
                
                @strongify(self);
                TZImagePickerController *cropController = [[TZImagePickerController alloc] initCropTypeWithAsset:assets.firstObject photo:photos.firstObject completion:^(UIImage *cropImage, id asset) {
                    @strongify(self);
                    self.selectedAvatarImage = cropImage;
                }];
                cropController.cropRect = CGRectMake(0, 0, kScreenWidth *0.75, kScreenWidth *0.75);
                cropController.needCircleCrop = YES;
                cropController.circleCropRadius = cropController.cropRect.size.width/2;
                [self presentViewController:cropController animated:YES completion:nil];
                
            };
            [self presentViewController:pickerController animated:YES completion:nil];
        } else if (indexPath.row == NicknameRow) {
            QLTextFieldViewController *editVC = [[QLTextFieldViewController alloc] initWithText:profileCell.subtitle placeholder:@"输入昵称" maxLength:12 didFinishAction:^BOOL(NSString *nickName, id obj)
            {
                @strongify(self);

                if (self) {
                    self.user.name = nickName;
                    profileCell.subtitle = nickName;
                }
                
                return YES;
            }];
            [self.navigationController pushViewController:editVC animated:YES];
            
        } else if (indexPath.row == GenderRow) {
            NSArray *rows = @[@"男",@"女"];
            NSInteger selectedIndex = [profileCell.subtitle isEqualToString:@"女"] ? 1 : 0;
            
            [ActionSheetStringPicker showPickerWithTitle:@"选择性别"
                                                    rows:rows
                                        initialSelection:selectedIndex
                                               doneBlock:^(ActionSheetStringPicker *picker,
                                                           NSInteger selectedIndex,
                                                           id selectedValue)
             {
                 @strongify(self);
                 profileCell.subtitle = selectedValue;
                 self.user.gender = [selectedValue isEqualToString:@"女"] ? kQLUserGenderFemale : kQLUserGenderMale;
             } cancelBlock:nil origin:self.view];
        }
    };
}

- (void)onSave {
    @weakify(self);
    
    
    if (self.selectedAvatarImage) {
        [[QLHUDManager sharedManager] showLoading];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *docUrl = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
//            NSURL *imageURL = [[NSURL alloc] initWithString:kQLAvatarImage relativeToURL:docUrl];//[NSURL fileURLWithPath:kQLAvatarImage relativeToURL:docUrl];
            
            NSString *imageURLString = [NSString stringWithFormat:@"%@/%@", docUrl.path, kQLAvatarImage];
            BOOL success = [UIImageJPEGRepresentation(self.selectedAvatarImage, 0.5) writeToFile:imageURLString atomically:YES];;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[QLHUDManager sharedManager] showSuccess:success?@"保存成功":@"保存失败"];
                
                if (success) {
                    self.user.logoUrl = imageURLString;
                    [self.user saveAsCurrentUser];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        });
    } else {
        [[QLHUDManager sharedManager] showLoadingInfo:@"保存中..." withDuration:3 isSucceeded:YES complete:^NSString*(void){
            @strongify(self);
            [self.user saveAsCurrentUser];
            [self.navigationController popViewControllerAnimated:YES];
            return @"保存成功";
        }];
    }
    
}

- (void)setSelectedAvatarImage:(UIImage *)selectedAvatarImage {
    _selectedAvatarImage = selectedAvatarImage;
    _avatarCell.detailImage = selectedAvatarImage;
}

//- (void)onSelectAvatarImage:(UIImage *)image {
//    self.selectedAvatarImage = image;
//    _avatarCell.detailImage = image;
//    
//    [[QLHUDManager sharedManager] showLoading];
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSURL *docUrl = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
//        NSString *imagePath = [NSString stringWithFormat:@"%@/%@", docUrl.absoluteString, kQLAvatarImage];
//        
//        BOOL success = [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (success) {
//                [QLHUDManager sharedManager] showSuccess:@"头像保存成功";
//            } else {
//                
//            }
//        });
//    });
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
