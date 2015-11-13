//
//  tabEntranceViewController.h
//
//  Created by MC374 on 12-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InformationMainViewController;
@class contactsBookViewController;
@class ShopsMainViewController;
@class MenberCenterMainViewController;
@class MoreMainViewController;
@class LoginViewController;
#import "CommandOperation.h"
@interface tabEntranceViewController : UITabBarController<UITabBarControllerDelegate,CommandOperationDelegate> {

	UIBarButtonItem *loginBarButton;
	UIViewController *chooseVC;
	
	InformationMainViewController *informationMainView;
	contactsBookViewController *contactsBookView;
	ShopsMainViewController *shopsMainView;
	MenberCenterMainViewController *menberCenterMainView;
	MoreMainViewController *moreMainView;
	UIImageView *logoview;
	
	LoginViewController *loginView;
	
	UIButton* loginBtn;
}
@property(nonatomic,retain) UIBarButtonItem *loginBarButton;
@property(nonatomic,retain) UIViewController *chooseVC;

@property(nonatomic,retain) InformationMainViewController *informationMainView;
@property(nonatomic,retain) contactsBookViewController *contactsBookView;
@property(nonatomic,retain) ShopsMainViewController *shopsMainView;
@property(nonatomic,retain) MenberCenterMainViewController *menberCenterMainView;
@property(nonatomic,retain) MoreMainViewController *moreMainView;
@property(nonatomic,retain) UIImageView *logoview;
@property(nonatomic,retain) LoginViewController *loginView;
@property(nonatomic,retain) UIButton *loginBtn;

@end
