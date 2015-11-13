//
//  MenberCenterMainViewController.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "CommandOperation.h"
@class ProductViewController;
@class BuyViewController;
@class ShopsViewController;
@class InformationViewController;
@class LoginViewController;

@protocol MenberCenterMainViewControllerDelegate<NSObject>

- (void)actionButtonIndex:(int)index imageView:(UIImageView *)imgView;

@end

@interface MenberCenterMainViewController : UIViewController  <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,IconDownloaderDelegate,UINavigationControllerDelegate,CommandOperationDelegate>
{
    UIScrollView *_mainScrollView;
	UIImageView *memberHeaderView;
	NSString *memberName;
	NSString *memberLevel;
	
	IconDownLoader *iconDownLoad;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	
	ProductViewController *productViewController;
	BuyViewController *buyViewController;
	ShopsViewController *shopsViewController;
	InformationViewController *infoViewController;
	
	LoginViewController *_loginViewController;
	id <MenberCenterMainViewControllerDelegate> delegate;
    
    UIImageView *msgView;
    UILabel *msgLabel;
}
@property (nonatomic, retain) UIScrollView *mainScrollView;
@property (nonatomic, retain) UIImageView *memberHeaderView;
@property (nonatomic, retain) NSString *memberName;
@property (nonatomic, retain) NSString *memberLevel;
@property (nonatomic, retain) ProductViewController *productViewController;
@property (nonatomic, retain) BuyViewController *buyViewController;
@property (nonatomic, retain) ShopsViewController *shopsViewController;
@property (nonatomic, retain) InformationViewController *infoViewController;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property(nonatomic, retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, assign) id <MenberCenterMainViewControllerDelegate> delegate;
- (void)changeImage;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;
- (void)viewAppearAction;
- (void)cancelAction;
- (void)didSelectAction:(UIButton *)btn;
@end
