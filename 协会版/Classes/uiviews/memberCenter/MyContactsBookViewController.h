//
//  MyContactsBookViewController.h
//  xieHui
//
//  Created by 来 云 on 12-11-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
#import "DataManager.h"
#import "UAModalPanel.h"
#import "MBProgressHUD.h"
@interface MyContactsBookViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,CommandOperationDelegate,UAModalPanelDelegate,UISearchBarDelegate,UISearchDisplayDelegate,MBProgressHUDDelegate>
{
    UITableView *myTableView;
    UITableView *currentTableView;
	NSMutableArray *memberItems;
    NSMutableArray *allMemberItems;
    NSMutableArray *activeMember;
    NSMutableDictionary *dicMember;
    NSString *catId;
    NSMutableArray *keys;
	int photoWith;
	int photoHigh;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	UIActivityIndicatorView *spinner;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplay;
    
    NSString *senderId;
    NSString *sourceName;
    NSString *sourceImage;
    
    NSNumber *infoId;
    int rowValue;
    NSIndexPath *indexPathValue;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) UITableView *currentTableView;
@property(nonatomic,retain) NSMutableArray *memberItems;
@property(nonatomic,retain) NSMutableArray *allMemberItems;
@property(nonatomic,retain) NSMutableArray *activeMember;
@property(nonatomic,retain) NSMutableDictionary *dicMember;
@property(nonatomic,retain) NSString *catId;
@property(nonatomic,retain) NSMutableArray *keys;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property (retain) UISearchBar *searchBar;
@property (retain) UISearchDisplayController *searchDisplay;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;

@property (nonatomic, assign) int rowValue;
@property (nonatomic, retain) NSIndexPath *indexPathValue;
//添加数据表视图
-(void)addTableView:(CGRect)tableFrame;

//通讯录数据转化
-(void)makeMemberDictionary;

//更改自定义tabbar的位置
-(void)changeCustomTabBar:(BOOL)type;

//开始搜索数据
-(void)searching:(NSString *)keyword;

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
-(void)update;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
@end
