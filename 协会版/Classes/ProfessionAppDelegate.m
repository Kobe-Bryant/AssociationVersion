//
//  ProfessionAppDelegate.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfessionAppDelegate.h"
#import "tabEntranceViewController.h"
#import "CustomTabBar.h"
#import "Common.h"
#import "DataManager.h"
#import "DBOperate.h"
#import "alertView.h"
#import "showPushAlert.h"
#import "CustomNavigationController.h"
#import "activityMainViewController.h"

#import "FileManager.h"

@implementation ProfessionAppDelegate

@synthesize window;
@synthesize navController;
@synthesize loginBtn;
@synthesize headerImage;
@synthesize myDeviceToken;
@synthesize province;
@synthesize city;
@synthesize LatitudeAndLongitude;
@synthesize pushAlert;
@synthesize delegate;

// dufu add 2013.05.15
@synthesize addressCity;

// dufu add 2013.06.14
// 数据库操作
- (void)operateDB
{
    //NSArray *ar_version = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag" theColumnValue:APP_SOFTWARE_VER_KEY withAll:NO];
	
    int soft_ver = [[NSUserDefaults standardUserDefaults] integerForKey:APP_SOFTWARE_VER_KEY];
	
    NSLog(@"dddd = %d",soft_ver);
    
	if(soft_ver != CURRENT_APP_VERSION)
	{
		[FileManager removeFile:dataBaseFile];
		NSString *filepath = [FileManager getFilePath:@""];
        NSLog(@"filepath 1111 = %@",filepath);
		//获取所有下个目录下的文件名列表
		NSArray *fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath: filepath error:nil];
		for(int i=0;i < [fileList count]; i++)
		{
			[FileManager removeFile:[fileList objectAtIndex:i]];
		}
        
        [[NSUserDefaults standardUserDefaults] setInteger:CURRENT_APP_VERSION forKey:APP_SOFTWARE_VER_KEY];
	}
    
    //创建表结构
	[DBOperate createTable];
    
//	//写入当前软件版本号
//	NSArray *ar_ver = [NSArray arrayWithObjects:APP_SOFTWARE_VER_KEY,[NSString stringWithFormat:@"%d",CURRENT_APP_VERSION], nil];
//	[DBOperate deleteData:T_SYSTEM_CONFIG tableColumn:@"tag" columnValue:APP_SOFTWARE_VER_KEY];
//	[DBOperate insertDataWithnotAutoID:ar_ver tableName:T_SYSTEM_CONFIG];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 数据库操作
	[self operateDB];
    
    //网络线程初始化
	netWorkQueue = [[NSOperationQueue alloc] init];
	[netWorkQueue setMaxConcurrentOperationCount:2];
    
    netWorkQueueArray = [[NSMutableArray alloc] init];
    
	//============================= UI 视图显示 ===========================================
    //显示状态栏
	[application setStatusBarHidden:NO withAnimation:NO];
    [application setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
    //登陆状态
	_isChangedImage = NO;
	headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员中心默认头像" ofType:@"png"]];
	
    //设置背景
    //float width = [UIScreen mainScreen].bounds.size.width;
	float height = [UIScreen mainScreen].bounds.size.height;
    CGFloat fixHeight = height < 548 ? -44.0f + 20.0f : 20.0f;
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"背景" ofType:@"png"]];
	UIImageView *backiv = [[UIImageView alloc]initWithFrame:CGRectMake(0, fixHeight , img.size.width, img.size.height)];
	backiv.image = img;
	[img release];
    [window addSubview:backiv];
	[backiv release];
    
    //下bar初始化
    //tabEntranceViewController *tabViewController = [[tabEntranceViewController alloc]init];
    CustomTabBar *tabViewController = [[CustomTabBar alloc]init];
    //默认选中第一个 如果是使用tabEntranceViewController 非自定义的 需要把该代码也注释
    [tabViewController selectedTab:[tabViewController.buttons objectAtIndex:0]];
    
    self.loginBtn = tabViewController.loginBtn;
    self.loginBtn.hidden = YES;
    
    UINavigationController *tabNavigation = [[CustomNavigationController alloc] initWithRootViewController:tabViewController];
    //NSLog(@"%@",[NSValue valueWithCGRect:tabNavigation.navigationBar.bounds]);
    [tabViewController release];
    
    //上bar 自定义
    UINavigationBar *navBar = [tabNavigation navigationBar];
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        // set globablly for all UINavBars
        UIImage *img = nil;
        if (IOS_VERSION >= 7.0) {
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:IOS7_NAV_BG_PIC ofType:nil]];
        }else{
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NAV_BG_PIC ofType:nil]];
        }
        [navBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [img release];
    }
    
    //上bar 背景
    tabNavigation.navigationBar.tintColor = COLOR_BAR_BUTTON;//[UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1];//[UIColor colorWithRed:0.54296875 green:0.7890625 blue:0.796875 alpha:1];//[UIColor colorWithRed:0.4765625 green:0.77734375 blue:0.88671875 alpha:1];
    
    self.navController = tabNavigation;	
    [window addSubview:tabNavigation.view];
    [tabNavigation release];
    
    if (IOS_VERSION >= 7.0) {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        
        tabViewController.edgesForExtendedLayout = UIRectEdgeNone;
        tabViewController.extendedLayoutIncludesOpaqueBars = NO;
        tabViewController.modalPresentationCapturesStatusBarAppearance = NO;
        tabViewController.navigationController.navigationBar.translucent = NO;
        tabViewController.tabBarController.tabBar.translucent = NO;
    }
    
    //============================= 事务逻辑处理 ===========================================
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数 700BFB35E4382872A2EA1E1BDC0F3CA496242B8D  //
    BOOL ret = [_mapManager start:@"aD99cXbvKRLUfBoeKUAILHCG" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //经纬度初始化
    myLocation.latitude = 22.548604;
	myLocation.longitude = 114.064515;

    //自动登陆
	[self isAutoLogin];
    
    // 微信注册
    [WXApi registerApp:WEICHATID];  // dufu add 2013.04.24
	
	//推送通知注册
    NSArray *ar_token = [DBOperate queryData:T_DEVTOKEN theColumn:nil theColumnValue:nil  withAll:YES];
    if ([ar_token count]>0)
    {
		NSArray *arr_token = [ar_token objectAtIndex:0];
		self.myDeviceToken = [arr_token objectAtIndex:devtoken_token];
        
        //获取位置
        [self getLocation];
	}
    else
    {
        //注册消息通知 获取token号
        if (IOS_VERSION >=8) {
            NSLog(@"这是ios8通知新的api");
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            NSLog(@"这是老的通知的api");
            
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
        }
    }
    
    //监听消息推送
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(launchNotification:)name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
	
	//线程延迟 2 秒执行
	[NSThread sleepForTimeInterval:2]; 
	application.applicationIconBadgeNumber = 0;
    
    //开启获取通讯录的线程
    is_get_contacts_book_done = NO;
    lastContactsBooksId = 0;
    contactsBookVer = [[Common getVersion:OPERAT_CONTACTS_BOOK_REFRESH] intValue];
    [self performSelector:@selector(accessContactsBookService) withObject:nil afterDelay:0.0];
	
	[self.window makeKeyAndVisible];
    return YES;
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    //selectedIndex
    
    [self isAutoLogin];

    //如果原先线程已经跑完 可以重新请求
    if (is_get_contacts_book_done) 
    {
        is_get_contacts_book_done = NO;
        lastContactsBooksId = 0;
        contactsBookVer = [[Common getVersion:OPERAT_CONTACTS_BOOK_REFRESH] intValue];
        [self performSelector:@selector(accessContactsBookService) withObject:nil afterDelay:0.0];
    }
    
    //获取位置
    [self getLocation];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

//获取地理位置
- (void)getLocation
{
//    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
//    {
//        locManager = [[CLLocationManager alloc] init];
//        locManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locManager.delegate = self;
//        [locManager startUpdatingLocation];
//    }
//    else 
//    {
//        //定位没打开 默认地址发送
//        [self apnsAccess];
//    }
    locManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [locManager requestWhenInUseAuthorization];
        //定位没打开 默认地址发送
        [self apnsAccess];
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        locManager.delegate = self;
        [locManager startUpdatingLocation];
        
    }
}

//自动登陆
- (void)isAutoLogin
{
	NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
	if ([dbArray count] != 0) {
        
		NSArray *memberArray = [dbArray objectAtIndex:0];
        NSString *location = [NSString stringWithFormat:@"%f,%f",myLocation.latitude,myLocation.longitude];
        
		NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
									 [Common getSecureString],@"keyvalue",
									 [NSNumber numberWithInt: SITE_ID],@"site_id",
									 [memberArray objectAtIndex:member_info_name],@"login_name",
									 [memberArray objectAtIndex:member_info_password],@"login_pwd",
                                     location,@"lat-and-long",
                                     [NSNumber numberWithInt: 1],@"edition",
                                     [Common getMacAddress],@"mac_addr",nil];
		
		[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_LOGIN_COMMAND_ID accessAdress:@"member/login.do?param=%@" delegate:self withParam:nil];
	}else{
        
		_isLogin = NO;
        
        self.loginBtn.hidden = NO;
        UIImage* image= [UIImage imageNamed:@"登录.png"];
		[loginBtn setImage:image forState:UIControlStateNormal];
		[loginBtn setImage:nil forState:UIControlStateHighlighted];
	}	
}

- (void)apnsAccess
{
    //上传token和统计信息给服务器
    LatitudeAndLongitude = LatitudeAndLongitude == nil ? @"114.064515,22.548604" : LatitudeAndLongitude;
    self.province = self.province == nil ? @"广东省" : self.province;
    self.city = self.city == nil ? @"深圳市" : self.city;
    self.myDeviceToken = self.myDeviceToken == nil ? @"" : self.myDeviceToken;
    
    NSArray *dbArr = [DBOperate queryData:T_PHONENUM theColumn:nil theColumnValue:nil withAll:YES];
    NSString *mobileStr = nil;
    if (dbArr != nil && [dbArr count] > 0) {
        mobileStr = [[dbArr objectAtIndex:0] objectAtIndex:phoneNum_mobile];
    }else {
        mobileStr = @"0";
    }
    
    int _userId = 0;
    NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
	if ([dbArray count] != 0) {
		NSArray *memberArray = [dbArray objectAtIndex:0];
        _userId = [[memberArray objectAtIndex:member_info_memberId] intValue];
    }else {
        _userId = 0;
    }
    
    //自动升级 版本号
    int  promoteVer;
    NSArray *promoteArr = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"0" withAll:NO];
    if ([promoteArr count] > 0) {
        promoteVer = [[[promoteArr objectAtIndex:0] objectAtIndex:app_info_ver] intValue];
    }else {
        promoteVer = 0;
    }
    
    //评分提醒 版本号
    int  gradeVer;
    NSArray *gradeArr = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"1" withAll:NO];
    if ([gradeArr count] > 0) {
        gradeVer = [[[gradeArr objectAtIndex:0] objectAtIndex:app_info_ver] intValue];
    }else {
        gradeVer = 0;
    }

    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										self.myDeviceToken,@"token",
										self.province,@"pro",
										self.city,@"city",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[Common getMacAddress],@"mac-addr",
										LatitudeAndLongitude,@"lat-and-long",
										[NSNumber numberWithInt:0],@"platform",
                                        mobileStr,@"mobile",
                                        [NSNumber numberWithInt: _userId],@"user_id",
                                        [NSNumber numberWithInt: promoteVer],@"promote_ver",
                                        [NSNumber numberWithInt: gradeVer],@"grade_ver",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:APNS_COMMAND_ID 
								  accessAdress:@"apns.do?param=%@" delegate:self withParam:nil];
}

//网络获取数据
-(void)accessContactsBookService
{    
	NSString *reqUrl = @"maillist.do?param=%@";
    
    NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: contactsBookVer],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: lastContactsBooksId],@"info_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_CONTACTS_BOOK_REFRESH 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    switch(commandid)
    {
            //自动登陆
        case MEMBER_LOGIN_COMMAND_ID:
            [self performSelectorOnMainThread:@selector(updateAction:) withObject:resultArray waitUntilDone:NO];
            break;
            
            //请求通讯录数据
        case OPERAT_CONTACTS_BOOK_REFRESH:
            
            //判断是否已经load完
            if (ver == 0)
            {
                //load完
                is_get_contacts_book_done = YES;
                
                //注册消息通知 发送广播 告知已load完
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loadContactsBooks" object:nil];  
            }
            else 
            {
                //继续load
                lastContactsBooksId = ver;
                [self performSelectorOnMainThread:@selector(accessContactsBookService) withObject:nil waitUntilDone:NO];
            }
            
            break;
        case APNS_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(apnsResult:) withObject:resultArray waitUntilDone:NO];
        }break;
            
        default:   ;
    }
}

- (void)updateAction:(NSMutableArray *)array{
    NSLog(@"array====%@",array);
	NSString *resultstr = [[array objectAtIndex:0] objectAtIndex:0];
	if ([resultstr isEqualToString:@"1"]) 
    {
        
		_isLogin = YES;
        
        self.loginBtn.hidden = NO;
        UIImage* image1= [UIImage imageNamed:@"已登录.png"];
        UIImage* image2= [UIImage imageNamed:@"已登录按下.png"];
        [self.loginBtn setImage:image1 forState:UIControlStateNormal];
        [self.loginBtn setImage:image2 forState:UIControlStateHighlighted];
        
        int total = 0;
        
        NSArray *dbArray = [[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0];
        NSString *userId = [NSString stringWithFormat:@"%d",[[dbArray objectAtIndex:member_info_memberId] intValue]];
        
        NSArray *ayArr = [array objectAtIndex:1];
        int num = [[NSString stringWithFormat:@"%@",[ayArr objectAtIndex:[ayArr count] - 3]] intValue];
        if (num > 0) 
        {
            [DBOperate updateData:T_MEMBER_INFO tableColumn:@"newMessageNum" columnValue:[NSString stringWithFormat:@"%d",num] conditionColumn:@"memberId" conditionColumnValue:userId];
            
            UIView *msgTipView = [[UIView alloc] initWithFrame:CGRectMake(230,1,24,24)];
            msgTipView.tag = 22222;
            
            NSArray *arrayViewControllers = self.navController.viewControllers;
            if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
            {
                CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                [tabViewController.customTab addSubview:msgTipView];
                
                //会员中心消息数字
                if (tabViewController.selectedIndex == 3)
                {
                    [[tabViewController.viewControllers objectAtIndex:3] viewWillAppear:YES];
                }
            }
            else
            {
                tabEntranceViewController *tabViewController = [arrayViewControllers objectAtIndex:0];
                [tabViewController.tabBar addSubview:msgTipView];
                
                //会员中心消息数字
                if (tabViewController.selectedIndex == 3)
                {
                    [[tabViewController.viewControllers objectAtIndex:3] viewWillAppear:YES];
                }
            }
                
            CGFloat fixWidth;
            if (num >= 100)
            {
                fixWidth = 34;
                if (num > 999) 
                {
                    num = 999;
                }
            }
            else
            {
                fixWidth = 24;
            }
            
            UIImage *msgImg = [[UIImage imageNamed:@"小红点.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:24];
            UIImageView *msgImageView = [[UIImageView alloc] initWithImage:msgImg];
            msgImageView.frame = CGRectMake(0, 0, fixWidth, 24);
            msgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [msgTipView addSubview:msgImageView];
            
            NSString *msgNum = [NSString stringWithFormat:@"%d",num];
            UILabel *msgLabel = [[UILabel alloc] initWithFrame:msgImageView.frame];
            msgLabel.text = msgNum;
            msgLabel.textColor = [UIColor whiteColor];
            msgLabel.font = [UIFont systemFontOfSize:14.0f];
            msgLabel.textAlignment = UITextAlignmentCenter;
            msgLabel.backgroundColor = [UIColor clearColor];
            [msgTipView addSubview:msgLabel];
            
            total = num;
        }
        
        int feedback_num = [[NSString stringWithFormat:@"%@",[ayArr objectAtIndex:[ayArr count] - 1]] intValue];
        if (feedback_num > 0) {
            [DBOperate updateData:T_MEMBER_INFO tableColumn:@"feedbackNum" columnValue:[NSString stringWithFormat:@"%d",feedback_num] conditionColumn:@"memberId" conditionColumnValue:userId];
            total = total + 1;
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:total];
	}
    else
    {
        
		_isLogin = NO;
        
        self.loginBtn.hidden = NO;
        UIImage* image= [UIImage imageNamed:@"登录.png"];
		[loginBtn setImage:image forState:UIControlStateNormal];
		[loginBtn setImage:nil forState:UIControlStateHighlighted];
	}
    
}

- (void)apnsResult:(NSMutableArray *)array
{
   
}

#pragma mark -
#pragma mark Application lifecycle

// Handle an actual notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[self showString:userInfo];	
}
-(void)showString:(NSDictionary*)userInfo{
//	NSDictionary *content = [userInfo objectForKey:@"aps"];
//	NSLog(@"receive E %@",content);
//	showPushAlert *pusha = [[showPushAlert alloc]initWithContent:[content objectForKey:@"alert"] onViewController:navController];
//	self.pushAlert = pusha;
//	[pusha release];
//	[pushAlert showAlert];
    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber < 1 ? 0 : [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    showPushAlert *pusha = [[showPushAlert alloc]initWithDic:userInfo onViewController:navController];
    self.pushAlert = pusha;
    [pusha release];
    [pushAlert showAlert];
    
    /*
    NSDictionary *titleDic = [userInfo objectForKey:@"aps"];
    NSString *title = [titleDic objectForKey:@"alert"];
    NSString *url = [userInfo objectForKey:@"url"];
    NSString *type = [userInfo objectForKey:@"type"];
    
    if ([type intValue] == 1 || [type intValue] == 2 || [type intValue] == 0)
    {
        //原来的资讯,产品 1:资讯 2:产品
        showPushAlert *pusha = [[showPushAlert alloc]initWithTitle:title url:url onViewController:navController];
        self.pushAlert = pusha;
        [pusha release];
        [pushAlert showAlert];
    }
    else
    {
        //活动跟消息 3:活动 4:消息
        if ([type intValue] == 3)
        {
            NSString *info_id = [userInfo objectForKey:@"info_id"];
            if ([info_id intValue] > 0)
            {
                activityMainViewController * activityMainView = [[activityMainViewController alloc] init];
                activityMainView.isFromAd = YES;
                activityMainView.infoId = [info_id intValue];
                
                [self.navController pushViewController:activityMainView animated:YES];
                [activityMainView release];
            }
        }
        else if([type intValue] == 4)
        {
            NSString *info_id = [userInfo objectForKey:@"info_id"];
            if ([info_id intValue] > 0)
            {
                NSArray *arrayViewControllers = self.navController.viewControllers;
                if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
                {
                    CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                    [tabViewController selectedTab:[tabViewController.buttons objectAtIndex:3]];
                }
            }
        }
    }
    */
    
    
}
-(void)launchNotification:(NSNotification*)notification{
	
	[self showString:[[notification userInfo]objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
	//NSString *status = [NSString stringWithFormat:@"%@\nRegistration failed.\n\nError: %@", pushStatus(), [error localizedDescription]];
	//[self showString:status];
	//NSLog(@"status %@",status);
    NSLog(@"Error in registration. Error: %@", error); 
    
    //获取位置
    [self getLocation];
}

//ios 8 通知需要多一层代理代理
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    NSLog(@"这是ios8通知新代理方法");
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

//获取token号回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *mydevicetoken = [[[NSMutableString stringWithFormat:@"%@",deviceToken]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""];
	self.myDeviceToken = mydevicetoken;
	NSArray *arr = [[NSArray alloc] initWithObjects:self.myDeviceToken, nil];
    [DBOperate insertData:arr tableName:T_DEVTOKEN];

    //获取位置
    [self getLocation];
}

#pragma mark -
#pragma mark locationManager

-(NSString*)coordToString:(CLLocationCoordinate2D)coord{
	NSString *key = @"ABQIAAAAi0wvL4p1DYOdJ0iL-v2_sxR-h6gSv-DalIHlg2rPU6QFhO9KcRRTQ8IhBeqcKLxlL3lMxiK9r4f7Ug";
	NSString *urlStr = [NSString stringWithFormat:@"http://ditu.google.cn/maps/geo?output=csv&key=%@&q=%lf,%lf&hl=zh-CN",key,coord.latitude,coord.longitude];
	//NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.cn/maps/geo?output=csv&key=%@&q=%lf,%lf&hl=zh-CN",key,coord.latitude,coord.longitude];
	NSURL *url = [NSURL URLWithString:urlStr];
    NSString *retstr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray *resultArray = [retstr componentsSeparatedByString:@","];
	NSLog(@"result %@",resultArray);
	return [resultArray objectAtIndex:2];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[locManager stopUpdatingLocation];
	locManager.delegate = nil;
	//self.locManager = nil;
	@try
    {
		double latitude = newLocation.coordinate.latitude;
		double longitude = newLocation.coordinate.longitude;
		myLocation.latitude = latitude;
		myLocation.longitude = longitude;
		LatitudeAndLongitude = [NSString stringWithFormat:@"%f,%f",longitude,latitude];
        NSString *address = [self coordToString:newLocation.coordinate];
        NSRange range1 = [address rangeOfString:@"国"];
        NSRange range2 = [address rangeOfString:@"省"];
        NSRange range3 = [address rangeOfString:@"市"];
        if (range2.location == NSNotFound)
        {
            NSRange rangepro = NSMakeRange(range1.location +1, range3.location-range1.location);
            self.province = [address substringWithRange:rangepro];
            self.city = province;
        }
        else
        {
            NSRange rangepro = NSMakeRange(range1.location +1, range2.location-range1.location);
            self.province = [address substringWithRange:rangepro];
            NSRange rangecity = NSMakeRange(range2.location +1, range3.location-range2.location);
            self.city = [address substringWithRange:rangecity];		
        }
        NSLog(@"address = %@",address);
        NSRange rancity = [address rangeOfString:@" "];
        rancity.length = rancity.location;
        rancity.location = 0;
        self.addressCity = [address substringWithRange:rancity];
        NSLog(@"self.addressCity = %@",self.addressCity);
        NSLog(@"province %d city %d ",province.length,city.length);
        
        //请求设备令牌接口
        [self apnsAccess];
	}
	@catch (NSException *exception) 
    {
        //请求设备令牌接口
        [self apnsAccess];
        NSLog(@"========获取位置======失败");
		return;
	}
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    [locManager stopUpdatingLocation];
	locManager.delegate = nil;
    
    //请求设备令牌接口
    [self apnsAccess];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [WXApi handleOpenURL:url delegate:self];   // dufu add 2013.04.24
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSDictionary *param;
    NSLog(@"sourceApplication:%@",sourceApplication);
    if (url != nil) {
        param = [NSDictionary dictionaryWithObjectsAndKeys:
                 url,@"url", nil];
    }
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        if (delegate != nil && [delegate respondsToSelector:@selector(handleCallBack:)]) {
            [delegate handleCallBack:param];
        }
        delegate = nil;
        return YES;
    } else {
        return  [WXApi handleOpenURL:url delegate:self];  // dufu add 2013.04.24
    }
}

// 微信部分
#pragma mark - WXApi Delegate
- (void)onReq:(BaseReq *)req  // dufu add 2013.04.24
{
    
}

- (void)onResp:(BaseResp *)resp  // dufu add 2013.04.24
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strMsg = [NSString stringWithFormat:@"发送消息结果:%d",resp.errCode];
        NSLog(@"%@",strMsg);
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	[navController release];
    [loginBtn release];
//	[netWorkQueue release];
//	netWorkQueue = nil;
	[headerImage release];
	[myDeviceToken release],myDeviceToken = nil;
    province = nil;
    city = nil;
    LatitudeAndLongitude = nil;
	[pushAlert release],pushAlert = nil;
    [super dealloc];
}

@end
