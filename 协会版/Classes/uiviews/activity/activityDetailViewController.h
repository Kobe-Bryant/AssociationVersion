//
//  activityDetailViewController.h
//  xieHui
//
//  Created by siphp on 13-5-6.
//
//

#import <UIKit/UIKit.h>
#import "myImageView.h"
#import "IconDownLoader.h"
#import "LoginViewController.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import "ShareAction.h" // dufu add 2013.05.10

enum loginCallBackType {
    loginCallBackOpenCamera,
    loginCallBackJoin
};

@interface activityDetailViewController : UIViewController<UIScrollViewDelegate,myImageViewDelegate,IconDownloaderDelegate,LoginViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CommandOperationDelegate,MBProgressHUDDelegate,UIActionSheetDelegate,ShareDelegate>
{
    UIActivityIndicatorView *spinner;
    MBProgressHUD *progressHUD;
    UIScrollView *mainScrollView;
    UIScrollView *picScrollView;
    UIScrollView *userPicScrollView;
    UIPageControl *pageControll;
    UIImagePickerController *imagePickerController;
    UIView *toolBar;
    UILabel *userPicNumLable;
    UIButton *interestButton;
    UILabel *interestTitleLabel;
    UILabel *interestLabel;
    UIImageView *interestImageView;
    UIButton *joinButton;
    UILabel *joinTitleLabel;
    UILabel *joinLabel;
    UIImageView *joinImageView;
    NSArray *activityArray;
    NSMutableArray *picArray;
    NSMutableArray *userPicArray;
    CGFloat picWidth;
    CGFloat picHeight;
    CGFloat userPicWidth;
    CGFloat userPicHeight;
    NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    NSString *userId;
    int userPicNum;
    int callBackTpye;
    BOOL status;
    BOOL isInterested;
    BOOL isJoin;
    BOOL isEndJoin;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) MBProgressHUD *progressHUD;
@property(nonatomic,retain) UIScrollView *mainScrollView;
@property(nonatomic,retain) UIScrollView *picScrollView;
@property(nonatomic,retain) UIScrollView *userPicScrollView;
@property(nonatomic,retain) UIPageControl *pageControll;
@property(nonatomic,retain) UIImagePickerController *imagePickerController;
@property(nonatomic,retain) UIView *toolBar;
@property(nonatomic,retain) UILabel *userPicNumLable;
@property(nonatomic,retain) UIButton *interestButton;
@property(nonatomic,retain) UILabel *interestTitleLabel;
@property(nonatomic,retain) UILabel *interestLabel;
@property(nonatomic,retain) UIImageView *interestImageView;
@property(nonatomic,retain) UIButton *joinButton;
@property(nonatomic,retain) UILabel *joinTitleLabel;
@property(nonatomic,retain) UILabel *joinLabel;
@property(nonatomic,retain) UIImageView *joinImageView;
@property(nonatomic,retain) NSArray *activityArray;
@property(nonatomic,retain) NSMutableArray *picArray;
@property(nonatomic,retain) NSMutableArray *userPicArray;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) NSString *userId;
@property (nonatomic, retain) ShareAction *ShareSheet; // dufu add 2013.05.10

//添加主视图
-(void)addMainScrollView;

//添加下bar
-(void)addToolBar;

//拨打电话
-(void)callPhone;

//显示位置
-(void)showMapByCoord;

//点击摄像头按钮
-(void)cameraButtonClick;

//打开摄像头
-(void)openCamera;

//打开图片库
-(void)openPhotoLibrary;

//打开图片库
-(void)reportUrl;

//查找名字为name的子类
-(UIView *)findView:(UIView *)aView withName:(NSString *)name;

//感兴趣
-(void)interest:(id)sender;

//参加
-(void)join:(id)sender;

//取消参加
-(void)accessJoinService:(int)type;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//网络获取更多数据
-(void)accessPicMoreService;

//回归常态
-(void)backNormal;

//插入第一张用户图片
-(void)insertUserPic:(NSNotification *)note;

//追加用户图片
-(void)appendUserPic:(NSMutableArray *)data;

//感兴趣成功
- (void)didFinishInterest:(NSMutableArray *)data;

//参加成功
- (void)didFinishJoin:(NSMutableArray *)data;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end
