//
//  Login_feedbackViewController.h
//  xieHui
//
//  Created by LuoHui on 13-4-24.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "IconDownLoader.h"
#import "CommandOperation.h"
#import "HPGrowingTextView.h"
#import "LoginViewController.h"
#import "alertCardViewController.h"
#import "UAModalPanel.h"
#import "EGORefreshTableHeaderView.h"
@interface Login_feedbackViewController : UIViewController <MBProgressHUDDelegate,CommandOperationDelegate,UIGestureRecognizerDelegate,HPGrowingTextViewDelegate,UITableViewDelegate,UITableViewDataSource,UAModalPanelDelegate,LoginViewDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    NSMutableArray *__listArray;
    NSString *sourceStr;
    NSString *sourceName;
    NSString *sourceImage;
    
    MBProgressHUD *progressHUD;
    
    NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
    
    UIView *containerView;
    HPGrowingTextView *textView;
    NSString *tempTextContent;
    
    UIActivityIndicatorView *indicatorView;
    BOOL _isLoadMore;
    
    alertCardViewController *cardCard;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSString *sourceStr;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceImage;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property (nonatomic, retain) NSString *tempTextContent;

@property (nonatomic, retain) alertCardViewController *cardCard;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;

@end
