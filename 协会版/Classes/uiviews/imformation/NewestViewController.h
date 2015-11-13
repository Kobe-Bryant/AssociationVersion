//
//  NewestViewController.h
//  Profession
//
//  Created by LuoHui on 12-9-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "IconDownLoader.h"
#import "CommandOperation.h"

@interface NewestViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,IconDownloaderDelegate,CommandOperationDelegate> {
	UINavigationController *myNavigationController;
	UITableView *myTableView;
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	IconDownLoader *iconDownLoad;
	NSMutableArray *newsArray;
	NSNumber *catid;
	NSNumber *catversion;
	int operateType;
	BOOL isLoadMore;
    UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property (nonatomic,retain) UINavigationController *myNavigationController;
@property (nonatomic,retain) UITableView *myTableView;
@property (nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property (nonatomic,retain) IconDownLoader *iconDownLoad;
@property (nonatomic,retain) NSMutableArray *newsArray;
@property (nonatomic,retain) NSNumber *catid;
@property (nonatomic,retain) NSNumber *catversion;
@property (nonatomic,assign) BOOL isLoadMore;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) UILabel *moreLabel;

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

- (void)accessService;
- (void)accessMoreService;
- (void)update:(NSMutableArray*)resultArray;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;
- (void)loadImagesForOnscreenRows;
-(void)appendTableWith:(NSMutableArray *)data;
@end

