//
//  activityViewController.h
//  xieHui
//
//  Created by siphp on 13-4-25.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "myImageView.h"
#import "IconDownLoader.h"
#import "activityView.h"

@interface activityViewController : UIViewController<UIScrollViewDelegate,CommandOperationDelegate,myImageViewDelegate,IconDownloaderDelegate,activityViewDelegate>
{
    UIActivityIndicatorView *spinner;
    UIScrollView *activityScrollView;
    UIPageControl *pageControll;
    NSMutableArray *activityItems;
    CGFloat scrollWidth;
    CGFloat scrollHeight;
    CGFloat picWidth;
    CGFloat picHeight;
    NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
}

@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) UIScrollView *activityScrollView;
@property(nonatomic,retain) UIPageControl *pageControll;
@property(nonatomic,retain) NSArray *activityItems;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;

//添加活动列表
-(void)addActivityScrollView;

//活动点击
-(void)buttonAction:(id)sender;

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath;

//获取网络图片
-(void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath;

//回调 获到网络图片后的回调函数
-(void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type;

//网络获取数据
-(void)accessItemService;

//更新数据
-(void)update;

//回归常态
-(void)backNormal;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end
