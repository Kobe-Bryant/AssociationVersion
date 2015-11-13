//
//  ProductViewController.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "IconDownLoader.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@interface ProductViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
        MBProgressHUDDelegate,CommandOperationDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate>
{
	UITableView *_productTableView;
	NSMutableArray *__listArray;

	NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	
	NSArray *__dbArray;
	
	MBProgressHUD *progressHUD;
			
	NSNumber *_supplyId;
    int rowValue;
	BOOL _isLoadMore;
			
	NSString *userIdStr;
    
    UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}
@property (nonatomic, retain) UITableView *productTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property (nonatomic, retain) NSArray *dbArray;
@property (nonatomic, retain) NSString *userIdStr;
@property (nonatomic, assign) int rowValue;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *moreLabel;

- (id)init;
- (void)accessService;
- (void)accessMoreService;
- (void)getMoreAction;
- (void)update;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;
@end
