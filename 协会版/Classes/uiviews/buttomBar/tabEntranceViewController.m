//
//  tabEntranceViewController.m
//
//  Created by MC374 on 12-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Common.h"

#import "tabEntranceViewController.h"
#import "InformationMainViewController.h"
#import "contactsBookViewController.h"
#import "ShopsMainViewController.h"
#import "MenberCenterMainViewController.h"
#import "MoreMainViewController.h"
#import "LoginViewController.h"
#import "SearchViewController.h"
#import "DataManager.h"
#import "FileManager.h"
#import "ProfessionAppDelegate.h"
#import "contactsBookCatViewController.h"

@implementation tabEntranceViewController

@synthesize loginBarButton;
@synthesize chooseVC;

@synthesize informationMainView;
@synthesize contactsBookView;
@synthesize shopsMainView;
@synthesize menberCenterMainView;
@synthesize loginView;
@synthesize moreMainView;
@synthesize logoview;
@synthesize loginBtn;

- (id)init{
	self = [super init];//调用父类初始化函数
	if (self != nil) 
	{	
		NSArray *tabArray = ARRAYS_TAB_BAR;
		NSMutableArray *controllers = [NSMutableArray array];
		for(int i = 0; i < [tabArray count]; i++){
			NSString *keyName = [tabArray objectAtIndex:i];
			NSString *titleName = keyName;
			if (i == 0){
				InformationMainViewController *ifm = [[InformationMainViewController alloc] init];
				UIImage *img1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:titleName ofType:@"png"]];
				[ifm.tabBarItem initWithTitle:titleName image:img1 tag:0];
				self.informationMainView = ifm;
				[img1 release];
				[ifm release];
				[controllers addObject:self.informationMainView];
			}else if(i == 1){
				contactsBookViewController *tempContactsBookView = [[contactsBookViewController alloc] init];
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:titleName ofType:@"png"]];
				[tempContactsBookView.tabBarItem initWithTitle:titleName image:img tag:0];
				[img release];
				self.contactsBookView = tempContactsBookView;
				[controllers addObject:self.contactsBookView];
				[tempContactsBookView release];
			} else if (i == 2){
				ShopsMainViewController *smvc = [[ShopsMainViewController alloc]init];
				UIImage *img1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:titleName ofType:@"png"]];
				[smvc.tabBarItem initWithTitle:titleName image:img1 tag:0];
				[img1 release];
				self.shopsMainView = smvc;
				[smvc release];
				[controllers addObject:self.shopsMainView];
			}else if (i == 3) {
				LoginViewController *login = [[LoginViewController alloc]init];
				self.loginView = login;
				[login release];
				UIImage *img2 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:titleName ofType:@"png"]];
				[login.tabBarItem initWithTitle:titleName image:img2 tag:0];
				[img2 release];
				[controllers addObject:self.loginView];
				
				
			}else if (i == 4){
				MoreMainViewController *mmvc = [[MoreMainViewController alloc]init];
				self.moreMainView = mmvc;
				UIImage *img3 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:titleName ofType:@"png"]];
				[moreMainView.tabBarItem initWithTitle:titleName image:img3 tag:0];
				[img3 release];
				[mmvc release];
				[controllers addObject:self.moreMainView];
			}
		}
		
		self.viewControllers = controllers;
		self.customizableViewControllers = controllers;		
		self.delegate = self;
		
		UIImage* image= [UIImage imageNamed:@"登录.png"];
		UIImage* image1= [UIImage imageNamed:@"已登录.png"];
		UIImage* image2= [UIImage imageNamed:@"已登录按下.png"];
        CGRect frame_1= CGRectMake(0, 0, image.size.width, image.size.height);   
		loginBtn = [[UIButton alloc] initWithFrame:frame_1];
	
		if (_isLogin == NO) {
			[loginBtn setImage:image forState:UIControlStateNormal]; 
			[loginBtn setImage:nil forState:UIControlStateHighlighted];
		}else {
			[loginBtn setImage:image1 forState:UIControlStateNormal];
			[loginBtn setImage:image2 forState:UIControlStateHighlighted];
		}
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];   
        loginBtn.titleLabel.font=[UIFont systemFontOfSize:16];   
        [loginBtn addTarget:self action:@selector(handleFunction:) forControlEvents:UIControlEventTouchUpInside];   
		
		//定制自己的风格的  UIBarButtonItem  
		UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:loginBtn]; 
		someBarButtonItem.tag = 1;
		self.loginBarButton = someBarButtonItem;
        [self.navigationItem setRightBarButtonItem:someBarButtonItem];   
        [someBarButtonItem release];   
       // [btn release]; 
		
		
		//添加首页图片title
		UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 ,0 ,0)];
		UIImage *logoImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
		int imgWidth = logoImage.size.width;
		int imgHeight = logoImage.size.height;
		int x = (self.view.frame.size.width - imgWidth) / 2;
		int y = (44 - logoImage.size.height)/2;
		[logo setFrame:CGRectMake(x,y ,imgWidth ,imgHeight)];
		logo.image = logoImage;
		self.logoview = logo;
		self.navigationItem.titleView = logoview;
		[logoImage release];
		
		self.view.backgroundColor = [UIColor clearColor];
		
	}
#ifdef SHOW_NAV_TAB_BG	
	UIView *v = [[UIView alloc] initWithFrame:self.view.frame];
	UIImage *img = [UIImage imageNamed:TAB_BG_PIC];
	UIColor *bcolor = [[UIColor alloc] initWithPatternImage:img];
	v.backgroundColor = bcolor;
	[self.tabBar insertSubview:v atIndex:0];
	self.tabBar.opaque = YES;
	[bcolor release];
	[v release];
#else
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 49);
	UIView *view = [[UIView alloc] initWithFrame:frame];
	UIColor *color = [UIColor colorWithRed:BTO_COLOR_RED green:BTO_COLOR_GREEN blue:BTO_COLOR_BLUE alpha:0.6];
	[view setBackgroundColor:color];
	[[self tabBar] insertSubview:view atIndex:0];
	[[self tabBar] setAlpha:1];
	[view release];
#endif
	
	return self;
}

- (void) viewDidLoad{
	[super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (_isLogin == NO) {
		UIImage* image= [UIImage imageNamed:@"登录.png"];
		[loginBtn setImage:image forState:UIControlStateNormal];
		[loginBtn setImage:nil forState:UIControlStateHighlighted];
	}else {
		UIImage* image1= [UIImage imageNamed:@"已登录.png"];
		UIImage* image2= [UIImage imageNamed:@"已登录按下.png"];
		[loginBtn setImage:image1 forState:UIControlStateNormal];
		[loginBtn setImage:image2 forState:UIControlStateHighlighted];
	}
}

- (void) viewDidUnload{
	[super viewDidUnload];
	self.logoview = nil;
	self.loginBarButton = nil;
	self.chooseVC = nil;
	self.informationMainView = nil;
	self.contactsBookView = nil;
	self.shopsMainView = nil;
	self.menberCenterMainView = nil;
	self.moreMainView = nil;
	self.loginView = nil;
}

-(void)dealloc{
	[loginBarButton release];
	[chooseVC release];
	[informationMainView release];
	[contactsBookView release];
	[shopsMainView release];
	[menberCenterMainView release];
	[moreMainView release];
	[logoview release];
	[loginView release];
	[loginBtn release];
	[super dealloc];
}

-(void) handleFunction:(id)sender{
	LoginViewController *login = [[LoginViewController alloc] init];
	if (_isLogin == YES) {
		login.memberCenter.view.hidden = NO;
		
		if (_isChangedImage == NO) {
            NSString *piclink = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_image];
            NSString *photoname = [Common encodeBase64:(NSMutableData *)[piclink dataUsingEncoding: NSUTF8StringEncoding]];
			UIImage *img = [FileManager getPhoto:photoname];
			if (img != nil) {
				ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
				deleagte.headerImage = img;
			}
		}else {
			ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
			login.memberCenter.memberHeaderView.image = deleagte.headerImage;
		}

	}else {
		login.memberCenter.view.hidden = YES;
	}

	[self.navigationController pushViewController:login animated:YES];
	
	

}

//通讯录分类
-(void)contactsBookCat
{
    contactsBookCatViewController *contactsBookCat = [[contactsBookCatViewController alloc] init];			
    [self.navigationController pushViewController:contactsBookCat animated:YES];
    [contactsBookCat release];
}


- (void)hideRealTabBar{
	for(UIView *view in self.view.subviews){
		if([view isKindOfClass:[UITabBar class]]){
			view.hidden = YES;
			break;
		}
	}
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
	
	@try {
        NSArray *tabArray = ARRAYS_TAB_BAR;
		int selectedIndextmp = [self selectedIndex];
		
		if(selectedIndextmp == 0){
			self.title = nil;
			self.navigationItem.titleView = logoview;
			[chooseVC.view removeFromSuperview];
			self.navigationItem.rightBarButtonItem = loginBarButton;
			if (_isLogin == NO) {
				UIImage* image= [UIImage imageNamed:@"登录.png"];
				[loginBtn setImage:image forState:UIControlStateNormal];
				[loginBtn setImage:nil forState:UIControlStateHighlighted];
			}else {
				UIImage* image1= [UIImage imageNamed:@"已登录.png"];
				UIImage* image2= [UIImage imageNamed:@"已登录按下.png"];
				[loginBtn setImage:image1 forState:UIControlStateNormal];
				[loginBtn setImage:image2 forState:UIControlStateHighlighted];
			}
		}else if(selectedIndextmp == 1){
			self.navigationItem.titleView = nil;
			self.title = [tabArray objectAtIndex:selectedIndextmp];
			[chooseVC.view removeFromSuperview];
			self.navigationItem.rightBarButtonItem = nil;
            
            UIButton *contactsBookCatButton = [UIButton buttonWithType:UIButtonTypeCustom];  
            contactsBookCatButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
            [contactsBookCatButton addTarget:self action:@selector(contactsBookCat) forControlEvents:UIControlEventTouchDown];
            [contactsBookCatButton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"分类按钮" ofType:@"png"]] forState:UIControlStateNormal];
            
            UIBarButtonItem *contactsBookCatItem = [[UIBarButtonItem alloc] initWithCustomView:contactsBookCatButton]; 
            self.navigationItem.rightBarButtonItem = contactsBookCatItem;
            
		}else if(selectedIndextmp == 2){
			self.navigationItem.titleView = nil;
			self.title = [tabArray objectAtIndex:selectedIndextmp];
			[chooseVC.view removeFromSuperview];
			self.navigationItem.titleView = nil;
			self.navigationItem.rightBarButtonItem = nil;
		}else if(selectedIndextmp == 3){	
			NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												[Common getSecureString],@"keyvalue",
												[NSNumber numberWithInt: SITE_ID],@"site_id",
												[NSNumber numberWithInt:2],@"type",nil];
			[[DataManager sharedManager] accessService:jsontestDic command:PV_COMMAND_ID 
										  accessAdress:@"pvcount.do?param=%@" delegate:self withParam:nil];
			
			
			self.navigationItem.titleView = nil;
			self.title = @"个人中心";
			[chooseVC.view removeFromSuperview];
			self.navigationItem.titleView = nil;
			self.navigationItem.rightBarButtonItem = nil;
			if (_isLogin == YES) {
				loginView.memberCenter.view.hidden = NO;
				[loginView.memberCenter viewAppearAction];
			}else {
				loginView.memberCenter.view.hidden = YES;
			}
			
		}else if(selectedIndextmp == 4){
			self.navigationItem.titleView = nil;
			self.title = [tabArray objectAtIndex:selectedIndextmp];
			[chooseVC.view removeFromSuperview];
			self.navigationItem.titleView = nil;
			self.navigationItem.rightBarButtonItem = nil;
		}
		
	}
	@catch (NSException *exception) {
		NSLog(@"tabchoose: Caught %@: %@", [exception name], [exception reason]);
		return;
	}
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{

}
@end
