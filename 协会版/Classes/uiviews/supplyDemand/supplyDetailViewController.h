//
//  supplyDetailViewController.h
//  Profession
//
//  Created by siphp on 12-8-14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myImageView.h"
#import "IconDownLoader.h"
#import "HPGrowingTextView.h"
#import "MBProgressHUD.h"
#import "DataManager.h"
#import "LoginViewController.h"
//#import "manageActionSheet.h"    // dufu mod 2013.04.25
//#import "SinaViewController.h"
//#import "TencentViewController.h"

#import "ShareAction.h"  // dufu add 2013.04.25

// commandOperationDelegate,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate,
@interface supplyDetailViewController : UIViewController <UIScrollViewDelegate,myImageViewDelegate,IconDownloaderDelegate,HPGrowingTextViewDelegate,MBProgressHUDDelegate,CommandOperationDelegate,LoginViewDelegate,ShareDelegate>{
	NSString *supplyID;
	NSMutableArray *supplyArray;
	NSMutableArray *supplyPicArray;
	float supplyShowHeight;
	UIScrollView *scrollView;
	UIScrollView *showPicScrollView;
	UIPageControl *pageControll;
	int photoWith;
	int photoHigh;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	UIView *containerView;
    HPGrowingTextView *textView;
	NSString *tempTextContent;
	MBProgressHUD *progressHUD;
//	manageActionSheet *actionSheet;   // dufu mod 2013.04.25
	BOOL isFavorite;
	NSString *userId;
    int operateType;
    
    NSString *commentTotal;
    BOOL isFrom;
    UIBarButtonItem* barbutton;
}

@property(nonatomic,retain) NSString *supplyID;
@property(nonatomic,retain) NSMutableArray *supplyArray;
@property(nonatomic,retain) NSMutableArray *supplyPicArray;
@property(nonatomic,retain) UIScrollView *showPicScrollView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIPageControl *pageControll;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIView *containerView;
@property(nonatomic,retain) HPGrowingTextView *textView;
@property(nonatomic,retain) NSString *tempTextContent;
@property(nonatomic,retain) MBProgressHUD *progressHUD;
//@property(nonatomic,retain) manageActionSheet *actionSheet;   // dufu mod 2013.04.25
@property(nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *commentTotal;
@property (nonatomic,assign) BOOL isFrom;

@property (nonatomic, retain) ShareAction *ShareSheet; // dufu add 2013.04.25

//图片展示
-(void)showSupplyPic;

//保存缓存图片
-(BOOL)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//查看公司黄页
-(void)showCompany;

//拨打电话
-(void)callPhone;

//更改按钮
-(void)buttonChange:(BOOL)isKeyboardShow;

//发表评论
-(void)publishComment:(id)sender;

//分享
-(void)share;

//收藏
-(void)favorite;

//编辑中
-(void)doEditing;

//关闭键盘
-(void)hiddenKeyboard;

//评论成功
- (void)commentSuccess:(NSMutableArray *)resultArray;

//收藏成功
- (void)favoriteSuccess;

//收藏失败
- (void)favoriteFail;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
@end
