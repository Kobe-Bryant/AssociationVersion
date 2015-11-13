//
//  supplyRecommendViewController.m
//  Profession
//
//  Created by lai yun on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "supplyRecommendViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "UIImageScale.h"
#import "imageDownLoadInWaitingObject.h"
#import "supplyDetailViewController.h"

#define MARGIN 5.0f

#define EXPANSION   0

@implementation supplyRecommendViewController

@synthesize myTableView;
@synthesize supplyItems;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
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
    
    self.title = @"推荐产品";
	
	photoWith = 76;
	photoHigh = 56;
    
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
    
	[self showSupply];
}

//显示供应列表
-(void)showSupply
{
	
	//从数据库中取出数据 
    self.supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_RECOMMEND theColumn:@"" theColumnValue:@""  withAll:YES];
    
    if ([self.supplyItems count] == 0) 
    {
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
        
        //本地没有数据 则从网络请求
        [self accessItemService];
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

//添加数据表视图
-(void)addTableView;
{
	[self.myTableView removeFromSuperview];
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 320.0f , self.view.frame.size.height)];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
	[self.view sendSubviewToBack:self.myTableView];
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
    IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{ 
			//保存图片
			[self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
			
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:101];
			picView.image = photo;
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

//网络获取数据
-(void)accessItemService
{
	NSString *reqUrl = @"recomPro.do?param=%@";
    NSNumber *ver = [Common getVersion:OPERAT_SUPPLY_RECOMMEND_REFRESH];
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 ver,@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: 0],@"updatetime",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_SUPPLY_RECOMMEND_REFRESH 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//网络获取更多数据
-(void)accessMoreService:(int)itemUpdateTime
{
	NSString *reqUrl = @"recomPro.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: -1],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: itemUpdateTime],@"updatetime",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_SUPPLY_RECOMMEND_MORE 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//更新供应的操作
-(void)updateSupply
{
	
	//重新更新数据
	self.supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_RECOMMEND theColumn:@"" theColumnValue:@""  withAll:YES];
	
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

//回归常态
-(void)backNormal
{
	//移除loading图标
    [self.spinner removeFromSuperview];
	
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
			case OPERAT_SUPPLY_RECOMMEND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
                break;
				
                //供应更多
			case OPERAT_SUPPLY_RECOMMEND_MORE:
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
			case OPERAT_SUPPLY_RECOMMEND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateSupply) withObject:nil waitUntilDone:NO];
				break;
				
				//供应更多
			case OPERAT_SUPPLY_RECOMMEND_MORE:
				[self performSelectorOnMainThread:@selector(moreBackNormal:) withObject:NO waitUntilDone:NO];
				break;
				
			default:   ;
		}
	}
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
            return 70.0f;
        }
    }
    else
    {
        //没有记录
        return 50.0f;
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
    
    //供应talbeView
    NSMutableArray *items = self.supplyItems;
    int countItems = [self.supplyItems count];
    
    NSArray *supplyArray; // dufu add 2013.04.28
    int price; // dufu add 2013.04.28
    
    if ([indexPath row] != countItems && countItems != 0){
        supplyArray = [items objectAtIndex:[indexPath row]];
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
                
                UIImageView *recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
                UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
                recommendImageView.image = recommendImage;
                [recommendImage release];
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
    
    if ([indexPath row] != countItems && countItems != 0){
        
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
        
        supplyTitle.text = [supplyArray objectAtIndex:supply_title];
        detailTitle.text = [supplyArray objectAtIndex:supply_desc];
        if (price > EXPANSION) {
            priceTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_price]];
            favTitle.text = [NSString stringWithFormat:@" %@",[supplyArray objectAtIndex:supply_favorite]];
        }
        
    }
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
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
            [self accessMoreService:updateTime];
            
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
            
            //取对应图片
            NSMutableArray *supplyPicArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_PIC_RECOMMEND theColumn:@"supply_id" theColumnValue:supplyID  withAll:NO];
            
            supplyDetail.supplyPicArray = supplyPicArray;
            
            
            [self.navigationController pushViewController:supplyDetail animated:YES];
            [supplyDetail release];
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
			NSArray *supplyArray = [self.supplyItems objectAtIndex:[self.supplyItems count]-1];
            int updateTime = [[supplyArray objectAtIndex:supply_update_time] intValue];
            [self accessMoreService:updateTime];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.supplyItems count] >= 20)
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
    
    [self accessItemService];  
	
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
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.spinner = nil;
    self.moreLabel = nil;
}


- (void)dealloc {
	self.supplyItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.spinner = nil;
    self.moreLabel = nil;
    [super dealloc];
}


@end
