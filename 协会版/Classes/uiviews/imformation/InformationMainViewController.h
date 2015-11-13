//
//  InformationMainViewController.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "LightMenuBarDelegate.h"
#import "MBProgressHUD.h"

@class FirsetPageViewController;
@class OtherPageViewCotroller;
 
@interface InformationMainViewController : UIViewController<CommandOperationDelegate,LightMenuBarDelegate,MBProgressHUDDelegate> {
	NSMutableArray *infoCategoryArray;
	NSArray *catArray;
	FirsetPageViewController *firstPageViewController;
	OtherPageViewCotroller *otherPageViewController;
	MBProgressHUD *progressHUD;
    LightMenuBar *myMenuBar;
}

@property (nonatomic,retain) NSMutableArray *infoCategoryArray;
@property (nonatomic,retain) NSArray *catArray;
@property (nonatomic,retain) FirsetPageViewController *firstPageViewController;
@property (nonatomic,retain) OtherPageViewCotroller *otherPageViewController;
@property(nonatomic,retain) LightMenuBar *myMenuBar;
- (void) addLightMenuBar;

//向左滚动
-(void)goLeft;

//向右滚动
-(void)goRight;

- (void)accessService;
- (void) update;

@end
