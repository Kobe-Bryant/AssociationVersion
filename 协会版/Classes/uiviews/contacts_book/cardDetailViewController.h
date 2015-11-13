//
//  cardDetailViewController.h
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
#import "DataManager.h"
#import "MBProgressHUD.h"

enum card_info {
    card_info_id,
    card_info_user_id,
    card_info_user_name,
    card_info_gender,
    card_info_post,
    card_info_company_name,
    card_info_tel,
    card_info_mobile,
    card_info_fax,
    card_info_email,
    card_info_cat_name,
    card_info_cat_id,
    card_info_province,
    card_info_city,
    card_info_district,
    card_info_address,
    card_info_img,
    card_info_created,
    card_info_url
};

@protocol cardDetailDelegate
@optional
- (void)feedbackButtonTouch;
- (void)favoriteButtonTouch;
- (void)urlButtonTouch:(NSString *)url;
@end

@interface cardDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,CommandOperationDelegate>{
    
    NSObject<cardDetailDelegate> *delegate;
    NSMutableArray *cardInfo;
    NSString *cUserId;
    BOOL isFavorite;
    UITableView *myTableView;
    NSString *userId;
    int photoWith;
	int photoHigh;
    NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    UIActivityIndicatorView *spinner;
    
    MBProgressHUD *progressHUD;
    
}
@property (nonatomic, assign) NSObject<cardDetailDelegate> *delegate;
@property(nonatomic,retain) NSMutableArray *cardInfo;
@property(nonatomic,retain) NSString *cUserId;
@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) MBProgressHUD *progressHUD;
//收藏
-(void)favorite;

//创建视图
-(void)createView;

//留言
-(void)feedback;

//跳转连接
-(void)goUrl:(NSString *)url;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//网络获取数据
-(void)accessItemService;

//更新数据
-(void)update:(NSMutableArray *)resultArray;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end
