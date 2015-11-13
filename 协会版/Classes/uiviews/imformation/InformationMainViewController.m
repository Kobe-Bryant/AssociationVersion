//
//  InformationMainViewController.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InformationMainViewController.h"
#import "DataManager.h"
#import "LightMenuBar.h"
#import "FirsetPageViewController.h"
#import "OtherPageViewCotroller.h"
#import "Encry.h"
#import "Common.h"
#import "MBProgressHUD.h"

@implementation InformationMainViewController
@synthesize infoCategoryArray;
@synthesize firstPageViewController;
@synthesize otherPageViewController;
@synthesize catArray;
@synthesize myMenuBar;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
	
	NSMutableArray *ay = [[NSMutableArray alloc] initWithObjects:HOME_CAT_NAME,nil];
	self.infoCategoryArray = ay;
	[ay release];
	
	//添加loading控件
	progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	progressHUD.delegate = self;
	progressHUD.labelText = LOADING_TIPS;
	
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	[self accessService];
    
    [self performSelector:@selector(updateNotifice) withObject:nil afterDelay:12];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.infoCategoryArray = nil;
	progressHUD = nil;
	self.catArray = nil;
    self.myMenuBar.delegate = nil;
    self.myMenuBar = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[infoCategoryArray release];
	infoCategoryArray = nil;
	[firstPageViewController release];
	firstPageViewController = nil;
	[otherPageViewController release];
	otherPageViewController = nil;
	[progressHUD release],progressHUD = nil;
	[catArray release],catArray = nil;
    self.myMenuBar.delegate = nil;
    self.myMenuBar = nil;
}

- (void) addLightMenuBar{
	//背景
    UIImageView *natBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0 , 0 , 320.0f , 40.0f)];
    UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"导航栏背景" ofType:@"png"]];
    natBackImageView.image = backImage;
    [self.view addSubview:natBackImageView];
    
    //分类滚动导航
	LightMenuBar *tempMenuBar = [[LightMenuBar alloc] initWithFrame:CGRectMake(16, 0, 288.0f, 40.0f) andStyle:LightMenuBarStyleItem];
	//LightMenuBar *menuBar = [[LightMenuBar alloc] initWithFrame:CGRectMake(0, 20, 320, 40) andStyle:LightMenuBarStyleButton];
    tempMenuBar.delegate = self;
    tempMenuBar.bounces = YES;
    tempMenuBar.selectedItemIndex = 0;
    tempMenuBar.backgroundColor = [UIColor clearColor];
    self.myMenuBar = tempMenuBar;
    [self.view addSubview:self.myMenuBar];
    
    //左边滚动按钮
	UIImageView *leftButton = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 40.0f)];
	leftButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"导航栏left_arrow" ofType:@"png"]];
	
	//绑定点击事件
	leftButton.userInteractionEnabled = YES;
	UITapGestureRecognizer *leftSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goLeft)];
	[leftButton addGestureRecognizer:leftSingleTap];
	[leftSingleTap release];
	
	[self.view addSubview:leftButton];
	[leftButton release];
    
    //右边滚动按钮
	UIImageView *rightButton = [[UIImageView alloc]initWithFrame:CGRectMake(300.0f, 0.0f, 20.0f, 40.0f)];
	rightButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"导航栏right_arrow" ofType:@"png"]];
	
	//绑定点击事件
	rightButton.userInteractionEnabled = YES;
	UITapGestureRecognizer *rightSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goRight)];
	[rightButton addGestureRecognizer:rightSingleTap];
	[rightSingleTap release];
	
	[self.view addSubview:rightButton];
	[rightButton release];
}

//向左滚动
-(void)goLeft
{
    [self.myMenuBar goLeftOrRight:@"left" animated:YES];
}

//向右滚动
-(void)goRight
{
    [self.myMenuBar goLeftOrRight:@"right" animated:YES];
}

- (void)accessService{
	//md5加密字符串生成
	NSString *keystring = [NSString stringWithFormat:@"%d%@",SITE_ID,SignSecureKey];
	NSString *securekey = [Encry md5:keystring];
    
    NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 securekey,@"keyvalue",
								 [Common getVersion:ACCESS_RECOMMEND_NEWS_COMMAND_ID],@"ver_news",
								 [NSNumber numberWithInt: 0],@"ver_shops",
								 [Common getVersion:ACCESS_NEWS_CATS_COMMAND_ID],@"ver_cats",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: 1],@"edition",
                                 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:ACCESS_RCM_CATS_COMMAND_ID 
								  accessAdress:@"recommend.do?param=%@" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
}

- (void) update{
	self.catArray  = nil;
	self.catArray = [DBOperate queryData:T_NEWS_CAT 
										theColumn:nil theColumnValue:nil withAll:YES];
	for(int i = 0;i <  [catArray count];i++) {
		NSArray *ay = [catArray objectAtIndex:i];
		NSString *catname = [ay objectAtIndex:newscat_name];
		[infoCategoryArray addObject:catname];
	}
	
	[self addLightMenuBar];
	if (progressHUD != nil) {
		if (progressHUD) {
			[progressHUD removeFromSuperview];
		}
	}
}

#pragma mark LightMenuBarDelegate Require
- (NSUInteger)itemCountInMenuBar:(LightMenuBar *)menuBar{
	
	return [infoCategoryArray count];
}
- (NSString *)itemTitleAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar{
	return [infoCategoryArray objectAtIndex:index];
}
- (void)itemSelectedAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar{
	[firstPageViewController.view removeFromSuperview];
	[otherPageViewController.view removeFromSuperview];
	self.catArray = nil;
	self.catArray = [DBOperate queryData:T_NEWS_CAT 
							   theColumn:nil theColumnValue:nil withAll:YES];
	if (index == 0) {
		if (firstPageViewController == nil) {
			FirsetPageViewController *first = [[FirsetPageViewController alloc] init];
			first.myNavigationController = self.navigationController;
			self.firstPageViewController = first;
			[first release];
		}
		[firstPageViewController.view setFrame:
						CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40)];
		[self.view addSubview:firstPageViewController.view];
	}else {
		NSArray *ay = [catArray objectAtIndex:index - 1];
		NSNumber *cid = [ay objectAtIndex:newscat_cid];
		NSNumber *cv = [ay objectAtIndex:newscat_version];
        otherPageViewController = nil;
		if (otherPageViewController == nil) {
			OtherPageViewCotroller *other = [[OtherPageViewCotroller alloc] init];
			other.myNavigationController = self.navigationController;
            other.catid = cid;	
            other.catversion = cv;
			self.otherPageViewController = other;
			[other release];
			[otherPageViewController.view setFrame:
			 CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40)];				
		}
		
		[self.view addSubview:otherPageViewController.view];
	}

}

#pragma mark LightMenuBarDelegate Optional
- (CGFloat)itemWidthAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	if ([self.infoCategoryArray count] > 3) 
	{
		return self.myMenuBar.frame.size.width / 3;
	}
	else 
	{
		return self.myMenuBar.frame.size.width / [self.infoCategoryArray count];
	}
}
- (CGFloat)verticalPaddingInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}

/**< Left and Right Padding, by Default 5.0f */
- (CGFloat)horizontalPaddingInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}

/**< Corner Radius of the background Area, by Default 5.0f */
- (CGFloat)cornerRadiusOfBackgroundInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}
- (UIColor *)colorOfBackgroundInMenuBar:(LightMenuBar *)menuBar{
	return [UIColor clearColor];
}
- (CGFloat)cornerRadiusOfButtonInMenuBar:(LightMenuBar *)menuBar {
    return 1.0f;
}
- (UIFont *)fontOfTitleInMenuBar:(LightMenuBar *)menuBar {
    return [UIFont systemFontOfSize:15.0f];
}
- (UIColor *)colorOfButtonHighlightInMenuBar:(LightMenuBar *)menuBar {
    //return [UIColor whiteColor];
	//return [UIColor colorWithRed:0.9 green:0.4 blue:0.0 alpha:1.0f];
    
    NSString *checkedImgName;
    if ([self.infoCategoryArray count] > 3) 
	{
		checkedImgName = @"导航栏3选中";
	}
	else 
	{
        if ([self.infoCategoryArray count] == 1 || [self.infoCategoryArray count] == 0) 
        {
            return [UIColor clearColor];
        }
        else 
        {
            checkedImgName = [NSString stringWithFormat:@"导航栏%d选中",[self.infoCategoryArray count]];
        }
	}
    
    UIImage *currentCheckedBackground = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:checkedImgName ofType:@"png"]];
    return [UIColor colorWithPatternImage:currentCheckedBackground];
    
}

- (UIColor *)colorOfTitleNormalInMenuBar:(LightMenuBar *)menuBar {
    return COLOR_UNSELECTED_CAT_TITLE;
}
- (UIColor *)colorOfTitleHighlightInMenuBar:(LightMenuBar *)menuBar {
    return COLOR_SELECTED_CAT_TITLE;
}
/**< Width of Seperator, by Default 1.0f */
- (CGFloat)seperatorWidthInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}

/**< Height Rate of Seperator, by Default 0.7f */
- (CGFloat)seperatorHeightRateInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}

#pragma mark ---- 自动升级 评分提醒 ----
- (void) updateNotifice{
	NSArray *updateArray = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"0" withAll:NO];
	if(updateArray != nil && [updateArray count] > 0){
		NSArray *array = [updateArray objectAtIndex:0];
		int reminde = [[array objectAtIndex:app_info_remide] intValue];
		int newUpdateVersion = [[array objectAtIndex:app_info_ver] intValue];
        
		if (CURRENT_APP_VERSION != newUpdateVersion) {
			if (reminde != 1) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:TIPS_NEWVERSION message:[array objectAtIndex:app_info_remark] delegate:self cancelButtonTitle:@"稍后提示我" otherButtonTitles:@"立即更新", nil];
                alertView.tag = 1;
                [alertView show];
                [alertView release];
                return;
            }
		}
	}
    
    NSArray *gradeArray = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"1"withAll:NO];
    if (gradeArray != nil && [gradeArray count] > 0) {
        NSArray *array = [gradeArray objectAtIndex:0];
        int remind = [[array objectAtIndex:app_info_remide] intValue];
        
        NSString *updateGradeUrl = [array objectAtIndex:app_info_url];
        if (updateGradeUrl != nil && [updateGradeUrl length] > 0) {
            NSDate *senddate = [NSDate date];
            NSCalendar *cal = [NSCalendar  currentCalendar];
            NSUInteger unitFlags = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
            NSDateComponents *conponent = [cal components:unitFlags fromDate:senddate];
            NSInteger year = [conponent year];
            NSInteger month = [conponent month];
            NSInteger day = [conponent day];
            
            NSInteger years = [[NSUserDefaults standardUserDefaults] integerForKey:@"year"];
            NSInteger months = [[NSUserDefaults standardUserDefaults] integerForKey:@"month"];
            NSInteger days = [[NSUserDefaults standardUserDefaults] integerForKey:@"day"];
            
            if (remind == 1) {
                return;
            }
            
            if (years != year || months != month || days <= day-7) {
                [[NSUserDefaults standardUserDefaults] setInteger:year forKey:@"year"];
                [[NSUserDefaults standardUserDefaults] setInteger:month forKey:@"month"];
                [[NSUserDefaults standardUserDefaults] setInteger:day forKey:@"day"];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"喜欢我，就来评分吧！" message:@"" delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles:@"鼓励一下",@"不再提醒", nil];
                alertView.tag = 2;
                [alertView show];
                [alertView release];
            }
        }
	}
}

#pragma mark - UIAlertViewDelegate
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (IOS_VERSION < 7)
    {
        UIView * view = [alertView.subviews objectAtIndex:2];
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*) view;
            label.textAlignment = UITextAlignmentLeft;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSArray *updateArray = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"0" withAll:NO];
            if(updateArray != nil && [updateArray count] > 0){
                NSArray *array = [updateArray objectAtIndex:0];
                NSString *url = [array objectAtIndex:app_info_url];
                [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
                      conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:0]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        } else if (buttonIndex == 2) {
            [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
                  conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:0]];
        }
    } else if (alertView.tag == 2){
        if (buttonIndex == 1) {
            NSArray *gradeArray = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"1"withAll:NO];
            if (gradeArray != nil && [gradeArray count] > 0) {
                NSArray *array = [gradeArray objectAtIndex:0];
                NSString *url = [array objectAtIndex:app_info_url];
                [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
                      conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:1]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        } else if (buttonIndex == 2) {
            [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
                  conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:1]];
        }
    }
}

@end
