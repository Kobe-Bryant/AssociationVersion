//
//  activityHistoryViewController.m
//  xieHui
//
//  Created by siphp on 13-4-25.
//
//

#import "activityHistoryViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "UIImageScale.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "activityCellViewController.h"
#import "ProfessionAppDelegate.h"
#import "activityDetailViewController.h"

@interface activityHistoryViewController ()

@end

@implementation activityHistoryViewController

@synthesize myTableView;
@synthesize activityItems;
@synthesize spinner;
@synthesize moreLabel;
@synthesize _loadingMore;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green: 0.95 blue: 0.95 alpha:1.0];
    
    NSMutableArray *tempActivityItems = [[NSMutableArray alloc] init];
	self.activityItems = tempActivityItems;
	[tempActivityItems release];
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    picWidth = 100.0f;
    picHeight = 75.0f;
    
    //添加loading图标
    UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f - 40.0f) / 2.0)];
    self.spinner = tempSpinner;
    
    UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
    loadingLabel.font = [UIFont systemFontOfSize:14];
    loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
    loadingLabel.text = LOADING_TIPS;
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.backgroundColor = [UIColor clearColor];
    [self.spinner addSubview:loadingLabel];
    [loadingLabel release];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [tempSpinner release];
    
    //网络获取
    [self accessItemService];
    
}

//添加数据表视图
-(void)addTableView;
{
    //初始化tableView
    if ([self.myTableView isDescendantOfView:self.view])
    {
        [self.myTableView reloadData];
    }
    else
    {
        UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width , self.view.frame.size.height)];
        [tempTableView setDelegate:self];
        [tempTableView setDataSource:self];
        tempTableView.scrollsToTop = YES;
        self.myTableView = tempTableView;
        [tempTableView release];
        self.myTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:myTableView];
        [self.view sendSubviewToBack:self.myTableView];
        [self.myTableView reloadData];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0.0f , 0.0f , self.view.frame.size.width , 10.0f)];
        self.myTableView.tableHeaderView = topMarginView;
        [topMarginView release];
        
        //分割线
        self.myTableView.separatorColor = [UIColor clearColor];
        
    }
}

//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
    
	for (NSIndexPath *indexPath in visiblePaths)
	{
		int countItems = [self.activityItems count];
		if (countItems >[indexPath row])
		{
            
            NSArray *activityArray = [self.activityItems objectAtIndex:[indexPath row]];
            
            activityCellViewController *activityCell = (activityCellViewController *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
            //图片
            NSString *picUrl = [activityArray objectAtIndex:activity_history_pic];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1)
            {
                UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
                if (pic.size.width > 2)
                {
                    activityCell.picView.image = pic;
                }
                else
                {
                    UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
                    activityCell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                    
                    if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
                    {
                        [activityCell.picView stopSpinner];
                        [activityCell.picView startSpinner];
                        [self startIconDownload:picUrl forIndexPath:indexPath];
                    }
                }
            }
            else
            {
                UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
                activityCell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
            }
            
        }
		
	}
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
    int countItems = [self.activityItems count];
	
	if (countItems > [indexPath row])
	{
		NSArray *activityArray = [self.activityItems objectAtIndex:[indexPath row]];
        NSString *picUrl = [activityArray objectAtIndex:activity_history_pic];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
		
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
        activityCellViewController *activityCell = (activityCellViewController *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
            
            UIImage *pic = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
            activityCell.picView.image = pic;
            [activityCell.picView stopSpinner];
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

//更新记录
-(void)update
{
    //取数据
    self.activityItems = [DBOperate queryData:T_ACTIVITY_HISTORY
                                    theColumn:@"" theColumnValue:@"" orderBy:@"end_time" orderType:@"desc" withAll:YES];
    
    //添加表
    [self addTableView];
    
    //回归常态
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
			NSArray *activityArray = [data objectAtIndex:i];
			[self.activityItems addObject:activityArray];
		}
		
		NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
		for (int ind = 0; ind < [data count]; ind++)
		{
			NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.activityItems indexOfObject:[data objectAtIndex:ind]] inSection:0];
			[insertIndexPaths addObject:newPath];
		}
		[self.myTableView insertRowsAtIndexPaths:insertIndexPaths
								withRowAnimation:UITableViewRowAnimationFade];
		
	}
	
	[self moreBackNormal];
}


//网络获取数据
-(void)accessItemService
{
    NSString *reqUrl = @"activitylist.do?param=%@";
    
    //取本地第一条记录end_time
    int end_time = 0;
    self.activityItems = [DBOperate queryData:T_ACTIVITY_HISTORY
                                    theColumn:@"" theColumnValue:@"" orderBy:@"end_time" orderType:@"desc" withAll:YES];
    if ([self.activityItems count] > 0)
    {
        NSArray *activityArray = [self.activityItems objectAtIndex:0];
        end_time = [[activityArray objectAtIndex:activity_history_end_time] intValue];
    }
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [Common getVersion:OPERAT_ACTIVITY_HISTORY_REFRESH],@"ver",
                                 [NSNumber numberWithInt: 2],@"type",
                                 [NSNumber numberWithInt: end_time],@"end_time",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_ACTIVITY_HISTORY_REFRESH
								  accessAdress:reqUrl
									  delegate:self
									 withParam:nil];
}

//网络获取更多数据
-(void)accessMoreService
{
    NSString *reqUrl = @"activitylist.do?param=%@";
    
    //取本地最后一条记录end_time
    int end_time = 0;
    if ([self.activityItems count] > 0)
    {
        NSArray *activityArray = [self.activityItems objectAtIndex:([self.activityItems count] - 1)];
        end_time = [[activityArray objectAtIndex:activity_history_end_time] intValue];
    }
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: -1],@"ver",
                                 [NSNumber numberWithInt: 2],@"type",
                                 [NSNumber numberWithInt: end_time],@"end_time",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_ACTIVITY_HISTORY_MORE
								  accessAdress:reqUrl
									  delegate:self
									 withParam:nil];
}

//回归常态
-(void)backNormal
{
    //移出loading
    [self.spinner removeFromSuperview];
}

//更多回归常态
-(void)moreBackNormal
{
    _loadingMore = NO;
    
	//loading图标移除
	if (self.spinner != nil) {
		[self.spinner stopAnimating];
	}
    
	if (self.moreLabel) {
        self.moreLabel.text = @"上拉加载更多";
    }
	
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch(commandid)
    {
        //刷新
        case OPERAT_ACTIVITY_HISTORY_REFRESH:
            [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
            break;
            
        //更多
        case OPERAT_ACTIVITY_HISTORY_MORE:
            [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
            break;
            
        default:   ;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.activityItems count] >= 10)
    {
        return [self.activityItems count] + 1;
    }
    else
    {
        if ([self.activityItems count] == 0)
        {
            return 1;
        }
        else
        {
            return [self.activityItems count];
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activityItems != nil && [self.activityItems count] > 0)
    {
        if ([indexPath row] == [self.activityItems count])
        {
            //更多
            return 50.0f;
        }
        else
        {
            //记录 180 + 10
            return 190.0f;
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
	
	int activityItemsCount =  [self.activityItems count];
    int cellType;
    if (self.activityItems != nil && activityItemsCount > 0)
    {
        if ([indexPath row] == activityItemsCount)
        {
            //更多
            CellIdentifier = @"moreCell";
            cellType = 1;
        }
        else
        {
            //记录
            CellIdentifier = @"listCell";
            cellType = 2;
        }
    }
    else
    {
        //没有记录
        CellIdentifier = @"noneCell";
        cellType = 0;
    }
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
        switch(cellType)
		{
            //没有记录
			case 0:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                self.myTableView.separatorColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
				noneLabel.tag = 101;
				[noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
				noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
				noneLabel.text = @"没有往期活动！";
				noneLabel.textAlignment = UITextAlignmentCenter;
				noneLabel.backgroundColor = [UIColor clearColor];
				[cell.contentView addSubview:noneLabel];
				[noneLabel release];
                
                break;
            }
            //更多
			case 1:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                self.myTableView.separatorColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
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
                break;
            }
            //记录
			case 2:
            {
                cell = [[[activityCellViewController alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                break;
            }
				
			default:   ;
		}
        
        cell.backgroundColor = [UIColor clearColor];
	}
	
	if (cellType == 2)
    {
        //数据填充
        NSArray *activityArray = [self.activityItems objectAtIndex:[indexPath row]];
        
        activityCellViewController *activityCell = (activityCellViewController *)cell;
        
        //标题
        activityCell.titleLabel.text = [activityArray objectAtIndex:activity_history_title];
        
        //主办单位
        activityCell.companyLabel.text = [activityArray objectAtIndex:activity_history_organizer];
        
        //时间
        activityCell.timeLabel.text = [Common getFriendDate:[[activityArray objectAtIndex:activity_history_begin_time] intValue] eTime:[[activityArray objectAtIndex:activity_history_end_time] intValue]];;
        
        //地址
        activityCell.addressLabel.text = [activityArray objectAtIndex:activity_history_address];
        
        //感兴趣
        activityCell.interestLabel.text = [NSString stringWithFormat:@"感兴趣 %@",[activityArray objectAtIndex:activity_history_interests]];
        
        //状态
        activityCell.statusLabel.text = @"已结束...";
        
        //图片
        NSString *picUrl = [activityArray objectAtIndex:activity_history_pic];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2)
            {
                activityCell.picView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
                activityCell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                
				if (tableView.dragging == NO && tableView.decelerating == NO)
				{
                    [activityCell.picView stopSpinner];
                    [activityCell.picView startSpinner];
					[self startIconDownload:picUrl forIndexPath:indexPath];
				}
            }
        }
        else
        {
            UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
            activityCell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
        }
        
        return activityCell;
        
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int countItems = [self.activityItems count];
	
	if (countItems > [indexPath row])
    {
        ProfessionAppDelegate *ProfessionDelegate = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
        activityDetailViewController *activityDetailView = [[activityDetailViewController alloc] init];
        
        NSArray *activityArray = [self.activityItems objectAtIndex:[indexPath row]];
        activityDetailView.activityArray = activityArray;
        
        //活动图片处理
        if ([[activityArray objectAtIndex:activity_history_pics] isKindOfClass:[NSMutableArray class]])
        {
            activityDetailView.picArray = [activityArray objectAtIndex:activity_history_pics];
        }
        else
        {
            activityDetailView.picArray = [DBOperate queryData:T_ACTIVITY_HISTORY_PIC
                                                     theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_history_id] orderBy:@"id" orderType:@"asc" withAll:NO];
        }
        
        //用户图片处理
        if ([[activityArray objectAtIndex:activity_history_user_pics] isKindOfClass:[NSMutableArray class]])
        {
            activityDetailView.userPicArray = [activityArray objectAtIndex:activity_history_user_pics];
        }
        else
        {
            activityDetailView.userPicArray = [DBOperate queryData:T_ACTIVITY_HISTORY_USER_PIC
                                                         theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_history_id] orderBy:@"id" orderType:@"desc" withAll:NO];
        }
        
        [ProfessionDelegate.navController pushViewController:activityDetailView animated:YES];
        [activityDetailView release];
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
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
            
            //数据
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.activityItems count] >= 10)
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

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
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
    
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.activityItems = nil;
	self.spinner = nil;
    self.moreLabel = nil;
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
}


- (void)dealloc {
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.activityItems= nil;
	self.spinner = nil;
    self.moreLabel = nil;
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    [super dealloc];
}

@end
