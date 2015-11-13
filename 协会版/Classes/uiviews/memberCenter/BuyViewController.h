//
//  BuyViewController.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@interface BuyViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
           MBProgressHUDDelegate,CommandOperationDelegate,EGORefreshTableHeaderDelegate>
{
	UITableView *_buyTableView;
	NSMutableArray *__listArray;
    
    MBProgressHUD *progressHUD;

    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

    NSNumber *_listId;
    int rowValue;
               
    NSString *userIdStr;
    
    UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
               
}
@property (nonatomic, retain) UITableView *buyTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSString *userIdStr;
@property (nonatomic, assign) int rowValue;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *moreLabel;


- (id)init;
- (void)accessService;
- (void)accessMoreService;
- (void)getMoreAction;
- (void)update;
@end
