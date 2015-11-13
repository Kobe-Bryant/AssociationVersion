//
//  FirsetPageViewController.h
//  Profession
//
//  Created by MC374 on 12-8-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "myImageView.h"
#import "AutoScrollView.h"
#import "CommandOperation.h"
#import "IconDownLoader.h"
#import "EGORefreshTableHeaderView.h"
#import "UAModalPanel.h"
#import "LoginViewController.h"
@class MBProgressHUD;

@interface FirsetPageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,myImageViewDelegate,AutoScrollViewDelegate,CommandOperationDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,UAModalPanelDelegate,LoginViewDelegate> {
	UIScrollView *mainScrollView;
	UINavigationController *myNavigationController;
	UITableView *myTableView;
	UIScrollView *bannerScrollView;
	UIPageControl *pageControll;
	int totalheight;
	NSMutableArray *adPicArray;
	AutoScrollView *adScrollView;
	NSArray *topAdArray;
	NSArray *footAdArray;
	NSArray *recommendNewsArray;
	NSArray *activeMember;
	
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
	IconDownLoader *iconDownLoad;
	
	MBProgressHUD *progressHUD;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    UIScrollView *recommendScrollView;
    
    NSString *senderId;
    NSString *sourceImage;
}

@property (nonatomic,retain) UINavigationController *myNavigationController;
@property (nonatomic,retain) UITableView *myTableView;
@property (nonatomic,retain) UIScrollView *mainScrollView;
@property (nonatomic,retain) NSMutableArray *adPicArray;
@property (nonatomic,retain) AutoScrollView *adScrollView;
@property (nonatomic,assign) int totalheight;
@property (nonatomic,retain) NSArray *topAdArray;
@property (nonatomic,retain) NSArray *footAdArray;
@property (nonatomic,retain) NSArray *recommendNewsArray;
@property (nonatomic,retain) NSArray *activeMember;

@property (nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property (nonatomic,retain) IconDownLoader *iconDownLoad;
@property (nonatomic,retain) UIScrollView *recommendScrollView;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;

- (void) handleFunction:(id) sender;
- (void) update;
- (void)accessService;
- (void)accessRecommentService;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;
@end
