//
//  MemberEditViewController.h
//  xieHui
//
//  Created by 来 云 on 12-10-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "EPUploader.h"
#import "MBProgressHUD.h"
#import "CommandOperation.h"
#import "TSLocateView.h"
@interface MemberEditViewController : UITableViewController <UIGestureRecognizerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,IconDownloaderDelegate,CommandOperationDelegate,MBProgressHUDDelegate,EPUploaderDelegate,UINavigationControllerDelegate>
{
    UIImageView *memberHeaderView;
    
    UITextField *_nameTextField;
    UITextField *_sexTextField;
    UITextField *_postTextField;
    UITextField *_companyTextField;
    UITextField *_phoneTextField;
    UITextField *_emailTextField;
    UITextField *_urlTextField;
    UITextField *_addrTextField;
    UITextField *_addressTextField;
    
    NSString *_nameTempContent;
    NSString *_sexTempContent;
    NSString *_postTempContent;
    NSString *_companyTempContent;
    NSString *_phoneTempContent;
    NSString *_emailTempContent;
    NSString *_urlTempContent;
    NSString *_addrTempContent;
    NSString *_addressTempContent;
    
    UIPickerView *pickerview;
    NSArray *content;
    
    IconDownLoader *iconDownLoad;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    
    EPUploader *upload;
	UIImage *scaleImage;
    
    MBProgressHUD *mbProgressHUD;
    
    NSMutableArray *itemArray;
    
    UIActionSheet *_actionSheet;
    
    NSString *provinceStr;
    NSString *cityStr;
    NSString *districtStr;
    
    NSString *sexValue;
}
@property (nonatomic, retain) UIImageView *memberHeaderView;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *sexTextField;
@property (nonatomic, retain) UITextField *postTextField;
@property (nonatomic, retain) UITextField *companyTextField;
@property (nonatomic, retain) UITextField *phoneTextField;
@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, retain) UITextField *urlTextField;
@property (nonatomic, retain) UITextField *addrTextField;
@property (nonatomic, retain) UITextField *addressTextField;

@property (nonatomic, retain) NSString *nameTempContent;
@property (nonatomic, retain) NSString *sexTempContent;
@property (nonatomic, retain) NSString *postTempContent;
@property (nonatomic, retain) NSString *companyTempContent;
@property (nonatomic, retain) NSString *phoneTempContent;
@property (nonatomic, retain) NSString *emailTempContent;
@property (nonatomic, retain) NSString *urlTempContent;
@property (nonatomic, retain) NSString *addrTempContent;
@property (nonatomic, retain) NSString *addressTempContent;

@property (nonatomic, retain) EPUploader *upload;
@property (nonatomic, retain) UIImage *scaleImage;
@property (nonatomic, retain) MBProgressHUD *mbProgressHUD;
@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic, retain) NSString *sexValue;

- (NSString *)checkTelNumberFormart:(NSString *)phoneNumber;
@end
