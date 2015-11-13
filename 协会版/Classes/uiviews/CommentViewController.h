//
//  CommentViewController.h
//  Profession
//
//  Created by LuoHui on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "MBProgressHUD.h"
#import "HPGrowingTextView.h"
#import "LoginViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface CommentViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,CommandOperationDelegate,MBProgressHUDDelegate,HPGrowingTextViewDelegate,LoginViewDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView *_myTableView;
	NSMutableArray *__listArray;

    NSString *_type;
    NSString *_infoId;
    NSString *infoTitle;
    
    MBProgressHUD *progressHUD;
    UIView *containerView;
    HPGrowingTextView *textView;
    NSString *tempTextContent;
    NSString *userId;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    UIBarButtonItem *button;
    
    BOOL isFromSuper;
    
    UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;

}
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSString *_type;
@property (nonatomic, retain) NSString *_infoId;
@property (nonatomic, retain) NSString *infoTitle;
@property (nonatomic, retain) NSString *tempTextContent;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) UIBarButtonItem *button;
@property (nonatomic, assign) BOOL isFromSuper;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *moreLabel;

-(void)publishComment:(id)sender;
@end
