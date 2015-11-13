//
//  SystemMessageViewController.h
//  xieHui
//
//  Created by LuoHui on 13-4-27.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CommandOperation.h"
#import "LoginViewController.h"
#import "EGORefreshTableHeaderView.h"
@interface SystemMessageViewController : UIViewController <CommandOperationDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    NSMutableArray *__listArray;
    
    UIActivityIndicatorView *indicatorView;
    BOOL _isLoadMore;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    UIActivityIndicatorView *spinner;

}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@end
