//
//  SearchMemberResultViewController.h
//  xieHui
//
//  Created by lai yun on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
#import "DataManager.h"
#import "UAModalPanel.h"
#import "LoginViewController.h"
@interface SearchMemberResultViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,CommandOperationDelegate,UAModalPanelDelegate,LoginViewDelegate> {
	UITableView *myTableView;
	NSMutableArray *memberItems;
    NSMutableArray *activeMember;
	int photoWith;
	int photoHigh;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	UIActivityIndicatorView *spinner;
    NSString *keyString;
    
    NSString *senderId;
    NSString *sourceName;
    NSString *sourceImage;
    
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *memberItems;
@property(nonatomic,retain) NSMutableArray *activeMember;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) NSString *keyString;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;
@property(nonatomic,retain) UILabel *moreLabel;

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

//网络获取更多数据
-(void)accessMoreService:(int)infoId;

//更新商铺的操作
-(void)updateMember;

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data;

//更多回归常态
-(void)moreBackNormal:(BOOL)isHaveMoreData;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;


@end