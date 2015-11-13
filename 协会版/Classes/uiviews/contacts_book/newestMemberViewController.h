//
//  newestMemberViewController.h
//  xieHui
//
//  Created by lai yun on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"
#import "IconDownLoader.h"
#import "DataManager.h"
#import "UAModalPanel.h"
#import "LoginViewController.h"
@interface newestMemberViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,IconDownloaderDelegate,CommandOperationDelegate,UAModalPanelDelegate,LoginViewDelegate> {
	UITableView *myTableView;
	NSMutableArray *memberItems;
    NSMutableArray *activeMember;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	int photoWith;
	int photoHigh;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	UIActivityIndicatorView *spinner;

    NSString *senderId;
    NSString *sourceName;
    NSString *sourceImage;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *memberItems;
@property(nonatomic,retain) NSMutableArray *activeMember;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;

@property(nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;
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

//网络获取数据
-(void)accessItemService;

//更新商铺的操作
-(void)updateMember;

//回归常态
-(void)backNormal;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;


@end

