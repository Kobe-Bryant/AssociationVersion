//
//  RegisterViewController.h
//  Profession
//
//  Created by MC374 on 12-8-18.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CommandOperation.h"

@protocol registerViewDelegate <NSObject>

- (void)registerSuccess;

@end

@interface RegisterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate, MBProgressHUDDelegate,CommandOperationDelegate>
{
	UITableView *registTableView;
	UITextField *nameTextField;
    UITextField *passwordTextField;
	MBProgressHUD *progressHUD;
	
    id <registerViewDelegate> delegate;
}
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

@property (nonatomic, assign) id<registerViewDelegate> delegate;
- (void)accessService;
- (void)checkWeiboExpiredAction;
- (BOOL)validateRegexPassword:(NSString *)password;
@end
