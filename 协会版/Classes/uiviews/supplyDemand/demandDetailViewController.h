//
//  demandDetailViewController.h
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

@interface demandDetailViewController : UIViewController<UIScrollViewDelegate,myImageViewDelegate,IconDownloaderDelegate,HPGrowingTextViewDelegate,MBProgressHUDDelegate,CommandOperationDelegate,LoginViewDelegate> {
	NSString *demandID;
	NSMutableArray *demandArray;
	NSMutableArray *demandPicArray;
	float demandShowHeight;
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
	BOOL isFavorite;
	NSString *userId;
    int operateType;
    
    NSString *commentTotal;
    UIBarButtonItem *barbutton;
    BOOL isFrom;
}

@property(nonatomic,retain) NSString *demandID;
@property(nonatomic,retain) NSMutableArray *demandArray;
@property(nonatomic,retain) NSMutableArray *demandPicArray;
@property(nonatomic,retain) UIScrollView *showPicScrollView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIPageControl *pageControll;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIView *containerView;
@property(nonatomic,retain) HPGrowingTextView *textView;
@property(nonatomic,retain) NSString *tempTextContent;
@property(nonatomic,retain) MBProgressHUD *progressHUD;
@property(nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *commentTotal;
@property (nonatomic,assign) BOOL isFrom;

//图片展示
-(void)showdemandPic;

//保存缓存图片
-(BOOL)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//拨打电话
-(void)callPhone;

//更改按钮
-(void)buttonChange:(BOOL)isKeyboardShow;

//发表回复
-(void)publishReply:(id)sender;

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
