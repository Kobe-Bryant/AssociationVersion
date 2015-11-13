//
//  SupplyDemandMainViewController.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LightMenuBarDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownLoader.h"
#import "MBProgressHUD.h"
#import "DataManager.h"

@interface SupplyDemandMainViewController : UIViewController<LightMenuBarDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,IconDownloaderDelegate,MBProgressHUDDelegate,CommandOperationDelegate> {
	int showType;		//1表示供应 2表示求购
	UITableView *myTableView;
    LightMenuBar *myMenuBar;
	NSMutableArray *supplyItems;
	NSMutableArray *demandItems;
	NSMutableArray *supplyCatItems;
	NSMutableArray *demandCatItems;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	int photoWith;
	int photoHigh;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	BOOL isFirstLoadingSupplyCat;
	BOOL isFirstLoadingDemandCat;
	MBProgressHUD *progressHUD;
	int cat_id;
	UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) LightMenuBar *myMenuBar;
@property(nonatomic,retain) NSMutableArray *supplyItems;
@property(nonatomic,retain) NSMutableArray *demandItems;
@property(nonatomic,retain) NSMutableArray *supplyCatItems;
@property(nonatomic,retain) NSMutableArray *demandCatItems;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) MBProgressHUD *progressHUD;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) UILabel *moreLabel;

//显示供应列表
-(void)showSupply;

//显示求购列表
-(void)showDemand;

//移出所有view
-(void)removeAllView;

//添加滚动分类导航
-(void)addCatNat;

//向左滚动
-(void)goLeft;

//向右滚动
-(void)goRight;

//添加数据表视图
-(void)addTableView;

//搜索
-(void)searchSupply;

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

//网络获取分类数据
-(void)accessCatService:(int)commandid;

//网络获取数据
-(void)accessItemService:(int)commandid accessVer:(int)ver;

//网络获取更多数据
-(void)accessMoreService:(int)commandid itemsUpdateTime:(int)itemUpdateTime;

//更新供应分类的操作
-(void)updateSupplyCat;

//更新求购分类的操作
-(void)updateDemandCat;

//更新供应的操作
-(void)updateSupply;

//更新求购的操作
-(void)updateDemand;

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data;

//移出提示层
-(void)removeprogressHUD;

//回归常态
-(void)backNormal;

//更多回归常态
-(void)moreBackNormal:(BOOL)isHaveMoreData;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;


@end
