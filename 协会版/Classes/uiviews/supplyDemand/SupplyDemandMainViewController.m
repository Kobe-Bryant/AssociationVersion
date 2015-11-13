//
//  SupplyDemandMainViewController.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SupplyDemandMainViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "LightMenuBar.h"
#import "UIImageScale.h"
#import "imageDownLoadInWaitingObject.h"
#import "supplyDetailViewController.h"
#import "demandDetailViewController.h"
#import "SearchViewController.h"

#define MARGIN 5.0f

#define EXPANSION   0

@implementation SupplyDemandMainViewController

@synthesize myTableView;
@synthesize myMenuBar;
@synthesize supplyItems;
@synthesize demandItems;
@synthesize supplyCatItems;
@synthesize demandCatItems;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize progressHUD;
@synthesize spinner;
@synthesize moreLabel;

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
	
	photoWith = 76;
	photoHigh = 56;
	
	isFirstLoadingSupplyCat = YES;
	isFirstLoadingDemandCat = YES;
	
	cat_id = 0;

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
	
	//供应分类数据初始化
	NSMutableArray *tempSupplyCatArray = [[NSMutableArray alloc] init];
	self.supplyCatItems = tempSupplyCatArray;
	[tempSupplyCatArray release];
	
	//求购分类数据初始化
	NSMutableArray *tempDemandCatArray = [[NSMutableArray alloc] init];
	self.demandCatItems = tempDemandCatArray;
	[tempDemandCatArray release];
	
}

//显示供应列表
-(void)showSupply
{
	//移出所有view
	[self removeAllView];
	
	//设置类型
	showType = 1;
	
	//设置回常态
	[self backNormal];
    
    _loadingMore = NO;
	
	if (self.supplyCatItems == nil || [self.supplyCatItems count] == 0) 
	{
		//从数据库中取出数据 
		self.supplyCatItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_CAT theColumn:@"" theColumnValue:@"" withAll:YES];

		if (isFirstLoadingSupplyCat) 
		{
			//添加loading信息
			MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
			self.progressHUD = progressHUDTmp;
			[progressHUDTmp release];
			self.progressHUD.delegate = self;
			self.progressHUD.labelText = LOADING_TIPS;
			[self.view addSubview:self.progressHUD];
			[self.view bringSubviewToFront:self.progressHUD];
			[self.progressHUD show:YES];
			
			//从网络中获取检查有没有更新的数据
			isFirstLoadingSupplyCat = NO;
			[self accessCatService:OPERAT_SUPPLY_CAT_REFRESH];
			
		}
		else 
		{
			if ([self.supplyCatItems count] == 0) 
			{
				UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
				noneLabel.font = [UIFont systemFontOfSize:14];
				noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
				noneLabel.text = @"没找到任何供应分类！";			
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[self.view addSubview:noneLabel];
				[noneLabel release];
			}
			else 
			{
				//新增第一个全部分类
				NSMutableArray *allCat = [[NSMutableArray alloc]init];
				[allCat addObject:[NSString stringWithFormat:@"%d",0]];
				[allCat addObject:[NSString stringWithFormat:@"全部"]];
				[allCat addObject:[NSString stringWithFormat:@"%d",0]];
				[self.supplyCatItems insertObject:allCat atIndex:0];
				[allCat release];
				
				//添加分类导航
				[self addCatNat];
			}
		}

	}
	else 
	{		
		//添加分类导航
		[self addCatNat];
	}
	
}

//显示求购列表
-(void)showDemand
{
	//移出所有view
	[self removeAllView];
	
	//设置类型
	showType = 2;
    
    _loadingMore = NO;
	
	if (self.demandCatItems == nil || [self.demandCatItems count] == 0) 
	{
		//从数据库中取出数据 
		self.demandCatItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_CAT theColumn:@"" theColumnValue:@"" withAll:YES];
		
		if (isFirstLoadingDemandCat) 
		{
			//添加loading信息
			MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
			self.progressHUD = progressHUDTmp;
			[progressHUDTmp release];
			self.progressHUD.delegate = self;
			self.progressHUD.labelText = LOADING_TIPS;
			[self.view addSubview:self.progressHUD];
			[self.view bringSubviewToFront:self.progressHUD];
			[self.progressHUD show:YES];
			
			//从网络中获取检查有没有更新的数据
			isFirstLoadingDemandCat = NO;
			[self accessCatService:OPERAT_DEMAND_CAT_REFRESH];
			
		}
		else 
		{
			if ([self.demandCatItems count] == 0) 
			{
				UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
				noneLabel.font = [UIFont systemFontOfSize:14];
				noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
				noneLabel.text = @"没找到任何求购分类！";			
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[self.view addSubview:noneLabel];
				[noneLabel release];
			}
			else 
			{
				//新增第一个全部分类
				NSMutableArray *allCat = [[NSMutableArray alloc]init];
				[allCat addObject:[NSString stringWithFormat:@"%d",0]];
				[allCat addObject:[NSString stringWithFormat:@"全部"]];
				[allCat addObject:[NSString stringWithFormat:@"%d",0]];
				[self.demandCatItems insertObject:allCat atIndex:0];
				[allCat release];
				
				//添加分类导航
				[self addCatNat];
			}
		}
		
	}
	else 
	{		
		//添加分类导航
		[self addCatNat];
	}
	
}

//移出所有view
-(void)removeAllView
{
	NSArray *viewsToRemove = [self.view subviews]; 
	for (UIView *v in viewsToRemove) 
	{
		[v removeFromSuperview];
	}
}

//添加滚动分类导航
-(void)addCatNat
{
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

//添加数据表视图
-(void)addTableView;
{
	[self.myTableView removeFromSuperview];
	
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 40.0f , 320.0f , 327.0f)];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
	[self.view sendSubviewToBack:self.myTableView];
	[self.progressHUD sendSubviewToBack:self.myTableView];
	[self.myTableView reloadData];
	
	//下拉更新
	_refreshHeaderView = nil;
	_reloading = NO;
	EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.myTableView.bounds.size.height, self.view.frame.size.width, self.myTableView.bounds.size.height)];
	view.delegate = self;
	[self.myTableView addSubview:view];
	_refreshHeaderView = view;
	[view release];
	[_refreshHeaderView refreshLastUpdatedDate];
}

//搜索
-(void)searchSupply
{
//	//这里做搜索页面跳转
//	SearchViewController *searchView = [[SearchViewController alloc] init];
//	searchView.selectIndex = search_product;
//	UINavigationController *navController = [[UINavigationController alloc]
//											 initWithRootViewController:searchView];
//	[navController setModalPresentationStyle:UIModalPresentationCurrentContext]; 
//	[self.navigationController presentModalViewController:navController animated:YES]; 
//	[searchView release];
//	[navController release];
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

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
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

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d,%@",cat_id,indexPath]];
    if (iconDownloader == nil && photoURL != nil && photoURL.length > 1) 
    {
		if ([imageDownloadsInProgress count]>= 5) {
			imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:photoURL withIndexPath:indexPath withImageType:cat_id];
			[imageDownloadsInWaiting addObject:one];
			[one release];
			return;
		}
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = photoURL;
        iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.imageType = cat_id;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:[NSString stringWithFormat:@"%d,%@",cat_id,indexPath]];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    if (showType ==  1) 
	{
        IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d,%@",Type,indexPath]];
        if (iconDownloader != nil)
        {
            // Display the newly loaded image
            if(iconDownloader.cardIcon.size.width>2.0)
            {
                NSString *picName = [Common encodeBase64:(NSMutableData *)[iconDownloader.downloadURL dataUsingEncoding: NSUTF8StringEncoding]];
                
                //保存图片
                [FileManager savePhoto:picName withImage:iconDownloader.cardIcon];
                
                if (Type == cat_id)
                {
                    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                    UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
                    UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
                    picView.image = photo;
                }
            }
            
            [imageDownloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d,%@",Type,indexPath]];
            if ([imageDownloadsInWaiting count]>0) 
            {
                imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
                [self startIconDownload:one.imageURL forIndexPath:one.indexPath];
                [imageDownloadsInWaiting removeObjectAtIndex:0];
            }
            
        }
    }
}

//网络获取分类数据
-(void)accessCatService:(int)commandid
{
	NSString *reqUrl = commandid == OPERAT_SUPPLY_CAT_REFRESH ? @"pcats.do?param=%@" : @"tcats.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getVersion:commandid],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic 
									   command:commandid 
								  accessAdress:reqUrl 
									  delegate:self 
									 withParam:nil];
}

//网络获取数据
-(void)accessItemService:(int)commandid accessVer:(int)ver
{
	NSString *reqUrl = commandid == OPERAT_SUPPLY_REFRESH ? @"products.do?param=%@" : @"trades.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: ver],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: cat_id],@"cats_id",
								 [NSNumber numberWithInt: 0],@"updatetime",
								 nil];
	
	NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt: cat_id],@"cat_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:commandid 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:param];
}

//网络获取更多数据
-(void)accessMoreService:(int)commandid itemsUpdateTime:(int)itemUpdateTime
{
	NSString *reqUrl = commandid == OPERAT_SUPPLY_MORE ? @"products.do?param=%@" : @"trades.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: -1],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: cat_id],@"cats_id",
								 [NSNumber numberWithInt: itemUpdateTime],@"updatetime",
								 nil];
	
	NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt: cat_id],@"cat_id",
								  nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:commandid 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:param];
}

//更新供应分类的操作
-(void)updateSupplyCat
{
    //设置回常态
	[self backNormal];
    
	//重新更新数据
	self.supplyCatItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_CAT theColumn:@"" theColumnValue:@"" withAll:YES];
	
	if ([self.supplyCatItems count] == 0) 
	{
		UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
		noneLabel.font = [UIFont systemFontOfSize:14];
		noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		noneLabel.text = @"没找到任何供应分类！";			
		noneLabel.textAlignment = UITextAlignmentCenter;
		noneLabel.backgroundColor = [UIColor clearColor];
		[self.view addSubview:noneLabel];
		[noneLabel release];
	}
	else 
	{
		//新增第一个全部分类
		NSMutableArray *allCat = [[NSMutableArray alloc]init];
		[allCat addObject:[NSString stringWithFormat:@"%d",0]];
		[allCat addObject:[NSString stringWithFormat:@"全部"]];
		[allCat addObject:[NSString stringWithFormat:@"%d",0]];
		[self.supplyCatItems insertObject:allCat atIndex:0];
		[allCat release];
		
		//添加分类导航
		[self addCatNat];
	}
}

//更新求购分类的操作
-(void)updateDemandCat
{
    //设置回常态
	[self backNormal];
    
	//重新更新数据
	self.demandCatItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_CAT theColumn:@"" theColumnValue:@"" withAll:YES];
	
	if ([self.demandCatItems count] == 0) 
	{
		UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
		noneLabel.font = [UIFont systemFontOfSize:14];
		noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		noneLabel.text = @"没找到任何求购分类！";			
		noneLabel.textAlignment = UITextAlignmentCenter;
		noneLabel.backgroundColor = [UIColor clearColor];
		[self.view addSubview:noneLabel];
		[noneLabel release];
	}
	else 
	{
		//新增第一个全部分类
		NSMutableArray *allCat = [[NSMutableArray alloc]init];
		[allCat addObject:[NSString stringWithFormat:@"%d",0]];
		[allCat addObject:[NSString stringWithFormat:@"全部"]];
		[allCat addObject:[NSString stringWithFormat:@"%d",0]];
		[self.demandCatItems insertObject:allCat atIndex:0];
		[allCat release];
		
		//添加分类导航
		[self addCatNat];
	}
    
}

//更新供应的操作
-(void)updateSupply
{
	NSString *_cat_id = [NSString stringWithFormat:@"%d",cat_id];
	
	//重新更新数据
	self.supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
	
	//新增一个搜索行的数据
	NSMutableArray *searchSupplyData = [[NSMutableArray alloc]init];
	[searchSupplyData addObject:[NSString stringWithFormat:@"0"]];
	[searchSupplyData addObject:[NSString stringWithFormat:@""]];
	[searchSupplyData addObject:[NSString stringWithFormat:@""]];
	[searchSupplyData addObject:[NSString stringWithFormat:@""]];
	[searchSupplyData addObject:@""];
	[searchSupplyData addObject:[NSString stringWithFormat:@""]];
	[searchSupplyData addObject:@""];
	[searchSupplyData addObject:@""];
	[searchSupplyData addObject:@""];
	[searchSupplyData addObject:@""];
	[self.supplyItems insertObject:searchSupplyData atIndex:0];
	[searchSupplyData release];
	
	//添加表视图
	if ([self.myTableView isDescendantOfView:self.view]) 
	{
		[self.myTableView reloadData];
	}
	else
	{
		[self addTableView];
	}

	//设置回常态
	[self backNormal];

}

//更新求购的操作
-(void)updateDemand;
{
	NSString *_cat_id = [NSString stringWithFormat:@"%d",cat_id];
	
	//从数据库中取出数据 
	self.demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
	
	//添加表视图
	if ([self.myTableView isDescendantOfView:self.view]) 
	{
		[self.myTableView reloadData];
	}
	else
	{
		[self addTableView];
	}
	
	//设置回常态
	[self backNormal];
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

//移出提示层
-(void)removeprogressHUD
{
	if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
		self.progressHUD = nil;
	}
}

//回归常态
-(void)backNormal
{
	//移除loading图标
	[self removeprogressHUD];
	
    _loadingMore = NO;
    if (self.moreLabel) {
        self.moreLabel.text = @"上拉加载更多";
    }
    
	//下拉缩回
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
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

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
	if (ver == NEED_UPDATE) 
	{
		switch(commandid)
		{
			//供应刷新
			case OPERAT_SUPPLY_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
			break;
				
			//供应分类刷新
			case OPERAT_SUPPLY_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupplyCat) withObject:nil waitUntilDone:NO];
			break;
				
			//供应更多
			case OPERAT_SUPPLY_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
			break;
				
			//求购刷新
			case OPERAT_DEMAND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
			break;
			
			//求购分类刷新
			case OPERAT_DEMAND_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemandCat) withObject:nil waitUntilDone:NO];
			break;
			//求购更多
			case OPERAT_DEMAND_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
				break;

			default:   ;
		}
	}
	else
	{
		switch(commandid)
		{
				//供应刷新
			case OPERAT_SUPPLY_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
				break;
				
				//供应分类刷新
			case OPERAT_SUPPLY_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupplyCat) withObject:nil waitUntilDone:NO];
				break;
				
				//供应更多
			case OPERAT_SUPPLY_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
				//求购刷新
			case OPERAT_DEMAND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
				break;
				
				//求购分类刷新
			case OPERAT_DEMAND_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemandCat) withObject:nil waitUntilDone:NO];
				break;
				//求购更多
			case OPERAT_DEMAND_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
			default:   ;
		}
	}

}



#pragma mark 滚动导航委托 LightMenuBarDelegate
- (NSUInteger)itemCountInMenuBar:(LightMenuBar *)menuBar {
	
	if (showType == 1) 
	{
		return [self.supplyCatItems count];
	}
	else
	{
		return [self.demandCatItems count];
	}
    
}

- (NSString *)itemTitleAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	if (showType == 1) 
	{
		NSArray *supplyCatArray = [self.supplyCatItems objectAtIndex:index];
		return [supplyCatArray objectAtIndex:supply_cat_name];
	}
	else
	{
		NSArray *demandCatArray = [self.demandCatItems objectAtIndex:index];
		return [demandCatArray objectAtIndex:demand_cat_name];
	}
	
}

- (void)itemSelectedAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	//设置回常态
	[self backNormal];
    
    _loadingMore = NO;
	
    if (showType == 1) 
	{
		NSArray *supplyCatArray = [self.supplyCatItems objectAtIndex:index];
		NSString *_cat_id = [supplyCatArray objectAtIndex:supply_cat_id];
		cat_id = [_cat_id intValue];
		
		int catVer;
		
		if (cat_id == 0)
		{
			catVer = [[Common getVersion:OPERAT_SUPPLY_REFRESH] intValue];
		}
		else
		{
			NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
			if ([catItems count] > 0)
			{
				NSMutableArray *catArray = [catItems objectAtIndex:0];
				catVer = [[catArray objectAtIndex:supply_cat_version] intValue];
			}
			else 
			{
				catVer = 0;
			}
			
		}

		//从数据库中取出数据 
		self.supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
		
		if ([self.supplyItems count] == 0) 
		{
			//添加loading信息
			MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
			self.progressHUD = progressHUDTmp;
			[progressHUDTmp release];
			self.progressHUD.delegate = self;
			self.progressHUD.labelText = LOADING_TIPS;
			[self.view addSubview:self.progressHUD];
			[self.view bringSubviewToFront:self.progressHUD];
			[self.progressHUD show:YES];
			
			//本地没有数据 则从网络请求
			[self accessItemService:OPERAT_SUPPLY_REFRESH accessVer:catVer];
		}
		else 
		{
			//新增一个搜索行的数据
			NSMutableArray *searchSupplyData = [[NSMutableArray alloc]init];
			[searchSupplyData addObject:[NSString stringWithFormat:@"0"]];
			[searchSupplyData addObject:[NSString stringWithFormat:@""]];
			[searchSupplyData addObject:[NSString stringWithFormat:@""]];
			[searchSupplyData addObject:[NSString stringWithFormat:@""]];
			[searchSupplyData addObject:@""];
			[searchSupplyData addObject:[NSString stringWithFormat:@""]];
			[searchSupplyData addObject:@""];
			[searchSupplyData addObject:@""];
			[searchSupplyData addObject:@""];
			[searchSupplyData addObject:@""];
			[self.supplyItems insertObject:searchSupplyData atIndex:0];
			[searchSupplyData release];
			
			//添加表视图
			if ([self.myTableView isDescendantOfView:self.view]) 
			{
				[self.myTableView reloadData];
			}
			else
			{
				[self addTableView];
			}

		}
		
	}
	else
	{
		NSArray *demandCatArray = [self.demandCatItems objectAtIndex:index];
		NSString *_cat_id = [demandCatArray objectAtIndex:demand_cat_id];
		cat_id = [_cat_id intValue];
		
		int catVer;
		
		if (cat_id == 0)
		{
			catVer = [[Common getVersion:OPERAT_DEMAND_REFRESH] intValue];
		}
		else
		{
			NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
			if ([catItems count] > 0)
			{
				NSMutableArray *catArray = [catItems objectAtIndex:0];
				catVer = [[catArray objectAtIndex:demand_cat_version] intValue];
			}
			else 
			{
				catVer = 0;
			}
			
		}
		
		//从数据库中取出数据 
		self.demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
		
		if ([self.demandItems count] == 0) 
		{
			//添加loading信息
			MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
			self.progressHUD = progressHUDTmp;
			[progressHUDTmp release];
			self.progressHUD.delegate = self;
			self.progressHUD.labelText = LOADING_TIPS;
			[self.view addSubview:self.progressHUD];
			[self.view bringSubviewToFront:self.progressHUD];
			[self.progressHUD show:YES];
			
			//本地没有数据 则从网络请求
			[self accessItemService:OPERAT_DEMAND_REFRESH accessVer:catVer];
		}
		else 
		{
			//添加表视图
			if ([self.myTableView isDescendantOfView:self.view]) 
			{
				[self.myTableView reloadData];
			}
			else
			{
				[self addTableView];
			}
			
		}
	}
}

//< Optional
- (CGFloat)itemWidthAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	if (showType == 1) 
	{
		if ([self.supplyCatItems count] > 4) 
		{
			return self.myMenuBar.frame.size.width / 4;
		}
		else 
		{
			return self.myMenuBar.frame.size.width / [self.supplyCatItems count];
		}

	}
	else
	{
		if ([self.demandCatItems count] > 4) 
		{
			return self.myMenuBar.frame.size.width / 4;
		}
		else 
		{
			return self.myMenuBar.frame.size.width / [self.demandCatItems count];
		}
	}
	
}

/****************************************************************************/
//< For Background Area
/****************************************************************************/

/**< Top and Bottom Padding, by Default 5.0f */
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

- (UIColor *)colorOfBackgroundInMenuBar:(LightMenuBar *)menuBar {
    //return [UIColor colorWithRed:1 green:0.588 blue:0.0 alpha:0.0f];
    return [UIColor clearColor];
}

/****************************************************************************/
//< For Button 
/****************************************************************************/

/**< Corner Radius of the Button highlight Area, by Default 5.0f */
- (CGFloat)cornerRadiusOfButtonInMenuBar:(LightMenuBar *)menuBar {
    return 1.0f;
}

- (UIColor *)colorOfButtonHighlightInMenuBar:(LightMenuBar *)menuBar {
    //return [UIColor whiteColor];
	//return [UIColor colorWithRed:0.9 green:0.4 blue:0.0 alpha:1.0f];
    
    NSString *checkedImgName;
    if (showType == 1) 
	{
		if ([self.supplyCatItems count] > 4) 
		{
			checkedImgName = @"导航栏4选中";
		}
		else 
		{
			checkedImgName = [NSString stringWithFormat:@"导航栏%d选中",[self.supplyCatItems count]];
		}
        
	}
	else
	{
		if ([self.demandCatItems count] > 4) 
		{
			checkedImgName = @"导航栏4选中";
		}
		else 
		{
			checkedImgName = [NSString stringWithFormat:@"导航栏%d选中",[self.supplyCatItems count]];
		}
	}
    
    UIImage *currentCheckedBackground = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:checkedImgName ofType:@"png"]];
    return [UIColor colorWithPatternImage:currentCheckedBackground];
}

- (UIColor *)colorOfTitleNormalInMenuBar:(LightMenuBar *)menuBar {
    return [UIColor whiteColor];
}

- (UIColor *)colorOfTitleHighlightInMenuBar:(LightMenuBar *)menuBar {
    return [UIColor whiteColor];
}

- (UIFont *)fontOfTitleInMenuBar:(LightMenuBar *)menuBar {
    return [UIFont systemFontOfSize:15.0f];
}

/****************************************************************************/
//< For Seperator 
/****************************************************************************/

///**< Color of Seperator, by Default White */
//- (UIColor *)seperatorColorInMenuBar:(LightMenuBar *)menuBar {
//}

/**< Width of Seperator, by Default 1.0f */
- (CGFloat)seperatorWidthInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
}

/**< Height Rate of Seperator, by Default 0.7f */
- (CGFloat)seperatorHeightRateInMenuBar:(LightMenuBar *)menuBar {
    return 0.0f;
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
            if ([self.supplyItems count] == 1)
            {
                return [self.supplyItems count] + 1;
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
		if ([indexPath row] == 0) 
		{
			//搜索
			return 40.0f;
		}
		else 
		{
			if (self.supplyItems != nil && [self.supplyItems count] > 1)
			{
				if ([indexPath row] == [self.supplyItems count])
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
	if (showType ==  1) 
	{
		//供应talbeView
		items = self.supplyItems;
		countItems = [self.supplyItems count];
        
        NSArray *supplyArray; // dufu add 2013.04.28
        int price; // dufu add 2013.04.28
        
        if ([indexPath row] != 0 && [indexPath row] != countItems && countItems != 0){
            supplyArray = [items objectAtIndex:[indexPath row]];
            price = [[supplyArray objectAtIndex:supply_price] intValue]; // dufu add 2013.04.28
        }
		
		if ([indexPath row] == 0) 
		{
			//搜索
			CellIdentifier = @"searchCell";
		}
		else 
		{
			if (items != nil && countItems > 1)
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
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			//cell.backgroundView = 
			//cell.selectedBackgroundView = 
			if ([indexPath row] == 0)
			{
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				//搜索图标
				UIImageView *searchPicView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0 , 320, 40)];
				searchPicView.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"搜索供应" ofType:@"png"]];
				
				//绑定搜索事件
				searchPicView.userInteractionEnabled = YES;
				UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchSupply)];
				[searchPicView addGestureRecognizer:singleTap];
				[singleTap release];
				
				[cell.contentView addSubview:searchPicView];
				[searchPicView release];
			}
			else
			{
				if (items != nil && countItems > 1)
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
						
						UIImageView *supplyBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake( MARGIN , MARGIN , 80.0f , 60.0f)];
						UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"供应列表图片背景" ofType:@"png"]];
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
						detailtitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
						[cell.contentView addSubview:detailtitle];
						[detailtitle release];
						
                        if (price > EXPANSION) {
                            UIImageView *priceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN * 9 + 3.0f, 16.0f, 16.0f)];
                            UIImage *priceImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"价格小图标" ofType:@"png"]];
                            priceImageView.image = priceImage;
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
                            
                            UIImageView *favImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN * 2 + 200.0f, MARGIN * 9 + 3.0f, 16.0f, 16.0f)];
                            UIImage *favImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"收藏小图标" ofType:@"png"]];
                            favImageView.image = favImage;
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
                        }
						                        
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
		}
		
		if ([indexPath row] != 0 && [indexPath row] != countItems && countItems != 0){
			
			UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:100];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
			UILabel *supplyTitle = (UILabel *)[cell.contentView viewWithTag:102];
			UILabel *detailTitle = (UILabel *)[cell.contentView viewWithTag:103];
            
            UILabel *priceTitle;
			UILabel *favTitle;
            if (price > EXPANSION) {
                priceTitle = (UILabel *)[cell.contentView viewWithTag:104];
                favTitle = (UILabel *)[cell.contentView viewWithTag:105];
            }
			
            UIImageView *recommendImageView = (UIImageView *)[cell.contentView viewWithTag:106];
			
			//NSArray *supplyArray = [items objectAtIndex:[indexPath row]];
			NSString *piclink = [supplyArray objectAtIndex:supply_pic];
			if (piclink)
			{
				[supplyTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
				
				[detailTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN * 5, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
				
                if (price > EXPANSION) {
                    [priceTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    
                    [favTitle setFrame:CGRectMake(MARGIN * 2 + 200.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                }
				
				
				[picView setFrame:CGRectMake(MARGIN + 2, MARGIN + 2, photoWith, photoHigh)];
				
				//获取本地图片缓存
				UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
				
				if (cardIcon == nil)
				{
					UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"供应列表默认图片" ofType:@"png"]];
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
				
				[detailTitle setFrame:CGRectMake(MARGIN * 2, MARGIN * 5, cell.frame.size.width-6 * MARGIN, 20)];
				
                if (price > EXPANSION) {
                    [priceTitle setFrame:CGRectMake(MARGIN * 2 + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
                    
                    [favTitle setFrame:CGRectMake(MARGIN * 2 + 120.0f + 16.0f, MARGIN * 9, 150.0f, 20.0f)];
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
            if (price > EXPANSION) {
                priceTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_price]];
                favTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_favorite]];
            }
			
		}
		
	}
	else 
	{
		//求购talbeView
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

		if ([indexPath row] != 0 && self.supplyItems != nil && [self.supplyItems count] > 1)
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
				[self accessMoreService:OPERAT_SUPPLY_MORE itemsUpdateTime:updateTime];
				
				[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];

			}
			else 
			{
				NSArray *supplyArray = [self.supplyItems objectAtIndex:[indexPath row]];
				NSString *supplyID = [supplyArray objectAtIndex:supply_id];
				supplyDetailViewController *supplyDetail = [[supplyDetailViewController alloc] init];
				
				supplyDetail.supplyID = supplyID;
				NSMutableArray *supplyInfoArray = [[NSMutableArray alloc] init];
				[supplyInfoArray addObject:supplyArray];
				supplyDetail.supplyArray = supplyInfoArray;
				[supplyInfoArray release];
                
                supplyDetail.commentTotal = [NSString stringWithFormat:@"%d",[[supplyArray objectAtIndex:supply_commentTotal] intValue]];
                supplyDetail.isFrom = YES;
				
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
				[self accessMoreService:OPERAT_DEMAND_MORE itemsUpdateTime:updateTime];
				
				[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
			}
			else 
			{
				//记录
				NSArray *demandArray = [self.demandItems objectAtIndex:[indexPath row]];
				NSString *demandID = [demandArray objectAtIndex:demand_id];
				demandDetailViewController *demandDetail = [[demandDetailViewController alloc] init];			
				demandDetail.demandID = demandID;
				NSMutableArray *demandInfoArray = [[NSMutableArray alloc] init];
				[demandInfoArray addObject:demandArray];
				demandDetail.demandArray = demandInfoArray;
				[demandInfoArray release];
				
                 demandDetail.commentTotal = [NSString stringWithFormat:@"%d",[[demandArray objectAtIndex:demand_commentTotal] intValue]];
                demandDetail.isFrom = YES;
                
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

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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
				[self accessMoreService:OPERAT_SUPPLY_MORE itemsUpdateTime:updateTime];
            }
            else
            {
                NSArray *demandArray = [self.demandItems objectAtIndex:[self.demandItems count]-1];
				int updateTime = [[demandArray objectAtIndex:demand_update_time] intValue];
				[self accessMoreService:OPERAT_DEMAND_MORE itemsUpdateTime:updateTime];
            }
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (showType == 1)
	{
		[self loadImagesForOnscreenRows];
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.myTableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
	if (showType == 1) 
	{
		int catVer;
		
		if (cat_id == 0)
		{
			catVer = [[Common getVersion:OPERAT_SUPPLY_REFRESH] intValue];
		}
		else
		{
			NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
			if ([catItems count] > 0)
			{
				NSMutableArray *catArray = [catItems objectAtIndex:0];
				catVer = [[catArray objectAtIndex:supply_cat_version] intValue];
			}
			else 
			{
				catVer = 0;
			}
			
		}
		
		[self accessItemService:OPERAT_SUPPLY_REFRESH accessVer:catVer];
	}
	else
	{
		int catVer;
		
		if (cat_id == 0)
		{
			catVer = [[Common getVersion:OPERAT_DEMAND_REFRESH] intValue];
		}
		else
		{
			NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
			if ([catItems count] > 0)
			{
				NSMutableArray *catArray = [catItems objectAtIndex:0];
				catVer = [[catArray objectAtIndex:demand_cat_version] intValue];
			}
			else 
			{
				catVer = 0;
			}
			
		}
		
		[self accessItemService:OPERAT_DEMAND_REFRESH accessVer:catVer];
	}

	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
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
    self.supplyItems = nil;
	self.demandItems = nil;
	self.supplyCatItems = nil;
	self.demandCatItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.myMenuBar.delegate = nil;
    self.myMenuBar = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
	self.spinner = nil;
    self.moreLabel = nil;
}


- (void)dealloc {
	self.supplyItems = nil;
	self.demandItems = nil;
	self.supplyCatItems = nil;
	self.demandCatItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.myMenuBar.delegate = nil;
    self.myMenuBar = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
	self.spinner = nil;
    self.moreLabel = nil;
    [super dealloc];
}


@end
