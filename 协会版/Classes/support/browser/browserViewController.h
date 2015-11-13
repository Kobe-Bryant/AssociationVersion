//
//  browserViewController.h
//  Profession
//
//  Created by siphp on 12-8-25.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareAction.h"  // dufu add 2013.04.25

// commandOperationDelegate,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate
@interface browserViewController : UIViewController<UIWebViewDelegate,ShareDelegate,UIGestureRecognizerDelegate>
{
	UIWebView *webView;
    NSString *titleString;
	NSString *url;
    NSString *webTitle;
    UIImage *shareImage;
	UIActivityIndicatorView *spinner;
    BOOL isShowTool;
    
    BOOL isshare;
    BOOL isSignFlag;
}

@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic,retain) NSString *titleString;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,retain) NSString *webTitle;
@property(nonatomic,retain) UIImage *shareImage;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,assign) BOOL isShowTool;

@property (nonatomic, retain) ShareAction *ShareSheet; // dufu add 2013.04.25
// 手势是否开启  yes 开启  NO不开启
@property (nonatomic, assign) BOOL isSignFlag;// dufu add 2013.05.22

//工具栏
-(void)showToolBar;

//功能按钮
-(void)buttonClick:(id)sender;

//分享
-(void)share;

//刷新
-(void)reload;

@end
