//
//  MoreMainViewController.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "IconDownLoader.h"
#import "MBProgressHUD.h"
#import "ShareAction.h"
@interface MoreMainViewController : UIViewController <CommandOperationDelegate,IconDownloaderDelegate,MBProgressHUDDelegate,ShareDelegate>{
    UIScrollView *mainScrollView;
    UIView *introductionView;
    UIView *moreView;
    UIActivityIndicatorView *spinner;
    CGFloat iconWidth;
    CGFloat iconHeight;
    
    UIButton *aboutButton;
    
    NSMutableArray *__listArray;
    
    NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
    UIImageView *numView;

}
@property (nonatomic, retain) UIScrollView *mainScrollView;
@property (nonatomic, retain) UIView *introductionView;
@property (nonatomic, retain) UIView *moreView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property (nonatomic, retain) ShareAction *ShareSheet;
//创建介绍视图
-(void)createIntroductionView;

//创建更多功能视图
-(void)createMoreView;

//关于我们
-(void)aboutUs;

//微博设置
-(void)weiboSet;

//在线反馈
-(void)feedback;

//推荐应用
-(void)recommendApp;

@end
