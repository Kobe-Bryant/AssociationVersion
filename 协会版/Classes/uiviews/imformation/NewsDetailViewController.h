//
//  NewsDetailViewController.h
//  Profession
//
//  Created by MC374 on 12-8-21.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "MBProgressHUD.h"
#import "CommandOperation.h"
//#import "manageActionSheet.h"
#import "IconDownLoader.h"
//#import "CommandOperation.h"
//#import "SinaViewController.h"
//#import "TencentViewController.h"
#import "LoginViewController.h"
#import "ShareAction.h"  // dufu add 2013.04.25
// commandOperationDelegate,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate,
@interface NewsDetailViewController : UIViewController<HPGrowingTextViewDelegate,MBProgressHUDDelegate,UIScrollViewDelegate,IconDownloaderDelegate,CommandOperationDelegate,LoginViewDelegate,ShareDelegate> {
	UIScrollView *contentScrollView;
	UIView *containerView;
	HPGrowingTextView *textView;
	BOOL isFavorite;
    //manageActionSheet *actionSheet;
	IconDownLoader *iconDownLoad;
	UIImageView *newsImageView;
	UILabel *descLable;
	NSArray *detailArray;
	float totalheight;
	MBProgressHUD *progressHUDTmp;
	NSString *userId;
	int operateType;
    NSString *tempTextContent;
    NSString *commentTotal;
    UIBarButtonItem *barbutton;
    
    BOOL isFrom;
}
@property (nonatomic,assign) BOOL isFavorite;
@property (nonatomic,assign) float totalheight;
//@property (nonatomic,retain) manageActionSheet *actionSheet;
@property (nonatomic,retain) IconDownLoader *iconDownLoad;
@property (nonatomic,retain) NSArray *detailArray;
@property (nonatomic,retain) NSString *userId;
@property (nonatomic,assign) int operateType;
@property (nonatomic,retain) HPGrowingTextView *textView;
@property (nonatomic,retain) NSString *tempTextContent;
@property (nonatomic,retain) NSString *commentTotal;
@property (nonatomic, retain) UIBarButtonItem *barbutton;

@property (nonatomic, retain) ShareAction *ShareSheet; // dufu add 2013.04.25

@property (nonatomic,assign) BOOL isFrom;
- (void) addButtomBar;
- (void) doEditing;
- (void) publishComment:(id)sender;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;

-(void)hiddenKeyboard;
@end
