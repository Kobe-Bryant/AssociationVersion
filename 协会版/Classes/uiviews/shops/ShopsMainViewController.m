//
//  ShopsMainViewController.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopsMainViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "LightMenuBar.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "shopDetailViewController.h"
#import "SearchViewController.h"
#import "CustomNavigationController.h"

#define MARGIN 5.0f

@implementation ShopsMainViewController

@synthesize myTableView;
@synthesize myMenuBar;
@synthesize shopItems;
@synthesize shopCatItems;
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor clearColor];
	
	photoWith = 75;
	photoHigh = 75;
	
	isFirstLoadingShopCat = YES;
	
	cat_id = 0;
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
	
	//商铺数据初始化
	NSMutableArray *tempShopArray = [[NSMutableArray alloc] init];
	self.shopItems = tempShopArray;
	[tempShopArray release];
	
	
	//商铺分类数据初始化
	NSMutableArray *tempShopCatArray = [[NSMutableArray alloc] init];
	self.shopCatItems = tempShopCatArray;
	[tempShopCatArray release];
	
	//从数据库中取出数据 
	self.shopCatItems = (NSMutableArray *)[DBOperate queryData:T_SHOP_CAT theColumn:@"" theColumnValue:@"" withAll:YES];
	
	if (isFirstLoadingShopCat) 
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
		isFirstLoadingShopCat = NO;
		[self accessCatService:OPERAT_SHOP_CAT_REFRESH];
		
	}
	else 
	{
		if ([self.shopCatItems count] == 0) 
		{
			UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
			noneLabel.font = [UIFont systemFontOfSize:14];
			noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
			noneLabel.text = TIPS_NONE_CAT;
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
			[self.shopCatItems insertObject:allCat atIndex:0];
			[allCat release];
			
			//添加分类导航
			[self addCatNat];
		}
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
	//[self.myTableView removeFromSuperview];
	
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 40.0f , 320.0f , VIEW_HEIGHT - 20 - 44 - 49 - 40.0f)];
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
-(void)searchShop
{
	//这里做搜索页面跳转
	SearchViewController *searchView = [[SearchViewController alloc] init];
	searchView.selectIndex = search_shops;
	CustomNavigationController *navController = [[CustomNavigationController alloc]
											 initWithRootViewController:searchView];
	[navController setModalPresentationStyle:UIModalPresentationCurrentContext]; 
	[self.navigationController presentModalViewController:navController animated:YES]; 
	[searchView release];
	[navController release];
}

//滚动loading图片
- (void)loadImagesForOnscreenRows
{
	//NSLog(@"load images for on screen");
	NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
		int countItems = [self.shopItems count];
		if (countItems >[indexPath row])
		{
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
			
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
	NSArray *shopArray = [self.shopItems objectAtIndex:[indexPath row]];
	return [shopArray objectAtIndex:shop_pic];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	
	int countItems = [self.shopItems count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *shopArray = [self.shopItems objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[shopArray objectAtIndex:shop_pic] dataUsingEncoding: NSUTF8StringEncoding]];
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
	
	int countItems = [self.shopItems count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *shopArray = [self.shopItems objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[shopArray objectAtIndex:shop_pic] dataUsingEncoding: NSUTF8StringEncoding]];
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
                UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
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

//网络获取分类数据
-(void)accessCatService:(int)commandid
{
	NSString *reqUrl = @"ccats.do?param=%@";
	
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
	NSString *reqUrl = @"companies.do?param=%@";
	
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
	NSString *reqUrl = @"companies.do?param=%@";
	
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

//更新商铺分类的操作
-(void)updateShopCat
{
    //设置回常态
	[self backNormal];
    
	//重新更新数据
	self.shopCatItems = (NSMutableArray *)[DBOperate queryData:T_SHOP_CAT theColumn:@"" theColumnValue:@"" withAll:YES];
	
	if ([self.shopCatItems count] == 0) 
	{
		UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 180, 20)];
		noneLabel.font = [UIFont systemFontOfSize:14];
		noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		noneLabel.text = TIPS_NONE_CAT;
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
		[self.shopCatItems insertObject:allCat atIndex:0];
		[allCat release];
		
		//添加分类导航
		[self addCatNat];
	}
}

//更新商铺的操作
-(void)updateShop
{
	NSString *_cat_id = [NSString stringWithFormat:@"%d",cat_id];
	
	//重新更新数据
	self.shopItems = (NSMutableArray *)[DBOperate queryData:T_SHOP theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
	
	//新增一个搜索行的数据
	NSMutableArray *searchShopData = [[NSMutableArray alloc]init];
	[searchShopData addObject:[NSString stringWithFormat:@"0"]];
	[searchShopData addObject:[NSString stringWithFormat:@""]];
	[searchShopData addObject:[NSString stringWithFormat:@""]];
	[searchShopData addObject:[NSString stringWithFormat:@""]];
	[searchShopData addObject:@""];
	[searchShopData addObject:[NSString stringWithFormat:@""]];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[searchShopData addObject:@""];
	[self.shopItems insertObject:searchShopData atIndex:0];
	[searchShopData release];
	
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
	//合并数据
	if (data != nil && [data count] > 0) 
	{
		for (int i = 0; i < [data count];i++ ) 
		{
			NSArray *shopArray = [data objectAtIndex:i];
			[self.shopItems addObject:shopArray];
		}
		
		NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
		for (int ind = 0; ind < [data count]; ind++) 
		{
			NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.shopItems indexOfObject:[data objectAtIndex:ind]] inSection:0];
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
				//商铺刷新
			case OPERAT_SHOP_REFRESH:
				[self performSelectorOnMainThread:@selector(updateShop) withObject:nil waitUntilDone:NO];
				break;
				
				//商铺分类刷新
			case OPERAT_SHOP_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateShopCat) withObject:nil waitUntilDone:NO];
				break;
				
				//商铺更多
			case OPERAT_SHOP_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
				break;
				
			default:   ;
		}
	}
	else
	{
		switch(commandid)
		{
				//商铺刷新
			case OPERAT_SHOP_REFRESH:
				[self performSelectorOnMainThread:@selector(updateShop) withObject:nil waitUntilDone:NO];
				break;
				
				//商铺分类刷新
			case OPERAT_SHOP_CAT_REFRESH:
				[self performSelectorOnMainThread:@selector(updateShopCat) withObject:nil waitUntilDone:NO];
				break;
				
				//商铺更多
			case OPERAT_SHOP_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
			default:   ;
		}
	}
	
}



#pragma mark 滚动导航委托 LightMenuBarDelegate
- (NSUInteger)itemCountInMenuBar:(LightMenuBar *)menuBar {
	
	return [self.shopCatItems count];
	
}

- (NSString *)itemTitleAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	NSArray *shopCatArray = [self.shopCatItems objectAtIndex:index];
	return [shopCatArray objectAtIndex:shop_cat_name];
	
}

- (void)itemSelectedAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	//设置回常态
	[self backNormal];
    
    _loadingMore = NO;
	
	NSArray *shopCatArray = [self.shopCatItems objectAtIndex:index];
	NSString *_cat_id = [shopCatArray objectAtIndex:shop_cat_id];
	cat_id = [_cat_id intValue];
	
	int catVer;
	
	if (cat_id == 0)
	{
		catVer = [[Common getVersion:OPERAT_SHOP_REFRESH] intValue];
	}
	else
	{
		NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_SHOP_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
		if ([catItems count] > 0)
		{
			NSMutableArray *catArray = [catItems objectAtIndex:0];
			catVer = [[catArray objectAtIndex:shop_cat_version] intValue];
		}
		else 
		{
			catVer = 0;
		}
		
	}
	
	//从数据库中取出数据 
	self.shopItems = (NSMutableArray *)[DBOperate queryData:T_SHOP theColumn:@"cat_id" theColumnValue:_cat_id  withAll:NO];
	
	if ([self.shopItems count] == 0) 
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
		[self accessItemService:OPERAT_SHOP_REFRESH accessVer:catVer];
	}
	else 
	{
		//新增一个搜索行的数据
		NSMutableArray *searchShopData = [[NSMutableArray alloc]init];
		[searchShopData addObject:[NSString stringWithFormat:@"0"]];
		[searchShopData addObject:[NSString stringWithFormat:@""]];
		[searchShopData addObject:[NSString stringWithFormat:@""]];
		[searchShopData addObject:[NSString stringWithFormat:@""]];
		[searchShopData addObject:@""];
		[searchShopData addObject:[NSString stringWithFormat:@""]];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[searchShopData addObject:@""];
		[self.shopItems insertObject:searchShopData atIndex:0];
		[searchShopData release];
		
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

//< Optional
- (CGFloat)itemWidthAtIndex:(NSUInteger)index inMenuBar:(LightMenuBar *)menuBar {
	
	if ([self.shopCatItems count] > 3) 
	{
		return self.myMenuBar.frame.size.width / 3;
	}
	else 
	{
		return self.myMenuBar.frame.size.width / [self.shopCatItems count];
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
    //return [UIColor blackColor];
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
    if ([self.shopCatItems count] > 3) 
	{
		checkedImgName = @"导航栏3选中";
	}
	else 
	{
		checkedImgName = [NSString stringWithFormat:@"导航栏%d选中",[self.shopCatItems count]];
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
	
    if ([self.shopItems count] >= 20)
    {
        return [self.shopItems count] + 1;
    }
    else
    {
        if ([self.shopItems count] == 1)
        {
            return [self.shopItems count] + 1;
        }
        else
        {
            return [self.shopItems count];
        }
    }
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] == 0) 
	{
		//搜索
		return 40.0f;
	}
	else 
	{
		if (self.shopItems != nil && [self.shopItems count] > 1)
		{
			if ([indexPath row] == [self.shopItems count])
			{
				//点击更多
				return 50.0f;
			}
			else 
			{
				//记录
				return 87.0f;
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
	
	NSMutableArray *items = self.shopItems;
	int countItems =  [self.shopItems count];
	
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
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
		//cell.backgroundView =
		//cell.selectedBackgroundView = 
		if ([indexPath row] == 0)
		{
            self.myTableView.separatorColor = [UIColor clearColor];
			
			//搜索图标
			UIImageView *searchPicView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0 , 320, 40)];
			searchPicView.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"搜索店铺" ofType:@"png"]];
			
			//绑定搜索事件
			searchPicView.userInteractionEnabled = YES;
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchShop)];
			[searchPicView addGestureRecognizer:singleTap];
			[singleTap release];
			
			[cell.contentView addSubview:searchPicView];
			[searchPicView release];
		}
		else
		{
			if (items != nil && countItems > 1)
			{
                self.myTableView.separatorColor = [UIColor clearColor];
                
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
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 0.0f , 85.0f, cell.frame.size.width, 2.0f)];
                    UIImage * lineImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
                    lineImageView.image = lineImg;
                    [lineImg release];
                    [cell.contentView addSubview:lineImageView];
                    [lineImageView release];
					
					UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(300, 38, 16, 11)];
					UIImage *rimg;
					rimg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
					rightImage.image = rimg;
					[rimg release];
					[cell.contentView addSubview:rightImage];
					[rightImage release];
					
					UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectZero];
					picView.tag = 100;
//                    picView.layer.masksToBounds = YES;
//                    picView.layer.cornerRadius = 10;
					[cell.contentView addSubview:picView];
					[picView release];

					UILabel *shopTitle = [[UILabel alloc]initWithFrame:CGRectZero];
					shopTitle.backgroundColor = [UIColor clearColor];
					shopTitle.tag = 102;
					shopTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					shopTitle.font = [UIFont systemFontOfSize:18];
					shopTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
					[cell.contentView addSubview:shopTitle];
					[shopTitle release];
					
					UILabel *telTitle = [[UILabel alloc]initWithFrame:CGRectZero];
					telTitle.backgroundColor = [UIColor clearColor];
					telTitle.tag = 103;
					telTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					telTitle.font = [UIFont systemFontOfSize:14];
					telTitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
					[cell.contentView addSubview:telTitle];
					[telTitle release];
					
					UILabel *addressTitle = [[UILabel alloc]initWithFrame:CGRectZero];
					addressTitle.backgroundColor = [UIColor clearColor];
					addressTitle.tag = 104;
					addressTitle.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
					addressTitle.font = [UIFont systemFontOfSize:12];
					addressTitle.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
					[cell.contentView addSubview:addressTitle];
					[addressTitle release];
                    
                    UIImageView *attestationImageView = [[UIImageView alloc] initWithFrame:CGRectMake( MARGIN - 1.0f, MARGIN + 10.0f, 34.0f , 34.0f)];
                    UIImage *attestationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺认证标识" ofType:@"png"]];
                    attestationImageView.image = attestationImage;
                    attestationImageView.tag = 105;
                    attestationImageView.hidden = YES;
                    [attestationImage release];
                    [cell.contentView addSubview:attestationImageView];
                    [attestationImageView release];
					
					cell.backgroundColor = [UIColor clearColor];
					
				}
			}
			else
			{
				UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
				noneLabel.tag = 201;
				[noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
				noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
				noneLabel.text = TIPS_NONE_CAT_CONTENT;			
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:noneLabel];
				[noneLabel release];
			}
		}
	}
	
	if ([indexPath row] != 0 && [indexPath row] != countItems && countItems != 0){
		
		UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
		UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:101];
		UILabel *shopTitle = (UILabel *)[cell.contentView viewWithTag:102];
		UILabel *telTitle = (UILabel *)[cell.contentView viewWithTag:103];
		UILabel *addressTitle = (UILabel *)[cell.contentView viewWithTag:104];
		UIImageView *attestationImageView = (UIImageView *)[cell.contentView viewWithTag:105];
		
		NSArray *shopArray = [items objectAtIndex:[indexPath row]];
		NSString *piclink = [shopArray objectAtIndex:shop_pic];
		if (piclink)
		{
			[shopTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN * 2, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
			
			[telTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN * 7, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
			
			[addressTitle setFrame:CGRectMake(MARGIN * 2 + 80.0f, MARGIN * 11, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
			
			[picView setFrame:CGRectMake(MARGIN, MARGIN, photoWith, photoHigh)];
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			if (cardIcon == nil)
			{
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺列表默认图片" ofType:@"png"]];
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
			
			//认证的图标
			if ([[shopArray objectAtIndex:shop_attestation] intValue] == 1)
			{
				attestationImageView.hidden = NO;
			}
            else 
            {
                attestationImageView.hidden = YES;
            }
			
		}
		else 
		{
			[backImage removeFromSuperview];
			[shopTitle setFrame:CGRectMake(MARGIN * 2, MARGIN * 2, cell.frame.size.width-6 * MARGIN, 20)];
			
			[telTitle setFrame:CGRectMake(MARGIN * 2, MARGIN * 7, cell.frame.size.width-6 * MARGIN, 20)];
			
			[addressTitle setFrame:CGRectMake(MARGIN * 2, MARGIN * 11, cell.frame.size.width-6 * MARGIN, 20)];
			
		}
		
		shopTitle.text = [shopArray objectAtIndex:shop_title];
		telTitle.text = [shopArray objectAtIndex:shop_tel];
		addressTitle.text = [shopArray objectAtIndex:shop_address];
	}
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if ([indexPath row] != 0 && self.shopItems != nil && [self.shopItems count] > 1)
	{
		if ([indexPath row] == [self.shopItems count])
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
			NSArray *shopArray = [self.shopItems objectAtIndex:[self.shopItems count]-1];
			int updateTime = [[shopArray objectAtIndex:shop_update_time] intValue];
			[self accessMoreService:OPERAT_SHOP_MORE itemsUpdateTime:updateTime];

			[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
		
		}
		else 
		{
			NSArray *shopArray = [self.shopItems objectAtIndex:[indexPath row]];
			NSString *shopID = [shopArray objectAtIndex:shop_id];
			shopDetailViewController *shopDetail = [[shopDetailViewController alloc] init];			

			shopDetail.shopID = shopID;
			NSMutableArray *shopInfoArray = [[NSMutableArray alloc] init];
			[shopInfoArray addObject:shopArray];
			shopDetail.shopItems = shopInfoArray;
			[shopInfoArray release];
			[self.navigationController pushViewController:shopDetail animated:YES];
			[shopDetail release];
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
	if (!decelerate)
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
			NSArray *shopArray = [self.shopItems objectAtIndex:[self.shopItems count]-1];
			int updateTime = [[shopArray objectAtIndex:shop_update_time] intValue];
			[self accessMoreService:OPERAT_SHOP_MORE itemsUpdateTime:updateTime];
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.shopItems count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self loadImagesForOnscreenRows];
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
	
	int catVer;
	
	if (cat_id == 0)
	{
		catVer = [[Common getVersion:OPERAT_SHOP_REFRESH] intValue];
	}
	else
	{
		NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_SHOP_CAT theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",cat_id] withAll:NO];
		if ([catItems count] > 0)
		{
			NSMutableArray *catArray = [catItems objectAtIndex:0];
			catVer = [[catArray objectAtIndex:shop_cat_version] intValue];
		}
		else 
		{
			catVer = 0;
		}
		
	}
	
	[self accessItemService:OPERAT_SHOP_REFRESH accessVer:catVer];
	
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
    self.shopItems = nil;
	self.shopCatItems = nil;
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
	self.shopItems = nil;
	self.shopCatItems = nil;
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
