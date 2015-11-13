//
//  NewestViewController.m
//  Profession
//
//  Created by LuoHui on 12-9-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewestViewController.h"
#import "Common.h"
#import "NewsDetailViewController.h"
#import "IconDownLoader.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "callSystemApp.h"
#import "downloadParam.h"
#import "DataManager.h"
#import "Encry.h"
#import "UIImageScale.h"

#define MARGIN 5
#define PHOTOWIDTH 76
#define PHOTOHEIGHT 56

@implementation NewestViewController
@synthesize myNavigationController;
@synthesize myTableView;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize iconDownLoad;
@synthesize newsArray;
@synthesize catid;
@synthesize catversion;
@synthesize isLoadMore;
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
    
    self.title = @"最新资讯";
    
    self.catid = [NSNumber numberWithInt: 0];
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
	
}

- (void) viewWillAppear:(BOOL)animated{
    
	[super viewWillAppear:animated];
    
    self.newsArray = (NSMutableArray*)[DBOperate queryData:T_NEWS_LIST theColumn:@"catid" 
                                            theColumnValue:[NSString stringWithFormat:@"%d",[catid intValue]] withAll:NO];
    if ([self.newsArray count] == 0)
    {
        //添加loading图标
        UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, self.view.frame.size.height / 2.0)];
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
        
        [self accessService];
    }
    else 
    {
        [self addTableView];
    }
	
}

//添加数据表视图
-(void)addTableView;
{
	//[self.myTableView removeFromSuperview];
	
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 320.0f , self.view.frame.size.height)];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
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
		int countItems = [self.newsArray count];
		if (countItems >[indexPath row])
		{
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(80, 60)];
			
			UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:103];
			
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
    NSArray *ay = [self.newsArray objectAtIndex:indexPath.row];
    return [ay objectAtIndex:newslist_spic];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	
	int countItems = [self.newsArray count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *ay = [self.newsArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[ay objectAtIndex:newslist_spic] dataUsingEncoding: NSUTF8StringEncoding]];
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
	
	int countItems = [self.newsArray count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *ay = [self.newsArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[ay objectAtIndex:newslist_spic] dataUsingEncoding: NSUTF8StringEncoding]];
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
			
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(80, 60)];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:103];
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
	self.myNavigationController = nil;
	self.myTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.iconDownLoad = nil;
	self.newsArray = nil;
	self.catversion = nil;
    self.spinner = nil;
    self.moreLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
	[myNavigationController release];
	myNavigationController = nil;
	[myTableView release];
	myTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	[imageDownloadsInProgress release];
	imageDownloadsInProgress = nil;
	[imageDownloadsInWaiting release];
	imageDownloadsInWaiting = nil;
	[iconDownLoad release];
	iconDownLoad = nil;
	[newsArray release],newsArray = nil;
	[catid release],catid = nil;
	[catversion release],catversion = nil;
    self.spinner = nil;
    self.moreLabel = nil;
    [super dealloc];
}

- (void) accessService{	
	isLoadMore = NO;
    
    catversion = [Common getVersion:ACCESS_ALL_NEWS_COMMAND_ID];
    
	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSString stringWithFormat:@"%d",[catversion intValue]],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSString stringWithFormat:@"%d",[catid intValue]],@"cats_id",
										[NSNumber numberWithInt: 0],@"updatetime",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:ACCESS_NEWS_COMMAND_ID 
								  accessAdress:@"news.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void) accessMoreService{
	isLoadMore = YES;
	NSArray *ay = [newsArray lastObject];
	int updatetime = [[ay objectAtIndex:newslist_updatetime] intValue];
	
	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSString stringWithFormat:@"%d",-1],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSString stringWithFormat:@"%d",[catid intValue]],@"cats_id",
										[NSNumber numberWithInt: updatetime],@"updatetime",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:ACCESS_NEWS_COMMAND_ID 
								  accessAdress:@"news.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    
	[self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
    
}

- (void) update:(NSMutableArray*)resultArray{
	if (isLoadMore) {
		[self appendTableWith:resultArray];
	}else {
		[newsArray removeAllObjects];
		self.newsArray = nil;
		self.newsArray = (NSMutableArray*)[DBOperate queryData:T_NEWS_LIST theColumn:@"catid" 
												theColumnValue:[NSString stringWithFormat:@"%d",[catid intValue]] withAll:NO];
		//添加表视图
        if ([self.myTableView isDescendantOfView:self.view]) 
        {
            [self.myTableView reloadData];
        }
        else
        {
            [self addTableView];
        }
		
		//移除loading图标
        [self.spinner removeFromSuperview];
        
        _loadingMore = NO;
        if (self.moreLabel) {
            self.moreLabel.text = @"上拉加载更多";
        }
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
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

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data
{
	//合并数据
	if (data != nil && [data count] > 0) 
	{		
		for (int i = 0; i < [data count];i++ ) 
		{
			NSArray *ay = [data objectAtIndex:i];
			[self.newsArray addObject:ay];
		}
		NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
		for (int ind = 0; ind < [data count]; ind++) 
		{
			NSIndexPath *newPath = [NSIndexPath indexPathForRow:
									[newsArray indexOfObject:[data objectAtIndex:ind]] inSection:0];
			[insertIndexPaths addObject:newPath];
		}
		[myTableView insertRowsAtIndexPaths:insertIndexPaths 
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.newsArray count] == 0)
    {
        return 1;
    }
    else 
    {
        return [self.newsArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.newsArray != nil && [self.newsArray count] > 0)
    {
        if ([indexPath row] == [self.newsArray count])
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
	static NSString *CellIdentifier;
	UITableViewCell *cell;
    
    if (self.newsArray != nil && [self.newsArray count] > 0)
    {
        if ([indexPath row] == [self.newsArray count])
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
        
        //ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if (self.newsArray != nil && [self.newsArray count] > 0)
        {
            if ([indexPath row] == [self.newsArray count])
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
                //记录
                UIImageView *newsBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN,MARGIN,80 , 60)];
                UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:
                                      [[NSBundle mainBundle] pathForResource:@"资讯列表图片背景" ofType:@"png"]];
                newsBackImageView.image = backImage;
                [backImage release];
                [cell.contentView addSubview:newsBackImageView];
                [newsBackImageView release];
                
                UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectZero];
                picView.tag = 103;
                [cell.contentView addSubview:picView];
                [picView release];
                
                UILabel *mtitle = [[UILabel alloc]initWithFrame:
                                   CGRectMake(MARGIN * 2 + 80, MARGIN, cell.frame.size.width-PHOTOWIDTH-5 * MARGIN - 20, 20)];
                mtitle.backgroundColor = [UIColor clearColor];
                mtitle.tag = 101;
                mtitle.text = @"";
                mtitle.font = [UIFont systemFontOfSize:16];
                mtitle.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];		
                [cell.contentView addSubview:mtitle];
                [mtitle release];
                
                UILabel *detailtitle = [[UILabel alloc]initWithFrame:
                                        CGRectMake(MARGIN * 2 + 80, 25, cell.frame.size.width-PHOTOWIDTH-5 * MARGIN - 20, 40)];
                detailtitle.backgroundColor = [UIColor clearColor];
                detailtitle.tag = 102;
                detailtitle.text = @"";
                detailtitle.numberOfLines = 2;
                detailtitle.font = [UIFont systemFontOfSize:12];
                detailtitle.textColor = [UIColor grayColor];			
                [cell.contentView addSubview:detailtitle];
                [detailtitle release];
                
//                UILabel *timetitle = [[UILabel alloc]initWithFrame:
//                                      CGRectMake(MARGIN * 2 + 80, 45, cell.frame.size.width-PHOTOWIDTH-5 * MARGIN - 20, 20)];
//                timetitle.backgroundColor = [UIColor clearColor];
//                timetitle.tag = 104;
//                timetitle.text = @"";
//                timetitle.font = [UIFont systemFontOfSize:12];
//                timetitle.textColor = [UIColor grayColor];			
//                [cell.contentView addSubview:timetitle];
//                [timetitle release];
                
                //添加右箭头
                UIImageView *rightImage = [[UIImageView alloc]initWithFrame:
                                           CGRectMake(self.view.frame.size.width - 16 - MARGIN, 32, 16, 11)];
                UIImage *rimg;
                rimg = [[UIImage alloc]initWithContentsOfFile:
                        [[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
                rightImage.image = rimg;
                [rimg release];
                [cell.contentView addSubview:rightImage];
                [rightImage release];
                
                //推荐图标
                UIImageView *recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
                recommendImageView.tag = 106;
                recommendImageView.hidden = YES;
                [cell.contentView addSubview:recommendImageView];
                [recommendImageView release];
            }
        }
        else
        {
            //没有记录
            UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
            noneLabel.tag = 201;
            [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
            noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
            noneLabel.text = @"没找到任何资讯信息！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLabel];
            [noneLabel release];
        }
		
		
	}
	
	if ([indexPath row] != [newsArray count] && [newsArray count] != 0) 
    {
        UILabel *mainTitle = (UILabel*)[cell.contentView viewWithTag:101];
        UILabel *detailTitle = (UILabel*)[cell.contentView viewWithTag:102];
        UIImageView *picView = (UIImageView*)[cell.contentView viewWithTag:103];
        //UILabel *timeTitle = (UILabel*)[cell.contentView viewWithTag:104];
        UIImageView *recommendImageView = (UIImageView *)[cell.contentView viewWithTag:106];
        
		NSArray *ay = [newsArray objectAtIndex:indexPath.row];
		
		mainTitle.text = [ay objectAtIndex:newslist_title];
		detailTitle.text = [ay objectAtIndex:newslist_desc];
        
//        int createTime = [[ay objectAtIndex:newslist_created] intValue];
//        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
//        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
//        //[outputFormat setTimeZone:[NSTimeZone timeZoneWithName:@"H"]]; 
//        [outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
//        NSString *dateString = [outputFormat stringFromDate:date];
//        timeTitle.text = dateString;
//        [outputFormat release];
		
		
        [picView setFrame:CGRectMake(MARGIN+2, MARGIN+2, 76, 56)];
        
        //获取本地图片缓存
        UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(76, 56)];
        
        if (cardIcon == nil)
        {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认图资讯列表" ofType:@"png"]];
            picView.image = [img fillSize:CGSizeMake(80, 60)];
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
        
        //推荐图标
        if ([[ay objectAtIndex:newslist_recommend] intValue] == 1) 
        {
            UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"头条" ofType:@"png"]];
            recommendImageView.image = recommendImage;
            [recommendImage release];
            recommendImageView.hidden = NO;
        }
        else 
        {
            if ([[ay objectAtIndex:newslist_push_time] intValue] != 0) 
            {
                UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
                recommendImageView.image = recommendImage;
                [recommendImage release];
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

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.newsArray != nil && [self.newsArray count] > 0)
    {
        if ([indexPath row] == [self.newsArray count])
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
			[self accessMoreService];
            
			[self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else 
        {
            //记录
            NSArray *ay = [newsArray objectAtIndex:indexPath.row];
            
            NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
            detail.detailArray = ay;
            detail.commentTotal = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:newslist_commentTotal] intValue]];
            detail.isFrom = YES;
            [self.myNavigationController pushViewController:detail animated:YES];
            [detail release];
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
			[self accessMoreService];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.newsArray count] >= 20)
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
	
    [self accessService];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
