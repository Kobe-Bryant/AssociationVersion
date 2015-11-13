//
//  InformationViewController.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownLoader.h"
#import "MBProgressHUD.h"

@interface InformationViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
          MBProgressHUDDelegate,CommandOperationDelegate,EGORefreshTableHeaderDelegate,IconDownloaderDelegate>
{
	UITableView *_informationTableView;
	NSMutableArray *__listArray;

	MBProgressHUD *progressHUD;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
	
	NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
	
	NSNumber *_listId;
	int rowValue;
	BOOL _isLoadMore;
			  
	NSString *userIdStr;
    
    UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}
@property (nonatomic, retain) UITableView *informationTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property (nonatomic, retain) NSString *userIdStr;
@property (nonatomic, assign) int rowValue;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *moreLabel;

- (id)init;
- (void)accessService;
- (void)accessMoreService;
- (void)getMoreAction;
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index;
@end
