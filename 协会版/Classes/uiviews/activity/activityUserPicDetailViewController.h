//
//  activityUserPicDetailViewController
//  Profession
//
//  Created by siphp on 12-8-14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myImageView.h"
#import "IconDownLoader.h"
#import "DataManager.h"
#import "MBProgressHUD.h"

@interface activityUserPicDetailViewController : UIViewController <UIScrollViewDelegate,myImageViewDelegate,IconDownloaderDelegate,CommandOperationDelegate,MBProgressHUDDelegate,UIGestureRecognizerDelegate>{
	NSMutableArray *picArray;
	UIScrollView *showPicScrollView;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    int photoWith;
	int photoHigh;
	int chooseIndex;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
    MBProgressHUD *progressHUD;
    int tapOnce;
}

@property(nonatomic,retain) NSMutableArray *picArray;
@property(nonatomic,retain) UIScrollView *showPicScrollView;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,assign) int photoWith;
@property(nonatomic,assign) int photoHigh;
@property(nonatomic,assign) int chooseIndex;
@property(nonatomic,retain) MBProgressHUD *progressHUD;

//图片展示
-(void)showPic;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//追加用户图片
-(void)appendUserPic:(NSMutableArray *)data;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end
