//
//  shopDetailViewController.h
//  Profession
//
//  Created by siphp on 12-8-21.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
#import "MBProgressHUD.h"
#import "DataManager.h"
//#import "manageActionSheet.h" 
//#import "weiboSetViewController.h"  // dufu mod 2013.04.25
//#import "TencentViewController.h"
#import "dragCardViewController.h"
#import "LoginViewController.h"

#import "ShareAction.h"    // dufu add 2013.04.25

// ,commandOperationDelegate ,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate
@interface shopDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,MBProgressHUDDelegate,CommandOperationDelegate,LoginViewDelegate,dragCardDelegate,LoginViewDelegate,ShareDelegate> {
	NSString *shopID;
	UIActivityIndicatorView *spinner;
	NSMutableArray *shopItems;
	int logoWith;
	int logoHigh;
	int photoWith;
	int photoHigh;
	UITableView *myTableView;
	NSMutableArray *supplyItems;
	NSMutableArray *demandItems;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	int showType;		//1表示供应 2表示求购
	//manageActionSheet *actionSheet;    // dufu mod 2013.04.25
	MBProgressHUD *progressHUD;
	BOOL isFavorite;
	NSString *userId;
    int lastContentOffsetY;
    int currentButtonTag;
    BOOL isAnimation;
    CGFloat fixHeight;
    UIButton *favoritebutton;
    dragCardViewController *dragCard;
    
    NSString *senderId;
    NSString *sourceName;
    NSString *sourceImage;
    BOOL isContactFavorite;
    
    UIView *segmentBg;
    
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property(nonatomic,retain) NSString *shopID;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) NSMutableArray *shopItems;
@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *supplyItems;
@property(nonatomic,retain) NSMutableArray *demandItems;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
//@property(nonatomic,retain) manageActionSheet *actionSheet;   // dufu mod 2013.04.25
@property(nonatomic,retain) MBProgressHUD *progressHUD;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) UIButton *favoritebutton;
@property(nonatomic,retain) dragCardViewController *dragCard;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;

@property(nonatomic,retain) UILabel *moreLabel;

@property (nonatomic, retain) ShareAction *ShareSheet; // dufu add 2013.04.25

//构建顶部布局
-(void)createTopView;

//构建拖拽名片
-(void)createDragCard;

//显示位置
-(void)showMapByCoord;

//拨打电话
-(void)callPhone;

//分享
-(void)share;

//收藏
-(void)favorite;

//切换按钮
-(void)buttonClick:(id)sender;

//顶部内容上下动画效果
-(void)topViewAnimation:(NSString *)type;

//移出contentView里面所有view
-(void)removeContentAllView;

//显示简介
-(void)showDesc;

//显示供应
-(void)showSupply;

//显示求购
-(void)showDemand;

//添加数据表视图
-(void)addTableView;

//滚动loading图片
- (void)loadImagesForOnscreenRows;

//获取图片链接
-(NSString*)getPhotoURL:(NSIndexPath *)indexPath;

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//网络商铺获取数据
-(void)accessShopItemService;

//网络获取数据
-(void)accessItemService:(int)commandid itemsUpdateTime:(int)itemUpdateTime;

//更新商铺的操作
-(void)updateShop;

//更新供应的操作
-(void)updateSupply;

//更新求购的操作
-(void)updateDemand;

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data;

//更多回归常态
-(void)moreBackNormal:(BOOL)isHaveMoreData;
//收藏成功
- (void)favoriteSuccess;

//收藏失败
- (void)favoriteFail;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end
