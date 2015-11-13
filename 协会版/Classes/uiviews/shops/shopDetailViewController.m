//
//  shopDetailViewController.m
//  Profession
//
//  Created by siphp on 12-8-21.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "shopDetailViewController.h"
#import "Common.h"
#import "UIImageScale.h"
#import "callSystemApp.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "supplyDetailViewController.h"
#import "demandDetailViewController.h"
#import "mapViewController.h"
#import "LoginViewController.h" 
//#import "ShareToBlogViewController.h"  // dufu mod 2013.04.25
#import "alertView.h"
#import "MessageDetailViewController.h"
#import "BaiduMapViewController.h"
#import "browserViewController.h"
#import "HaveAppDownloadViewController.h"
#import "NoAppDownloadViewController.h"

#define TOPVIEWMARGIN 10.0f
#define MARGIN 5.0f

#define EXPANSION   0

@interface UINavigationItem (margin)

@end

@implementation UINavigationItem (margin)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;
        
        if (_leftBarButtonItem)
        {
            [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
        }
        else
        {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
        [negativeSeperator release];
    }
    else
    {
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -5;
        
        if (_rightBarButtonItem)
        {
            [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
        }
        else
        {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
        [negativeSeperator release];
    }
    else
    {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

#endif
@end

@implementation shopDetailViewController

@synthesize shopID;
@synthesize spinner;
@synthesize shopItems;
@synthesize myTableView;
@synthesize supplyItems;
@synthesize demandItems;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
//@synthesize actionSheet; // dufu mod 2013.04.25
@synthesize progressHUD;
@synthesize userId;
@synthesize favoritebutton;
@synthesize dragCard;
@synthesize senderId;
@synthesize sourceName;
@synthesize sourceImage;
@synthesize moreLabel;

@synthesize ShareSheet; // dufu add 2013.04.25 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
	
	self.title = @"单位";

	logoWith = 75;
	logoHigh = 75;
	
	photoWith = 62;
	photoHigh = 62;
    
    currentButtonTag = 1002;
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
	
	//供应数据初始化
	NSMutableArray *tempSupplyArray = [[NSMutableArray alloc] init];
	self.supplyItems = tempSupplyArray;
	[tempSupplyArray release];
	
	//求购数据初始化
	NSMutableArray *tempDemandArray = [[NSMutableArray alloc] init];
	self.demandItems = tempDemandArray;
	[tempDemandArray release];
	
	//self.view.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	
    UIView *topView = nil;
    UIView *contentView = nil;

    if (IS_SHOW_APP == 1) {
        topView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, 267.0f)];
        contentView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 267.0f , self.view.frame.size.width, self.view.frame.size.height - 44.0f - 267.0f)];
    }else {
        topView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, 227.0f)];
        contentView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 227.0f , self.view.frame.size.width, self.view.frame.size.height - 44.0f - 227.0f)];
    }
	
	
	topView.backgroundColor = [UIColor clearColor];
	topView.tag = 1000;
	contentView.backgroundColor = [UIColor clearColor];
	contentView.tag = 2000;
	
	[self.view addSubview:topView];
	[self.view addSubview:contentView];
    
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"返回按钮" ofType:@"png"]];
    UIButton *barbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    barbutton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    [barbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [barbutton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:barbutton];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    [barBtnItem release];
	
	//添加loading图标
	UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	[tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f) / 2.0)];
	self.spinner = tempSpinner;
	
	UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
	loadingLabel.font = [UIFont systemFontOfSize:14];
	loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	loadingLabel.text = LOADING_TIPS;		
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.backgroundColor = [UIColor clearColor];
	[self.spinner addSubview:loadingLabel];
	[self.view addSubview:self.spinner];
	[self.spinner startAnimating];
	[tempSpinner release];
	
	//获取当前用户的user_id
	NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
	if ([memberArray count] > 0) 
	{
		self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
	}
	else 
	{
		self.userId = @"0";
	}
	
	//判断该信息是否为当前用户收藏
	NSMutableArray *favorite = (NSMutableArray *)[DBOperate queryData:T_SHOP_FAVORITE theColumn:@"shop_id" equalValue:shopID theColumn:@"user_id" equalValue:self.userId];
	
	if (favorite == nil || [favorite count] == 0) 
	{
		//没有收藏
		isFavorite = NO;
	}
	else 
	{
		//已收藏
		isFavorite = YES;
	}
	
	//取商铺的数据
	if (self.shopItems == nil || [self.shopItems count] == 0)
	{
		self.shopItems = (NSMutableArray *)[DBOperate queryData:T_SHOP theColumn:@"id" theColumnValue:shopID  withAll:NO];
	}
    
	if (self.shopItems == nil || [self.shopItems count] == 0) 
	{
		//记录不存在 则网络获取
		[self accessShopItemService];
	}
	else
	{
		//记录已存在
		[self.spinner removeFromSuperview];
		[self createTopView];
		[self showDesc];
        [self createDragCard];
	}

    isContactFavorite = NO;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//构建顶部布局
-(void)createTopView
{
	NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
	UIView *topView = [self.view viewWithTag:1000];
    
	topView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	
	UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(TOPVIEWMARGIN, TOPVIEWMARGIN, logoWith, logoHigh)];
	picView.tag = 1001;
//    picView.layer.masksToBounds = YES;
//    picView.layer.cornerRadius = 10;
	[topView addSubview:picView];
	[picView release];
	
	//loading商铺logo图片
	UIImageView *logoPicView = (UIImageView *)[topView viewWithTag:1001];
	NSString *logoUrl = [shopInfo objectAtIndex:shop_pic];
	if (logoUrl.length > 1) 
	{
		NSIndexPath *logoIndexPath = [NSIndexPath indexPathForRow:10000 inSection:0];
		
		//获取本地图片缓存
		UIImage *cardIcon = [[self getPhoto:logoIndexPath]fillSize:CGSizeMake(logoWith, logoHigh)];
		if (cardIcon == nil)
		{
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺列表默认图片" ofType:@"png"]];
			logoPicView.image = [img fillSize:CGSizeMake(logoWith, logoHigh)];
			[img release];
            showType = 1;
			[self startIconDownload:logoUrl forIndexPath:logoIndexPath];
		}
		else
		{
			logoPicView.image = cardIcon;
		}
		
	}
	else
	{
		UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺列表默认图片" ofType:@"png"]];
		logoPicView.image = [img fillSize:CGSizeMake(logoWith, logoHigh)];
		[img release];
	}
    
    
	//认证的图标
	if ([[shopInfo objectAtIndex:shop_attestation] isEqualToString:@"1"])
	{
		UIImageView *attestationImageView = [[UIImageView alloc] initWithFrame:CGRectMake( TOPVIEWMARGIN - 1.0f, 15.0f, 34.0f , 34.0f)];
		UIImage *attestationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺认证标识" ofType:@"png"]];
		attestationImageView.image = attestationImage;
		[attestationImage release];
		[topView addSubview:attestationImageView];
		[attestationImageView release];
	}
	//会员等级的图标
    //	if ([[shopInfo objectAtIndex:shop_shop_ulevel] isEqualToString:@"3"])
    //	{
    //		UIImageView *attestationImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 270.0f, TOPVIEWMARGIN - 5.0f, 32.0f , 32.0f)];
    //		UIImage *attestationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"白金会员" ofType:@"png"]];
    //		attestationImageView.image = attestationImage;
    //		[attestationImage release];
    //		[topView addSubview:attestationImageView];
    //		[attestationImageView release];
    //		
    //	}else if ([[shopInfo objectAtIndex:shop_shop_ulevel] isEqualToString:@"4"]) {
    //		UIImageView *attestationImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 270.0f , TOPVIEWMARGIN - 5.0f, 32.0f , 32.0f)];
    //		UIImage *attestationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员_钻石" ofType:@"png"]];
    //		attestationImageView.image = attestationImage;
    //		[attestationImage release];
    //		[topView addSubview:attestationImageView];
    //		[attestationImageView release];
    //	}
	
	UILabel *shopTitle = [[UILabel alloc]initWithFrame:CGRectMake(TOPVIEWMARGIN * 2 + 80.0f, TOPVIEWMARGIN , 200.0f, 75)];
	shopTitle.backgroundColor = [UIColor clearColor];
	//shopTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	shopTitle.font = [UIFont systemFontOfSize:18];
    shopTitle.numberOfLines = 3;
	shopTitle.textColor = [UIColor colorWithRed:0.0 green: 0.0 blue: 0.0 alpha:1.0];
	shopTitle.text = [shopInfo objectAtIndex:shop_title];
	[topView addSubview:shopTitle];
	[shopTitle release];

    //=============================
    //拨打电话
	UIButton *telButtonImage = [UIButton buttonWithType:UIButtonTypeCustom];
	telButtonImage.frame = CGRectMake(TOPVIEWMARGIN, 95.0f, 300.0f, 43.0f);
	[telButtonImage addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    UIImage *telBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形上" ofType:@"png"]];
	[telButtonImage setBackgroundImage:telBackgroundImage forState:UIControlStateNormal];
	[topView addSubview:telButtonImage];
    [telBackgroundImage release];
    
    //电话的icon
    UIImageView *phoneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
    UIImage *phoneImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"电话icon" ofType:@"png"]];
    phoneImageView.image = phoneImage;
    [phoneImage release];
    [telButtonImage addSubview:phoneImageView];
    [phoneImageView release];
    
    //拨打的icon
    UIImageView *callImageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 7.0f, 30, 30)];
    UIImage *callImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
    callImageView.image = callImage;
    [callImage release];
    [telButtonImage addSubview:callImageView];
    [callImageView release];
    
    //电话号码
    UILabel *telInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 1.0f, 200.0f, 40.0f)];
	[telInfoLabel setFont:[UIFont systemFontOfSize:16.0f]];
	telInfoLabel.textColor = [UIColor colorWithRed:0.0 green: 0.0 blue: 0.0 alpha:1.0];
	telInfoLabel.text = [shopInfo objectAtIndex:shop_tel];
	telInfoLabel.backgroundColor = [UIColor clearColor];
	telInfoLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	[telButtonImage addSubview:telInfoLabel];
	[telInfoLabel release];
    
    //=============================
    //显示地图 
	UIButton *addressButtonImage = [UIButton buttonWithType:UIButtonTypeCustom];
	addressButtonImage.frame = CGRectMake(TOPVIEWMARGIN, 138.0f, 300.0f, 43.0f);
	[addressButtonImage addTarget:self action:@selector(showMapByCoord) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *addressBackgroundImage = nil;
    if (IS_SHOW_APP == 1) {
        addressBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形中" ofType:@"png"]];
    }else {
        addressBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形下" ofType:@"png"]];
    }
	[addressButtonImage setBackgroundImage:addressBackgroundImage forState:UIControlStateNormal];
	[topView addSubview:addressButtonImage];
	[addressBackgroundImage release];
    
    //地址的icon
    UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
    UIImage *addressImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"地址icon" ofType:@"png"]];
    addressImageView.image = addressImage;
    [addressImage release];
    [addressButtonImage addSubview:addressImageView];
    [addressImageView release];
    
    //定位的icon
    UIImageView *locationImageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 7.0f, 30, 30)];
    UIImage *locationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"定位icon" ofType:@"png"]];
    locationImageView.image = locationImage;
    [locationImage release];
    [addressButtonImage addSubview:locationImageView];
    [locationImageView release];
    
    //地址
    UILabel *addressInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 1.0f, 200.0f, 40.0f)];
	addressInfoLabel.textColor = [UIColor colorWithRed:0.0 green: 0.0 blue: 0.0 alpha:1.0];
	addressInfoLabel.text = [shopInfo objectAtIndex:shop_address];
	addressInfoLabel.backgroundColor = [UIColor clearColor];
    
    addressInfoLabel.numberOfLines = 2;
    
    if ([[shopInfo objectAtIndex:shop_address] length] < 10) 
    {
        [addressInfoLabel setFont:[UIFont systemFontOfSize:16.0f]];
    }
    else if([[shopInfo objectAtIndex:shop_address] length] < 25) 
    {
        [addressInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }
    else 
    {
        [addressInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    }
    
	//addressInfoLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	[addressButtonImage addSubview:addressInfoLabel];
	[addressInfoLabel release];
    
    if (IS_SHOW_APP == 1) {
        //下载APP
        UIButton *telButtonImage = [UIButton buttonWithType:UIButtonTypeCustom];
        telButtonImage.frame = CGRectMake(TOPVIEWMARGIN, 181.0f, 300.0f, 43.0f);
        [telButtonImage addTarget:self action:@selector(downloadApp) forControlEvents:UIControlEventTouchUpInside];
        UIImage *telBackgroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形下" ofType:@"png"]];
        [telButtonImage setBackgroundImage:telBackgroundImage forState:UIControlStateNormal];
        [topView addSubview:telButtonImage];
        [telBackgroundImage release];
        
        //电话的icon
        UIImageView *phoneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
        UIImage *phoneImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_企业移动APP" ofType:@"png"]];
        phoneImageView.image = phoneImage;
        [phoneImage release];
        [telButtonImage addSubview:phoneImageView];
        [phoneImageView release];
        
        //拨打的icon
        UIImageView *callImageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 7.0f, 30, 30)];
        UIImage *callImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_向右箭头" ofType:@"png"]];
        callImageView.image = callImage;
        [callImage release];
        [telButtonImage addSubview:callImageView];
        [callImageView release];
        
        //电话号码
        UILabel *telInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 1.0f, 200.0f, 40.0f)];
        [telInfoLabel setFont:[UIFont systemFontOfSize:16.0f]];
        telInfoLabel.textColor = [UIColor colorWithRed:0.0 green: 0.0 blue: 0.0 alpha:1.0];
        telInfoLabel.text = @"企业移动APP";
        telInfoLabel.backgroundColor = [UIColor clearColor];
        telInfoLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        [telButtonImage addSubview:telInfoLabel];
        [telInfoLabel release];
    }
    
	//=============================
	//添加切换按钮
    if (IS_SHOW_APP == 1) {
        segmentBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 231.0f, self.view.frame.size.width, 36.0f)];
    }else {
        segmentBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 191.0f, self.view.frame.size.width, 36.0f)];
    }
    
    segmentBg.backgroundColor = [UIColor clearColor];
    [topView addSubview:segmentBg];
    
	UIImageView *buttonBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 36.0f)];
	buttonBackGround.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺详情标签页背景" ofType:@"png"]];
	
	[segmentBg addSubview:buttonBackGround];
	[buttonBackGround release];
    
    //添加选中效果
	UIImageView *currentImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, (self.view.frame.size.width / 2), 36.0f)];
	currentImage.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺详情标签页背景选中" ofType:@"png"]];
	currentImage.tag = 1005;
	[segmentBg addSubview:currentImage];
	[currentImage release];

	//添加按钮
	NSArray *buttonTitle = [[NSArray alloc]initWithObjects:[shopInfo objectAtIndex:shop_aboutus_title],[shopInfo objectAtIndex:shop_myproduct_title],nil];
	float buttonX = 0.0f;
	float buttonWidth = topView.frame.size.width / 2;
	float buttonHeight = 36.0f;
	int bTag = 1001;
	for (NSString *bTitleInfo in buttonTitle)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setFrame:CGRectMake(buttonX, 0.0f, buttonWidth, buttonHeight)];
		[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
		buttonX += buttonWidth;
		button.tag = ++bTag;
		
		UILabel *bTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
		bTitle.font = [UIFont boldSystemFontOfSize:14.0];
		bTitle.textAlignment = UITextAlignmentCenter;
		bTitle.backgroundColor = [UIColor clearColor];
        bTitle.tag = 5000+button.tag;
        if (bTag == 1002) 
        {
            bTitle.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        }
        else
        {
            bTitle.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        }
		
		bTitle.text = bTitleInfo;
		[button addSubview:bTitle];
		[bTitle release];
		
		UIImage *unClickImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺详情标签页背景未选中" ofType:@"png"]];
		[button setImage:unClickImg forState:UIControlStateNormal];
		[button setImage:unClickImg forState:UIControlStateSelected];
		[unClickImg release];
		[segmentBg addSubview:button];
	}
	
	//添加分享 收藏按钮
	UIView* operatButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
	
	UIButton *sharebutton = [UIButton buttonWithType:UIButtonTypeCustom];  
    sharebutton.frame = CGRectMake(2.0f, 0.0f, 40.0f, 40.0f);  
	[sharebutton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchDown];
	[sharebutton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺详情分享按钮" ofType:@"png"]] forState:UIControlStateNormal];  
    [operatButtonView addSubview:sharebutton]; 
	
	self.favoritebutton = [UIButton buttonWithType:UIButtonTypeCustom];  
    self.favoritebutton.frame = CGRectMake(42.0f, 0.0f, 40.0f, 40.0f);  
    
	[self.favoritebutton addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchDown];
    NSString *favoriteImgName = isFavorite ? @"商铺详情已收藏按钮" : @"商铺详情收藏按钮";
	[self.favoritebutton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:favoriteImgName ofType:@"png"]] forState:UIControlStateNormal];  
    [operatButtonView addSubview:self.favoritebutton]; 
	
	UIBarButtonItem *operatButton = [[UIBarButtonItem alloc] initWithCustomView:operatButtonView]; 
	self.navigationItem.rightBarButtonItem = operatButton;
	[operatButton release]; 
	[operatButtonView release];
	
}

//构建拖拽名片
-(void)createDragCard
{
    //先从通讯录里面 获取用户数据
    NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
    NSString *cUserId = [shopInfo objectAtIndex:shop_shop_uid];
    
    //查询数据库 获取到数据
    NSMutableArray *memberInfo = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK theColumn:@"user_id" theColumnValue:cUserId withAll:NO];
    
    NSMutableArray *cardInfo = nil;
    if ([memberInfo count] > 0)
    {
        cardInfo = (NSMutableArray *)[memberInfo objectAtIndex:0];
    }
    
    //[self.navigationController.navigationBar setTranslucent:NO];
    dragCardViewController *tempDragCard = [[dragCardViewController alloc] initWithFrame:CGRectMake( 0.0f , self.view.frame.size.height - 36.0f - 44.0f, 320.0f , 364.0f) info:cardInfo userID:cUserId];
    //dragCardViewController *tempDragCard = [[dragCardViewController alloc] init];
    //tempDragCard.cardInfo = cardInfo;
    tempDragCard.delegate = self;
    self.dragCard = tempDragCard;
    [self.view addSubview:self.dragCard.view];
    [tempDragCard release];
    
    self.senderId = cUserId;
    self.sourceName = [cardInfo objectAtIndex:contactsbook_favorite_user_name];
    self.sourceImage = [cardInfo objectAtIndex:contactsbook_favorite_img];
}

//显示位置
-(void)showMapByCoord
{
	NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
	
	NSString *shopInfoLat = [shopInfo objectAtIndex:shop_lat];
	NSString *shopInfoLng = [shopInfo objectAtIndex:shop_lng];
    
    BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc] init];
    baiduMap.latitude = [shopInfoLat doubleValue];
    baiduMap.longitude = [shopInfoLng doubleValue];
    baiduMap.phone = [shopInfo objectAtIndex:shop_tel];
    baiduMap.addrStr = [shopInfo objectAtIndex:shop_address];
    baiduMap.title = @"企业地址";
    baiduMap.navigationItem.title = @"我的位置";
    [self.navigationController pushViewController:baiduMap animated:YES];
}

//拨打电话
-(void)callPhone
{
	NSString *shopTel = [[self.shopItems objectAtIndex:0] objectAtIndex:shop_tel];
	if (shopTel.length > 1) {
		[callSystemApp makeCall:shopTel];
	}
}

//下载APP
-(void)downloadApp
{
    //NSLog(@"hui===== %@",[[self.shopItems objectAtIndex:0] objectAtIndex:shop_iphone_url]);
	if (![[[self.shopItems objectAtIndex:0] objectAtIndex:shop_iphone_url] isEqualToString:@""]) {
        HaveAppDownloadViewController *haveApp = [[HaveAppDownloadViewController alloc] init];
        haveApp.logoImageUrl = [[self.shopItems objectAtIndex:0] objectAtIndex:shop_app_image];
        haveApp.appName = [[self.shopItems objectAtIndex:0] objectAtIndex:shop_app_name];
        haveApp.appUrl = [[self.shopItems objectAtIndex:0] objectAtIndex:shop_iphone_url];
        [self.navigationController pushViewController:haveApp animated:YES];
        [haveApp release];
    }else {
        NoAppDownloadViewController *noApp = [[NoAppDownloadViewController alloc] init];
        noApp.uId = [NSString stringWithFormat:@"%d",[[[self.shopItems objectAtIndex:0] objectAtIndex:shop_shop_uid] intValue]];
        [self.navigationController pushViewController:noApp animated:YES];
        [noApp release];
    }
}

//分享
-(void)share
{    
    // dufu  add 2013.04.25
    // 分享创建实例
    if (ShareSheet == nil) {
        ShareSheet = [[ShareAction alloc]init];
    }
    
    ShareSheet.shareDelegate = self;
    
    // 分享显示弹窗
    [ShareSheet shareActionShow:self.view navController:self.navigationController];
	
}

// 分享委托
#pragma mark - Share Delegate
- (NSDictionary *)shareSheetRetureValue  // dufu add 2013.04.25
{
    NSString *str = @"company/view/";
	NSString *link = [NSString stringWithFormat:@"%@%@%d",DETAIL_SHARE_LINK,str,[shopID intValue]];
	NSString *content = [[self.shopItems objectAtIndex:0] objectAtIndex:shop_title];
	NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
    
    NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
    NSString *photoUrl = [shopInfo objectAtIndex:shop_pic];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    // 分享的内容信息字典
    NSDictionary *dict;
    
    if (photoUrl.length > 1)
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [FileManager getPhoto:picName],ShareImage,
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl, nil];
    }
    else
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl,  nil];
    }
    return dict;
}

//收藏
-(void)favorite
{
	if (!isFavorite)
	{
		//判断用户是否登陆
		if (_isLogin == YES) 
		{
			if ([self.userId intValue] != 0)
			{
				MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
				self.progressHUD = progressHUDTmp;
				[progressHUDTmp release];
				self.progressHUD.delegate = self;
				self.progressHUD.labelText = @"发送中... ";
				[self.view addSubview:self.progressHUD];
				[self.view bringSubviewToFront:self.progressHUD];
				[self.progressHUD show:YES];
				
				NSString *reqUrl = @"member/favorites.do?param=%@";
				
				NSArray *shopInfo = [self.shopItems objectAtIndex:0];
				
				NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
											 [Common getSecureString],@"keyvalue",
											 [NSNumber numberWithInt: SITE_ID],@"site_id",
											 self.userId,@"user_id",
											 [shopInfo objectAtIndex:shop_id],@"info_id",
											 [NSNumber numberWithInt: 1],@"info_type",
											 [shopInfo objectAtIndex:shop_title],@"title",
											 nil];
				
				[[DataManager sharedManager] accessService:jsontestDic 
												   command:OPERAT_SEND_SHOP_FAVORITE
											  accessAdress:reqUrl 
												  delegate:self 
												 withParam:nil];
			}
			else
			{
				LoginViewController *login = [[LoginViewController alloc] init];
                login.delegate = self;
				[self.navigationController pushViewController:login animated:YES];
				[login release];
			}
			
		}
		else 
		{
			LoginViewController *login = [[LoginViewController alloc] init];
            login.delegate = self;
			[self.navigationController pushViewController:login animated:YES];
			[login release];
		}
	}
	else 
	{
		MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
		self.progressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.progressHUD.delegate = self;
		self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		self.progressHUD.mode = MBProgressHUDModeCustomView;
		self.progressHUD.labelText = @"该信息已收藏";
		[self.view addSubview:self.progressHUD];
		[self.view bringSubviewToFront:self.progressHUD];
		[self.progressHUD show:YES];
		
		[progressHUD hide:YES afterDelay:1.0f];
	}
    
}

//切换按钮
-(void)buttonClick:(id)sender
{
	UIView *topView = [self.view viewWithTag:1000];
	UIImageView *currentImage = (UIImageView *)[segmentBg viewWithTag:1005];
    UIView *contentView = [self.view viewWithTag:2000];
	CGRect currentImageFrame = currentImage.frame;
    CGRect topViewFrame = topView.frame;
    CGRect contentViewFrame = contentView.frame;
    
    //字
    UILabel *bTitle1 = (UILabel *)[topView viewWithTag:6002];
    UILabel *bTitle2 = (UILabel *)[topView viewWithTag:6003];
	
	UIButton *currentButton = sender;
	switch (currentButton.tag) 
	{
		case 1002:
		{
            currentButtonTag = 1002;
			currentImageFrame.origin.x = 0.0f;
            topViewFrame.origin.y = IS_SHOW_APP == 1 ? -231.0f : -191.0f;
            contentViewFrame.origin.y = 36.0f;
            contentViewFrame.size.height = self.view.frame.size.height - 36.0f;
            
            UIScrollView *scrollView = (UIScrollView *)[contentView viewWithTag:2001];
            CGRect scrollViewFrame = contentViewFrame;
            CGSize scrollViewSize = scrollView.contentSize;
            scrollViewFrame.origin.y = 0.0f;
            scrollViewSize.height = fixHeight > contentViewFrame.size.height ? fixHeight + 20.0f : contentViewFrame.size.height + 1.0f;
            
            //设置字体颜色
            bTitle1.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            bTitle2.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
			
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			currentImage.frame = currentImageFrame;
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            scrollView.frame = scrollViewFrame;
            scrollView.contentSize = scrollViewSize;
            
			// commit animations
			[UIView commitAnimations];
            
            [self showDesc];
            
			break;
		}
		case 1003:
		{
            currentButtonTag = 1003;
			currentImageFrame.origin.x = self.view.frame.size.width / 2;
            topViewFrame.origin.y = IS_SHOW_APP == 1 ? -231.0f : -191.0f;
            contentViewFrame.origin.y = 36.0f;
            contentViewFrame.size.height = self.view.frame.size.height - 36.0f;
            CGRect myTableViewFrame = contentViewFrame;
            myTableViewFrame.origin.y = 0.0f;
            
            //设置字体颜色
            bTitle1.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
            bTitle2.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
			
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			currentImage.frame = currentImageFrame;
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            self.myTableView.frame = myTableViewFrame;
            
			// commit animations
			[UIView commitAnimations];
			
			[self showSupply];
			break;
		}
		case 1004:
		{
            currentButtonTag = 1004;
			currentImageFrame.origin.x = (self.view.frame.size.width / 3)*2;
            topViewFrame.origin.y = IS_SHOW_APP == 1 ? -231.0f : -191.0f;
            contentViewFrame.origin.y = 36.0f;
            contentViewFrame.size.height = self.view.frame.size.height - 36.0f;
            CGRect myTableViewFrame = contentViewFrame;
            myTableViewFrame.origin.y = 0.0f;
			
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			currentImage.frame = currentImageFrame;
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            self.myTableView.frame = myTableViewFrame;
            
			// commit animations
			[UIView commitAnimations];
			
			[self showDemand];
			break;
		}
		default:
			break;
	}
	//[self topViewAnimation:@"up"];
}

//顶部内容上下动画效果
-(void)topViewAnimation:(NSString *)type
{
    UIView *topView = [self.view viewWithTag:1000];
    UIView *contentView = [self.view viewWithTag:2000];
    CGRect topViewFrame = topView.frame;
    CGRect contentViewFrame = contentView.frame;
    
    if ([type isEqualToString:@"up"]) 
    {
        topViewFrame.origin.y = IS_SHOW_APP == 1 ? -231.0f : -191.0f;
        contentViewFrame.origin.y = 36.0f;
        contentViewFrame.size.height = self.view.frame.size.height - 36.0f;
    }
    else if ([type isEqualToString:@"down"])
    {
        topViewFrame.origin.y = 0.0f;
        contentViewFrame.origin.y = IS_SHOW_APP == 1 ? 267.0f: 227.0f;
        contentViewFrame.size.height = IS_SHOW_APP == 1 ? self.view.frame.size.height - 267.0f : self.view.frame.size.height - 227.0f;
    }
    
    
	switch (currentButtonTag) 
	{
		case 1002:
		{
            UIScrollView *scrollView = (UIScrollView *)[contentView viewWithTag:2001];
            CGRect scrollViewFrame = contentViewFrame;
            CGSize scrollViewSize = scrollView.contentSize;
            scrollViewFrame.origin.y = 0.0f;
            
            scrollViewSize.height = fixHeight > contentViewFrame.size.height ? fixHeight + 20.0f : contentViewFrame.size.height + 1.0f;
            
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            scrollView.frame = scrollViewFrame;
            scrollView.contentSize = scrollViewSize;
			// commit animations
			[UIView commitAnimations];
            
			break;
		}
		case 1003:
		{
            CGRect myTableViewFrame = contentViewFrame;
            myTableViewFrame.origin.y = 0.0f;
            
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            self.myTableView.frame = myTableViewFrame;
            
			// commit animations
			[UIView commitAnimations];
            
			break;
		}
		case 1004:
		{
            CGRect myTableViewFrame = contentViewFrame;
            myTableViewFrame.origin.y = 0.0f;
            
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:0];
			
			// set views with new info
			topView.frame = topViewFrame;
			contentView.frame = contentViewFrame;
            self.myTableView.frame = myTableViewFrame;
            
			// commit animations
			[UIView commitAnimations];
            
			break;
		}
		default:
			break;
	}
}

//移出contentView里面所有view
-(void)removeContentAllView
{
	UIView *contentView = [self.view viewWithTag:2000];
	NSArray *viewsToRemove = [contentView subviews]; 
	for (UIView *v in viewsToRemove) 
	{
		[v removeFromSuperview];
	}
}

//显示简介
-(void)showDesc
{
	NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
	UIView *contentView = [self.view viewWithTag:2000];
	
	//移出所有子视图 重新构建内容
	[self removeContentAllView];
	
	contentView.backgroundColor = [UIColor whiteColor];
	
	UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , contentView.frame.size.width, contentView.frame.size.height)];
	tmpScroll.contentSize = CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
	tmpScroll.pagingEnabled = NO;
    tmpScroll.delegate = self;
	tmpScroll.showsHorizontalScrollIndicator = NO;
	tmpScroll.showsVerticalScrollIndicator = NO;
	tmpScroll.bounces = YES;
    tmpScroll.tag = 2001;
	
	UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[descInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
	descInfoLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
	descInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
	descInfoLabel.numberOfLines = 0;
	NSString *descText = [shopInfo objectAtIndex:shop_desc];
	descInfoLabel.text = descText;
	CGSize constraint = CGSizeMake(300, 20000.0f);
	CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	fixHeight = size.height;
	fixHeight = fixHeight == 0 ? 30.f : MAX(fixHeight,30.0f);
	[descInfoLabel setFrame:CGRectMake(12, 10, 300, fixHeight)];
	[tmpScroll addSubview:descInfoLabel];
	[descInfoLabel release];
    
    CGFloat contentSizeHeight = fixHeight > contentView.frame.size.height ? fixHeight + 20.0f : contentView.frame.size.height + 1.0f;
    
	tmpScroll.contentSize = CGSizeMake(contentView.frame.size.width, contentSizeHeight);
	[contentView addSubview:tmpScroll];
	[tmpScroll release];
}

//显示供应
-(void)showSupply
{
    _loadingMore = NO;
    
	UIView *contentView = [self.view viewWithTag:2000];
	contentView.backgroundColor = [UIColor clearColor];
	
	//移出所有子视图 重新构建内容
	[self removeContentAllView];
	
	//添加loading图标
	UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	[tempSpinner setCenter:CGPointMake(contentView.frame.size.width / 3, contentView.frame.size.height / 2.0)];
	self.spinner = tempSpinner;
	
	UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
	loadingLabel.font = [UIFont systemFontOfSize:14];
	loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	loadingLabel.text = LOADING_TIPS;		
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.backgroundColor = [UIColor clearColor];
	[self.spinner addSubview:loadingLabel];
	[contentView addSubview:self.spinner];
	[self.spinner startAnimating];
	[tempSpinner release];
	
	//设置类型
	showType = 1;
	
	//从数据库中取出数据 模拟数据
	//self.supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY theColumn:@"company_id" theColumnValue:shopID  withAll:YES];
	
	if (self.supplyItems == nil || [self.supplyItems count] == 0) 
	{
		//从网络请求
		[self accessItemService:OPERAT_SHOP_SUPPLY_REFRESH itemsUpdateTime:0];
	}
	else 
	{
		//添加表视图
		[self.spinner removeFromSuperview];	
		[self addTableView];
	}
}

//显示求购
-(void)showDemand
{
    _loadingMore = NO;
    
	UIView *contentView = [self.view viewWithTag:2000];
	contentView.backgroundColor = [UIColor clearColor];
	
	//移出所有子视图 重新构建内容
	[self removeContentAllView];
	
	//添加loading图标
	UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	[tempSpinner setCenter:CGPointMake(contentView.frame.size.width / 3, contentView.frame.size.height / 2.0)];
	self.spinner = tempSpinner;
	
	UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
	loadingLabel.font = [UIFont systemFontOfSize:14];
	loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	loadingLabel.text = LOADING_TIPS;		
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.backgroundColor = [UIColor clearColor];
	[self.spinner addSubview:loadingLabel];
	[contentView addSubview:self.spinner];
	[self.spinner startAnimating];
	[tempSpinner release];
	
	//设置类型
	showType = 2;
	
	//从数据库中取出数据 
	//self.demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND theColumn:@"company_id" theColumnValue:shopID withAll:NO];
	
	if (self.demandItems == nil || [self.demandItems count] == 0) 
	{
		//本地没有数据 则从网络请求
		[self accessItemService:OPERAT_SHOP_DEMAND_REFRESH itemsUpdateTime:0];
	}
	else 
	{
		//添加表视图
		[self.spinner removeFromSuperview];	
		[self addTableView];
	}
}

//添加数据表视图
-(void)addTableView;
{
	[self.myTableView removeFromSuperview];
	UIView *contentView = [self.view viewWithTag:2000];
	
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , contentView.frame.size.width , contentView.frame.size.height)];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[contentView addSubview:myTableView];
}

//滚动loading图片
- (void)loadImagesForOnscreenRows
{
	//NSLog(@"load images for on screen");
	NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		int countItems = [self.supplyItems count];
		if (countItems >[indexPath row])
		{
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
			
			if (cardIcon == nil)
			{
				if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
				{
					NSString *photoURL = [self getPhotoURL:indexPath];
					[self startIconDownload:photoURL forIndexPath:indexPath];
				}
			}
			else
			{
				picView.image = cardIcon;
			}
			
		}
		
	}
}

//获取图片链接
-(NSString*)getPhotoURL:(NSIndexPath *)indexPath
{
	NSArray *supplyArray = [self.supplyItems objectAtIndex:[indexPath row]];
	return [supplyArray objectAtIndex:supply_pic];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	if ([indexPath row] == 10000)
	{
		NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[shopInfo objectAtIndex:shop_pic] dataUsingEncoding: NSUTF8StringEncoding]];
		if (picName.length > 1) {
			return [FileManager getPhoto:picName];
		}
		else {
			return nil;
		}
	}
	else
	{
		int countItems = [self.supplyItems count];
		
		if (countItems > [indexPath row]) 
		{
			NSArray *supplyArray = [self.supplyItems objectAtIndex:[indexPath row]];
			NSString *picName = [Common encodeBase64:(NSMutableData *)[[supplyArray objectAtIndex:supply_pic] dataUsingEncoding: NSUTF8StringEncoding]];
			if (picName.length > 1) {
				return [FileManager getPhoto:picName];
			}
			else {
				return nil;
			}
		}
		else {
			
			return nil;
		}
	}
	
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
	if ([indexPath row] == 10000)
	{
		NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[shopInfo objectAtIndex:shop_pic] dataUsingEncoding: NSUTF8StringEncoding]];
		
		//保存缓存图片
		if([FileManager savePhoto:picName withImage:photo])
		{
			return YES;
		}
		else 
		{
			return NO;
		}
	}
	else
	{
		int countItems = [self.supplyItems count];
		
		if (countItems > [indexPath row]) 
		{
			NSArray *supplyArray = [self.supplyItems objectAtIndex:[indexPath row]];
			NSString *picName = [Common encodeBase64:(NSMutableData *)[[supplyArray objectAtIndex:supply_pic] dataUsingEncoding: NSUTF8StringEncoding]];
			//保存缓存图片
			if([FileManager savePhoto:picName withImage:photo])
			{
				return YES;
			}
			else 
			{
				return NO;
			}
			
		}
		return NO;
	}
	
}

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil && photoURL != nil && photoURL.length > 1) 
    {
		if ([imageDownloadsInProgress count]>= 5) {
			imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:photoURL withIndexPath:indexPath withImageType:CUSTOMER_PHOTO];
			[imageDownloadsInWaiting addObject:one];
			[one release];
			return;
		}
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = photoURL;
        iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.imageType = CUSTOMER_PHOTO;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    if (showType ==  1) 
	{
        IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader != nil)
        {
            UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            // Display the newly loaded image
            if(iconDownloader.cardIcon.size.width>2.0)
            { 
                //保存图片
                [self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
                
                if ([indexPath row] == 10000) 
                {
                    UIView *topView = [self.view viewWithTag:1000];
                    UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(logoWith, logoHigh)];
                    UIImageView *picView = (UIImageView *)[topView viewWithTag:1001];
                    picView.image = photo;
                }
                else
                {
                    UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
                    UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
                    picView.image = photo;
                }
                
            }
            
            [imageDownloadsInProgress removeObjectForKey:indexPath];
            if ([imageDownloadsInWaiting count]>0) 
            {
                imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
                [self startIconDownload:one.imageURL forIndexPath:one.indexPath];
                [imageDownloadsInWaiting removeObjectAtIndex:0];
            }
            
        }
    }
}

//网络商铺获取数据
-(void)accessShopItemService
{
	NSString *reqUrl = @"shop/company.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 self.shopID,@"company_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic 
									   command:OPERAT_SHOP_INFO
								  accessAdress:reqUrl 
									  delegate:self 
									 withParam:nil];
}

//网络获取数据
-(void)accessItemService:(int)commandid itemsUpdateTime:(int)itemUpdateTime
{
	NSString *reqUrl = (commandid == OPERAT_SHOP_SUPPLY_REFRESH || commandid ==  OPERAT_SHOP_SUPPLY_MORE) ? @"shop/myproducts.do?param=%@" : @"shop/mytrades.do?param=%@";
	
	NSMutableArray *shopInfo = [self.shopItems objectAtIndex:0];
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt:SITE_ID],@"site_id",
								 [shopInfo objectAtIndex:shop_shop_uid],@"uid",
								 [NSNumber numberWithInt:itemUpdateTime],@"updatetime",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:commandid 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//更新商铺的操作
-(void)updateShop
{
	[self.spinner removeFromSuperview];
	
	if (self.shopItems == nil || [self.shopItems count] == 0) 
	{
		UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, ((self.view.frame.size.height - 44.0f) / 2.0), 320, 20)];
		noneLabel.font = [UIFont systemFontOfSize:14];
		noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		noneLabel.text = @"记录不存在...";		
		noneLabel.textAlignment = UITextAlignmentCenter;
		noneLabel.backgroundColor = [UIColor clearColor];
		[self.view addSubview:noneLabel];
	}
	else
	{
		[self createTopView];
		[self showDesc];
	}
}

//更新供应的操作
-(void)updateSupply
{
	//添加表视图
	[self.spinner removeFromSuperview];
    if (currentButtonTag == 1003) 
    {
        [self addTableView];
    }
    
}

//更新求购的操作
-(void)updateDemand;
{
	//添加表视图
	[self.spinner removeFromSuperview];
    if (currentButtonTag == 1004) 
    {
        [self addTableView];
    }
}

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data
{
	if (showType == 1)
	{
		//合并数据
		if (data != nil && [data count] > 0) 
		{
			for (int i = 0; i < [data count];i++ ) 
			{
				NSArray *supplyArray = [data objectAtIndex:i];
				[self.supplyItems addObject:supplyArray];
			}
			
			NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
			for (int ind = 0; ind < [data count]; ind++) 
			{
				NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.supplyItems indexOfObject:[data objectAtIndex:ind]] inSection:0];
				[insertIndexPaths addObject:newPath];
			}
			[self.myTableView insertRowsAtIndexPaths:insertIndexPaths 
									withRowAnimation:UITableViewRowAnimationFade];
            
		    if ([data count] >= 20)
            {
                [self moreBackNormal:YES];
            }
            else
            {
                [self moreBackNormal:NO];
            }
        }
        else
        {
            [self moreBackNormal:NO];
        }
	}
	else
	{
		//合并数据
		if (data != nil && [data count] > 0) 
		{
			for (int i = 0; i < [data count];i++ ) 
			{
				NSArray *demandArray = [data objectAtIndex:i];
				[self.demandItems addObject:demandArray];
			}
			
			NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
			for (int ind = 0; ind < [data count]; ind++) 
			{
				NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.demandItems indexOfObject:[data objectAtIndex:ind]] inSection:0];
				[insertIndexPaths addObject:newPath];
			}
			[self.myTableView insertRowsAtIndexPaths:insertIndexPaths 
									withRowAnimation:UITableViewRowAnimationFade];
		
            if ([data count] >= 20)
            {
                [self moreBackNormal:YES];
            }
            else
            {
                [self moreBackNormal:NO];
            }
        }
        else
        {
            [self moreBackNormal:NO];
        }
	}
	
}

//更多回归常态
-(void)moreBackNormal:(BOOL)isHaveMoreData
{
    if (isHaveMoreData)
    {
        _loadingMore = NO;
        if (self.moreLabel) {
            self.moreLabel.text = @"上拉加载更多";
        }
    }
    else
    {
        if (self.moreLabel) {
            self.moreLabel.text = @"没有更多数据了";
        }
    }
    
	//loading图标移除
    if (self.spinner != nil) {
        [self.spinner stopAnimating];
    }
}

//收藏成功
- (void)favoriteSuccess
{
	isFavorite = YES;
	if (self.progressHUD) {
		[progressHUD hide:YES afterDelay:1.0f];
	}
	[self.favoritebutton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺详情已收藏按钮" ofType:@"png"]] forState:UIControlStateNormal];
}

//收藏失败
- (void)favoriteFail
{	
	if (self.progressHUD) {
		progressHUD.labelText = @"收藏失败";
        progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
        progressHUD.mode = MBProgressHUDModeCustomView;
        [progressHUD hide:YES afterDelay:1.0];
	}
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
	if (ver == NEED_UPDATE) 
	{
		int isSuccess;
		switch(commandid)
		{
				//商铺信息
			case OPERAT_SHOP_INFO:
				self.shopItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateShop) withObject:nil waitUntilDone:NO];
				break;
				//供应刷新
			case OPERAT_SHOP_SUPPLY_REFRESH:
				self.supplyItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
				break;
				
				//供应更多
			case OPERAT_SHOP_SUPPLY_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
				break;
				
				//求购刷新
			case OPERAT_SHOP_DEMAND_REFRESH:
				self.demandItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
				break;
				
				//求购更多
			case OPERAT_SHOP_DEMAND_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
				break;
				
				//收藏
			case OPERAT_SEND_SHOP_FAVORITE:
                if (resultArray != nil && [resultArray count] >0) {
                    isSuccess = [[resultArray objectAtIndex:0] intValue];
                }
                
				if (isSuccess == 1 ) {
					if (self.progressHUD) {
						self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
						self.progressHUD.mode = MBProgressHUDModeCustomView;
						self.progressHUD.labelText = @"收藏成功";
						
						if ([self.userId intValue] != 0) 
						{
							//收藏信息入库
							NSArray *shopInfo = [self.shopItems objectAtIndex:0];
							NSMutableArray *infoArray = [[NSMutableArray alloc]init];
							
							[infoArray addObject:@"0"];
							[infoArray addObject:[shopInfo objectAtIndex:shop_id]];
							[infoArray addObject:self.userId];
							[infoArray addObject:[shopInfo objectAtIndex:shop_shop_uid]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_shop_ulevel]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_catid]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_title]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_desc]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_tel]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_pic]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_pic_name]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_address]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_lng]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_lat]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_attestation]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_update_time]];
                            [infoArray addObject:[shopInfo objectAtIndex:shop_aboutus_title]];
                            [infoArray addObject:[shopInfo objectAtIndex:shop_myproduct_title]];
                            [infoArray addObject:[shopInfo objectAtIndex:shop_app_name]];
                            [infoArray addObject:[shopInfo objectAtIndex:shop_app_image]];
							[infoArray addObject:[shopInfo objectAtIndex:shop_iphone_url]];
                            
							//插入数据库
							[DBOperate insertData:infoArray tableName:T_SHOP_FAVORITE];
							[infoArray release];
							
						}
						
						[self performSelectorOnMainThread:@selector(favoriteSuccess) withObject:nil waitUntilDone:NO];
						
					}
				}else if(isSuccess == 0 ){
					if (self.progressHUD) {
						self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
						//self.progressHUD.mode = MBProgressHUDModeDeterminate;
						self.progressHUD.mode = MBProgressHUDModeCustomView;
						self.progressHUD.labelText = @"收藏失败";
						[self performSelectorOnMainThread:@selector(favoriteFail) withObject:nil waitUntilDone:NO];
					}
				}else if(isSuccess == 2 ){
					if (self.progressHUD) {
						self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
						//self.progressHUD.mode = MBProgressHUDModeDeterminate;
						self.progressHUD.mode = MBProgressHUDModeCustomView;
						self.progressHUD.labelText = @"该信息已收藏";
						[self performSelectorOnMainThread:@selector(favoriteFail) withObject:nil waitUntilDone:NO];
					}
				}
				break;
				
			default:   ;
		}
	}
	else
	{
		switch(commandid)
		{
				//商铺信息
			case OPERAT_SHOP_INFO:
				self.shopItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateShop) withObject:nil waitUntilDone:NO];
				break;
				//供应刷新
			case OPERAT_SHOP_SUPPLY_REFRESH:
				self.supplyItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
				break;
				
				//供应更多
			case OPERAT_SHOP_SUPPLY_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
				//求购刷新
			case OPERAT_SHOP_DEMAND_REFRESH:
				self.demandItems = resultArray;
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
				break;
				
				//求购更多
			case OPERAT_SHOP_DEMAND_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
			default:   ;
		}
	}
	
}

#pragma mark -
#pragma mark progressHUD委托
//在该函数 [progressHUD hide:YES afterDelay:1.0f] 执行后回调

- (void)hudWasHidden:(MBProgressHUD *)hud{
	
	if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
		self.progressHUD = nil;
	}
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (showType == 1) 
	{
        if ([self.supplyItems count] >= 20)
        {
            return [self.supplyItems count] + 1;
        }
        else
        {
            if ([self.supplyItems count] == 0)
            {
                return 1;
            }
            else
            {
                return [self.supplyItems count];
            }
        }
	}
	else
	{
        if ([self.demandItems count] >= 20)
        {
            return [self.demandItems count] + 1;
        }
        else
        {
            if ([self.demandItems count] == 0)
            {
                return 1;
            }
            else
            {
                return [self.demandItems count];
            }
        }
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (showType == 1)
	{
		if (self.supplyItems != nil && [self.supplyItems count] > 0)
		{
			if ([indexPath row] == [self.supplyItems count])
			{
				//点击更多
				return 50.0f;
			}
			else 
			{
				//记录
				return 76.0f;
			}
		}
		else
		{
			//没有记录
			return 50.0f;
		}
	}
	else
	{
		if (self.demandItems != nil && [self.demandItems count] > 0) 
		{
			if ([indexPath row] == [self.demandItems count])
			{
				//点击更多
				return 50.0f;
			}
			else 
			{
				//记录
				return 70.0f;
			}
		}
		else
		{
			//没有记录
			return 50.0f;
		}
	}
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
	
	NSMutableArray *items;
	int countItems;
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
	if (showType ==  1) 
	{
		//供应talbeView
		items = self.supplyItems;
		countItems = [self.supplyItems count];
        
        NSArray *supplyArray; // dufu add 2013.04.28
        int price; // dufu add 2013.04.28
        
        if ([indexPath row] != countItems && countItems > 0) {
            supplyArray = [items objectAtIndex:[indexPath row]]; // dufu add 2013.04.28
            price = [[supplyArray objectAtIndex:supply_price] intValue]; // dufu add 2013.04.28
        }
		
		if (items != nil && countItems > 0)
		{
			if ([indexPath row] == countItems)
			{
				//点击更多
				CellIdentifier = @"moreCell";
			}
			else 
			{
				//记录
				CellIdentifier = @"listCell";
			}
		}
		else
		{
			//没有记录
			CellIdentifier = @"noneCell";
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//cell.backgroundView = 
			//cell.selectedBackgroundView = 
            
			if (items != nil && countItems > 0)
			{
				if([indexPath row] == countItems)
				{		
					UILabel *tempMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 10, 120, 30)];
                    tempMoreLabel.tag = 200;
                    [tempMoreLabel setFont:[UIFont systemFontOfSize:14.0f]];
                    tempMoreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
                    tempMoreLabel.text = _loadingMore ? @"没有更多数据了" : @"上拉加载更多";
                    tempMoreLabel.textAlignment = UITextAlignmentCenter;
                    tempMoreLabel.backgroundColor = [UIColor clearColor];
                    self.moreLabel = tempMoreLabel;
                    [tempMoreLabel release];
                    [cell.contentView addSubview:self.moreLabel];
                    cell.tag = 201;
				}
				else
				{
					
					UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(300, 30, 16, 11)];
					UIImage *rimg;
					rimg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
					rightImage.image = rimg;
					[rimg release];
					[cell.contentView addSubview:rightImage];
					[rightImage release];
					
					UIImageView *supplyBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake( MARGIN , MARGIN , 66.0f , 66.0f)];
					UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"产品列表图背景" ofType:@"png"]];
					supplyBackImageView.image = backImage;
					supplyBackImageView.tag = 100;
					[backImage release];
					[cell.contentView addSubview:supplyBackImageView];
					[supplyBackImageView release];
					
					UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectZero];
					picView.tag = 101;
					[cell.contentView addSubview:picView];
					[picView release];
					
					UILabel *supplyTitle = [[UILabel alloc]initWithFrame:CGRectZero];
					supplyTitle.backgroundColor = [UIColor clearColor];
					supplyTitle.tag = 102;
					supplyTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					supplyTitle.font = [UIFont systemFontOfSize:16];
					supplyTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
					[cell.contentView addSubview:supplyTitle];
					[supplyTitle release];
					
					UILabel *detailtitle = [[UILabel alloc]initWithFrame:CGRectZero];
					detailtitle.backgroundColor = [UIColor clearColor];
					detailtitle.tag = 103;
					detailtitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					detailtitle.font = [UIFont systemFontOfSize:12];
                    detailtitle.numberOfLines = 3;  // dufu add 2013.04.28
					detailtitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
					[cell.contentView addSubview:detailtitle];
					[detailtitle release];
					
                    UIImageView *priceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN * 2 + 66.0f, MARGIN * 9 + 3.0f, 16.0f, 16.0f)];
                    UIImage *priceImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"价格小图标" ofType:@"png"]];
                    priceImageView.image = priceImage;
                    priceImageView.tag = 110;
                    [priceImage release];
                    [cell.contentView addSubview:priceImageView];
                    [priceImageView release];
                    
                    UILabel *priceTitle = [[UILabel alloc]initWithFrame:CGRectZero];
                    priceTitle.backgroundColor = [UIColor clearColor];
                    priceTitle.tag = 104;
                    priceTitle.font = [UIFont systemFontOfSize:12];
                    priceTitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
                    [cell.contentView addSubview:priceTitle];
                    [priceTitle release];
                    
                    UIImageView *favImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN * 2 + 180.0f, MARGIN * 9 + 3.0f, 16.0f, 16.0f)];
                    UIImage *favImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"收藏小图标" ofType:@"png"]];
                    favImageView.image = favImage;
                    favImageView.tag = 111;
                    [favImage release];
                    [cell.contentView addSubview:favImageView];
                    [favImageView release];
                    
                    UILabel *favTitle = [[UILabel alloc]initWithFrame:CGRectZero];
                    favTitle.backgroundColor = [UIColor clearColor];
                    favTitle.tag = 105;
                    favTitle.font = [UIFont systemFontOfSize:12];
                    favTitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
                    [cell.contentView addSubview:favTitle];
                    [favTitle release];
					
                    //推荐图标
                    UIImageView *recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
                    UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
                    recommendImageView.image = recommendImage;
                    [recommendImage release];
                    recommendImageView.tag = 106;
                    recommendImageView.hidden = YES;
                    [cell.contentView addSubview:recommendImageView];
                    [recommendImageView release];
					
					cell.backgroundColor = [UIColor clearColor];
					
				}
			}
			else
			{
				UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
				noneLabel.tag = 201;
				[noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
				noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
				noneLabel.text = @"没找到任何供应信息！";			
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:noneLabel];
				[noneLabel release];
			}
		}
		
		if ([indexPath row] != countItems && countItems > 0)
		{
			UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:100];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
			UILabel *supplyTitle = (UILabel *)[cell.contentView viewWithTag:102];
			UILabel *detailTitle = (UILabel *)[cell.contentView viewWithTag:103];
            UILabel *priceTitle = (UILabel *)[cell.contentView viewWithTag:104];
            UILabel *favTitle = (UILabel *)[cell.contentView viewWithTag:105];
            // dufu mod 2013.06.01
            UIImageView *priceImageView  = (UIImageView *)[cell.contentView viewWithTag:110];
            UIImageView *favImageView  = (UIImageView *)[cell.contentView viewWithTag:111];

            UIImageView *recommendImageView = (UIImageView *)[cell.contentView viewWithTag:106];
			
			//NSArray *supplyArray = [items objectAtIndex:[indexPath row]];  // dufu mod 2013.04.28
            
			NSString *piclink = [supplyArray objectAtIndex:supply_pic];
			if (piclink)
			{
                [supplyTitle setFrame:CGRectMake(MARGIN * 2 + 66.0f, MARGIN, cell.frame.size.width-66.0f-6 * MARGIN, 20)];
                
                if (price > EXPANSION) {  // dufu mod 2013.04.28
                    [detailTitle setFrame:CGRectMake(MARGIN * 2 + 66.0f, MARGIN * 5, cell.frame.size.width-66.0f-6 * MARGIN, 20)];
                    
                    [priceTitle setFrame:CGRectMake(MARGIN * 2 + 66.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    
                    [favTitle setFrame:CGRectMake(MARGIN * 2 + 180.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    priceImageView.hidden = NO;
                    favImageView.hidden = NO;
                } else {
                    CGSize labelSize = [@"你" sizeWithFont:[UIFont boldSystemFontOfSize:12.0f]];
                    [detailTitle setFrame:CGRectMake(MARGIN * 2 + 66.0f, MARGIN * 5, cell.frame.size.width-66.0f-6 * MARGIN, labelSize.height*3)];
                    [priceTitle setFrame:CGRectZero];
                    [favTitle setFrame:CGRectZero];
                    priceImageView.hidden = YES;
                    favImageView.hidden = YES;
                }
				
				[picView setFrame:CGRectMake(MARGIN + 2, MARGIN + 2, photoWith, photoHigh)];
				
				//获取本地图片缓存
				UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
				
				if (cardIcon == nil)
				{
					UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认图产品列表图" ofType:@"png"]];
					picView.image = [img fillSize:CGSizeMake(photoWith, photoHigh)];
					[img release];
					if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
					{
						NSString *photoURL = [self getPhotoURL:indexPath];
						[self startIconDownload:photoURL forIndexPath:indexPath];
					}
				}
				else
				{
					picView.image = cardIcon;
				}
			}
			else 
			{
				[backImage removeFromSuperview];
				[supplyTitle setFrame:CGRectMake(MARGIN * 2, MARGIN, cell.frame.size.width-6 * MARGIN, 20)];

                if (price > EXPANSION) {  // dufu mod 2013.04.28
                    [detailTitle setFrame:CGRectMake(MARGIN * 2, MARGIN * 5, cell.frame.size.width-6 * MARGIN, 20)];
                    
                    [priceTitle setFrame:CGRectMake(MARGIN * 2 + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    
                    [favTitle setFrame:CGRectMake(MARGIN * 2 + 120.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    priceImageView.hidden = NO;
                    favImageView.hidden = NO;
                } else {
                    CGSize labelSize = [@"你" sizeWithFont:[UIFont boldSystemFontOfSize:12.0f]];
                    [detailTitle setFrame:CGRectMake(MARGIN * 2 + 66.0f, MARGIN * 5, cell.frame.size.width-66.0f-6 * MARGIN, labelSize.height*3)];
                    [priceTitle setFrame:CGRectZero];
                    [favTitle setFrame:CGRectZero];
                    priceImageView.hidden = YES;
                    favImageView.hidden = YES;
                }
			}
            
            //推荐图标
            if ([[supplyArray objectAtIndex:supply_recommend] intValue] == 1) 
            {
                recommendImageView.hidden = NO;
            }
            else 
            {
                recommendImageView.hidden = YES;
            }
			
			supplyTitle.text = [supplyArray objectAtIndex:supply_title];
			detailTitle.text = [supplyArray objectAtIndex:supply_desc];
            
            if (price > EXPANSION) {  // dufu mod 2013.04.28
                priceTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_price]];
                favTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_favorite]];
            }
		}
	}
	else 
	{
		//供应talbeView
		items = self.demandItems;
		countItems = [self.demandItems count];
		
		if (items != nil && countItems > 0)
		{
			if ([indexPath row] == countItems)
			{
				//点击更多
				CellIdentifier = @"moreCell";
			}
			else 
			{
				//记录
				CellIdentifier = @"listCell";
			}
		}
		else
		{
			//没有记录
			CellIdentifier = @"noneCell";
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			if (items != nil && countItems > 0)
			{
				if([indexPath row] == countItems)
				{		
					UILabel *tempMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 10, 120, 30)];
                    tempMoreLabel.tag = 200;
                    [tempMoreLabel setFont:[UIFont systemFontOfSize:14.0f]];
                    tempMoreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
                    tempMoreLabel.text = _loadingMore ? @"没有更多数据了" : @"上拉加载更多";
                    tempMoreLabel.textAlignment = UITextAlignmentCenter;
                    tempMoreLabel.backgroundColor = [UIColor clearColor];
                    self.moreLabel = tempMoreLabel;
                    [tempMoreLabel release];
                    [cell.contentView addSubview:self.moreLabel];
                    cell.tag = 201;
				}
				else
				{
					
					UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(300, 30, 16, 11)];
					UIImage *rimg;
					rimg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
					rightImage.image = rimg;
					[rimg release];
					[cell.contentView addSubview:rightImage];
					[rightImage release];
					
					UILabel *demandTitle = [[UILabel alloc]initWithFrame:CGRectZero];
					demandTitle.backgroundColor = [UIColor clearColor];
					demandTitle.tag = 100;
					demandTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					demandTitle.font = [UIFont systemFontOfSize:16];
					demandTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
					[cell.contentView addSubview:demandTitle];
					[demandTitle release];
					
					UILabel *detailtitle = [[UILabel alloc]initWithFrame:CGRectZero];
					detailtitle.backgroundColor = [UIColor clearColor];
					detailtitle.tag = 101;
					detailtitle.numberOfLines = 0; 
					detailtitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					detailtitle.font = [UIFont systemFontOfSize:12];
					detailtitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
					[cell.contentView addSubview:detailtitle];
					[detailtitle release];
                    
                    //推荐图标
                    UIImageView *recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
                    UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
                    recommendImageView.image = recommendImage;
                    [recommendImage release];
                    recommendImageView.tag = 102;
                    recommendImageView.hidden = YES;
                    [cell.contentView addSubview:recommendImageView];
                    [recommendImageView release];
					
					cell.backgroundColor = [UIColor clearColor];
					
				}
			}
			else
			{
				UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
				noneLabel.tag = 201;
				[noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
				noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
				noneLabel.text = @"没找到任何求购信息！";			
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:noneLabel];
				[noneLabel release];
			}
			
		}
		
		if ([indexPath row] != countItems && countItems > 0){
			
			UILabel *demandTitle = (UILabel *)[cell.contentView viewWithTag:100];
			UILabel *detailTitle = (UILabel *)[cell.contentView viewWithTag:101];
            UIImageView *recommendImageView = (UIImageView *)[cell.contentView viewWithTag:102];
			
			NSArray *demandArray = [items objectAtIndex:[indexPath row]];
			
			[demandTitle setFrame:CGRectMake(MARGIN * 2 , MARGIN, cell.frame.size.width-6 * MARGIN, 20)];
			
			[detailTitle setFrame:CGRectMake(MARGIN * 2 , MARGIN * 5, cell.frame.size.width-6 * MARGIN, 40)];
			
			demandTitle.text = [demandArray objectAtIndex:demand_title];
			detailTitle.text = [demandArray objectAtIndex:demand_desc];
            
            //推荐图标
            if ([[demandArray objectAtIndex:demand_recommend] intValue] == 1) 
            {
                recommendImageView.hidden = NO;
            }
            else 
            {
                recommendImageView.hidden = YES;
            }
			
		}
		
	}
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (showType == 1)
	{
		
		if (self.supplyItems != nil && [self.supplyItems count] > 0)
		{
			if ([indexPath row] == [self.supplyItems count])
			{
				//点击更多
				UITableViewCell *cell=[myTableView cellForRowAtIndexPath:indexPath];
				self.moreLabel.text=@" 加载中 ...";
				
				//添加loading图标
				UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
				[tempSpinner setCenter:CGPointMake(cell.frame.size.width / 3, cell.frame.size.height / 2.0)];
				self.spinner = tempSpinner;
				[cell.contentView addSubview:self.spinner];
				[self.spinner startAnimating];
				[tempSpinner release];
				
				//网络获取
				NSArray *supplyArray = [self.supplyItems objectAtIndex:[self.supplyItems count]-1];
				int updateTime = [[supplyArray objectAtIndex:supply_update_time] intValue];
				[self accessItemService:OPERAT_SHOP_SUPPLY_MORE itemsUpdateTime:updateTime];
				
				[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
			}
			else 
			{
				NSArray *supplyArray = [self.supplyItems objectAtIndex:[indexPath row]];
				NSString *supplyID = [supplyArray objectAtIndex:supply_id];
				supplyDetailViewController *supplyDetail = [[supplyDetailViewController alloc] init];
				
				supplyDetail.supplyID = supplyID;
                
                supplyDetail.commentTotal = [NSString stringWithFormat:@"%d",[[supplyArray objectAtIndex:supply_commentTotal] intValue]];
                supplyDetail.isFrom = YES;
                
				NSMutableArray *supplyInfoArray = [[NSMutableArray alloc] init];
				[supplyInfoArray addObject:supplyArray];
				supplyDetail.supplyArray = supplyInfoArray;
				[supplyInfoArray release];
				
				if ([[supplyArray objectAtIndex:supply_pics] isKindOfClass:[NSMutableArray class]])
				{
					supplyDetail.supplyPicArray = [supplyArray objectAtIndex:supply_pics];
				}
				
				[self.navigationController pushViewController:supplyDetail animated:YES];
				[supplyDetail release];
			}
		}
		
	}
	else
	{
		
		if (self.demandItems != nil && [self.demandItems count] > 0) 
		{
			if ([indexPath row] == [self.demandItems count])
			{
				//点击更多
				UITableViewCell *cell=[myTableView cellForRowAtIndexPath:indexPath];
				self.moreLabel.text=@" 加载中 ...";
				
				//添加loading图标
				UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
				[tempSpinner setCenter:CGPointMake(cell.frame.size.width / 3, cell.frame.size.height / 2.0)];
				self.spinner = tempSpinner;
				[cell.contentView addSubview:self.spinner];
				[self.spinner startAnimating];
				[tempSpinner release];
				
				//网络获取
				NSArray *demandArray = [self.demandItems objectAtIndex:[self.demandItems count]-1];
				int updateTime = [[demandArray objectAtIndex:demand_update_time] intValue];
				[self accessItemService:OPERAT_SHOP_DEMAND_MORE itemsUpdateTime:updateTime];
				
				[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
			}
			else 
			{
				//记录
				NSArray *demandArray = [self.demandItems objectAtIndex:[indexPath row]];
				NSString *demandID = [demandArray objectAtIndex:demand_id];
				demandDetailViewController *demandDetail = [[demandDetailViewController alloc] init];			
				demandDetail.demandID = demandID;
                demandDetail.commentTotal = [NSString stringWithFormat:@"%d",[[demandArray objectAtIndex:demand_commentTotal] intValue]];
                demandDetail.isFrom = YES;
                
				NSMutableArray *demandInfoArray = [[NSMutableArray alloc] init];
				[demandInfoArray addObject:demandArray];
				demandDetail.demandArray = demandInfoArray;
				[demandInfoArray release];
				
				if ([[demandArray objectAtIndex:demand_pics] isKindOfClass:[NSMutableArray class]])
				{
					demandDetail.demandPicArray = [demandArray objectAtIndex:demand_pics];
				}
				
				[self.navigationController pushViewController:demandDetail animated:YES];
				[demandDetail release];
			}
		}
		
	}
	
}

//ios7去掉cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
    int currentOffsetY = scrollView.contentOffset.y;
    
    if (scrollView.dragging == YES && scrollView.decelerating == NO)
    {
        if (isAnimation)
        {
            if (currentOffsetY - lastContentOffsetY > 10) 
            {  
                isAnimation = NO;
                lastContentOffsetY = scrollView.contentOffset.y;
                [self topViewAnimation:@"up"];
                
            }  
            else if (lastContentOffsetY - currentOffsetY > 10)  
            {  
                isAnimation = NO;
                lastContentOffsetY = scrollView.contentOffset.y;
                [self topViewAnimation:@"down"];
            }
        }
    }
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            self.moreLabel.text=@"松开加载更多";
            
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    lastContentOffsetY = scrollView.contentOffset.y;
    isAnimation = YES;
    
    if (showType == 1)
	{
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.supplyItems count] >= 20)
        {
            _isAllowLoadingMore = YES;
        }
        else
        {
            _isAllowLoadingMore = NO;
        }
    }
    else
    {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.demandItems count] >= 20)
        {
            _isAllowLoadingMore = YES;
        }
        else
        {
            _isAllowLoadingMore = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (!decelerate && showType == 1)
	{
		[self loadImagesForOnscreenRows];
    }
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            self.moreLabel.text=@" 加载中 ...";
            
            UITableViewCell *cell = (UITableViewCell *)[self.myTableView viewWithTag:201];
            
            //添加loading图标
            UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            [tempSpinner setCenter:CGPointMake(cell.frame.size.width / 3, cell.frame.size.height / 2.0)];
            self.spinner = tempSpinner;
            [cell.contentView addSubview:self.spinner];
            [self.spinner startAnimating];
            [tempSpinner release];
            
            //网络获取
            if (showType == 1)
            {
                NSArray *supplyArray = [self.supplyItems objectAtIndex:[self.supplyItems count]-1];
				int updateTime = [[supplyArray objectAtIndex:supply_update_time] intValue];
				[self accessItemService:OPERAT_SHOP_SUPPLY_MORE itemsUpdateTime:updateTime];
			}
            else
            {
                NSArray *demandArray = [self.demandItems objectAtIndex:[self.demandItems count]-1];
				int updateTime = [[demandArray objectAtIndex:demand_update_time] intValue];
				[self accessItemService:OPERAT_SHOP_DEMAND_MORE itemsUpdateTime:updateTime];
            }
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (showType == 1)
	{
		[self loadImagesForOnscreenRows];
    }
    
    lastContentOffsetY = scrollView.contentOffset.y;
}

#pragma mark -
#pragma mark 登录接口回调
- (void)loginWithResult:(BOOL)isLoginSuccess{
    
	if (isLoginSuccess) 
    {
        if (isContactFavorite == NO) {
            //获取当前用户的user_id
            NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
            if ([memberArray count] > 0) 
            {
                self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
            }
            else 
            {
                self.userId = @"0";
            }
            
            //收藏操作
            [self favorite];
        }
	}
    //    else
    //    {
    //		[alertView showAlert:@"登录失败，请重试！"];
    //	}
    
}

#pragma mark ---- 弹出名片回调
- (void)feedback
{
    isContactFavorite = YES;
    if (_isLogin == YES) {
        MessageDetailViewController *msgDetail = [[MessageDetailViewController alloc] init];
        msgDetail.sourceStr = self.senderId;
        msgDetail.sourceName = self.sourceName;
        msgDetail.sourceImage = self.sourceImage;
        [self.navigationController pushViewController:msgDetail animated:YES];
        [msgDetail release];
    }else {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        [self.navigationController pushViewController:login animated:YES];
        [login release];
    }
}

- (void)favoriteLogin
{
    LoginViewController *login = [[LoginViewController alloc] init];
    login.delegate = self;
    [self.navigationController pushViewController:login animated:YES];
    [login release];
}

- (void)goUrl:(NSString *)url
{
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = url;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.shopID = nil;
	self.spinner = nil;
	self.shopItems = nil;
	self.supplyItems = nil;
	self.demandItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
	self.userId = nil;
    self.favoritebutton = nil;
    self.dragCard = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    self.moreLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}


- (void)dealloc {
	self.shopID = nil;
	self.spinner = nil;
	self.shopItems = nil;
	self.supplyItems = nil;
	self.demandItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
	self.userId = nil;
    self.favoritebutton = nil;
    self.dragCard = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    self.moreLabel = nil;
    [ShareSheet release]; // dufu add 2013.04.25
    [super dealloc];
}


@end
