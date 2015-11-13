//
//  MyActivityViewController.m
//  xieHui
//
//  Created by LuoHui on 13-4-24.
//
//

#import "MyActivityViewController.h"
#import "DBOperate.h"
#import "Common.h"
#import "DataManager.h"
#import "activityMainViewController.h"
#import "activityCellViewController.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "activityDetailViewController.h"
#import "CustomTabBar.h"
#import "tabEntranceViewController.h"

@interface MyActivityViewController ()

@end

@implementation MyActivityViewController
@synthesize myTableView = _myTableView;
@synthesize listArray = __listArray;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"我的活动";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
    
    picWidth = 100.0f;
    picHeight = 75.0f;
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
    //-----没有活动
    noItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:noItemView];
    noItemView.hidden = YES;
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 30)];
	strLabel.text = @"您还没有参加过任何活动哦！";
    strLabel.textColor = [UIColor grayColor];
	strLabel.font = [UIFont systemFontOfSize:16.0f];
	strLabel.tag = 100;
	strLabel.textAlignment = UITextAlignmentCenter;
	strLabel.backgroundColor = [UIColor clearColor];
	[noItemView addSubview:strLabel];
	[strLabel release];
    
    UIImage *btnImage = [UIImage imageNamed:@"button_green.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((320 - 230) * 0.5, CGRectGetMaxY(strLabel.frame) + 50, 230, 50);
    [btn setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showActivity) forControlEvents:UIControlEventTouchUpInside];
    [noItemView addSubview:btn];
    
    UILabel *btnStr = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, btn.frame.size.width, 30)];
    btnStr.backgroundColor = [UIColor clearColor];
    btnStr.text = @"查看近期活动";
    btnStr.textAlignment = UITextAlignmentCenter;
    btnStr.textColor = [UIColor whiteColor];
    btnStr.font = [UIFont systemFontOfSize:16];
    [btn addSubview:btnStr];
    [btnStr release];
    
    //-----有参加的活动
    haveItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:haveItemView];
    haveItemView.hidden = YES;
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 320, self.view.frame.size.height - 54)];
    _myTableView.delegate = self;
	_myTableView.dataSource = self;
	[_myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_myTableView setBackgroundColor:[UIColor clearColor]];
	[haveItemView addSubview:_myTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self accessService];
}

- (void)dealloc
{
    [_myTableView release];
    [__listArray release];
    [spinner release];
    [noItemView release];
    [haveItemView release];
    [indicatorView release];
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	[self.imageDownloadsInProgressDic release];
	[self.imageDownloadsInWaitingArray release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _myTableView = nil;
    __listArray = nil;
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgressDic = nil;
	self.imageDownloadsInWaitingArray = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [self.listArray count];
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) {
		return 190.0f;
	}else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];
		moreLabel.text = @"上拉加载更多";
		moreLabel.tag = 200;
        moreLabel.font = [UIFont systemFontOfSize:14.0f];
		moreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
		moreLabel.textAlignment = UITextAlignmentCenter;
		moreLabel.backgroundColor = [UIColor clearColor];
		[vv addSubview:moreLabel];
		[moreLabel release];
		
		//添加loading图标
		indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
		[indicatorView setCenter:CGPointMake(320 / 3, 40 / 2.0)];
		indicatorView.hidesWhenStopped = YES;
		[vv addSubview:indicatorView];
		
		return vv;
	}else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 1 && self.listArray.count >= 20) {
		return 40;
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	//NSInteger row = [indexPath row];
	
	activityCellViewController *cell = (activityCellViewController *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[activityCellViewController alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.titleLabel.text = @"";
        cell.companyLabel.text = @"";
		cell.timeLabel.text = @"";
		cell.addressLabel.text = @"";
        cell.interestLabel.text = @"";
        cell.statusLabel.text = @"";
    }
    if ([self.listArray count] > 0 && indexPath.row < [self.listArray count]) {
        NSArray *activityArray = [self.listArray objectAtIndex:[indexPath row]];
        //标题
        cell.titleLabel.text = [activityArray objectAtIndex:my_activity_title];
        
        //主办单位
        cell.companyLabel.text = [activityArray objectAtIndex:my_activity_organizer];
        
        //时间
        cell.timeLabel.text = [self getFriendDate:[[activityArray objectAtIndex:my_activity_begin_time] intValue] eTime:[[activityArray objectAtIndex:my_activity_end_time] intValue]];;
        
        //地址
        cell.addressLabel.text = [activityArray objectAtIndex:my_activity_address];
        
        //感兴趣
        cell.interestLabel.text = [NSString stringWithFormat:@"感兴趣 %@",[activityArray objectAtIndex:my_activity_interests]];
        
        //判断活动状态
        NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
        long long int currentTime = (long long int)cTime;
        NSString *statusString = @"";
        if ([[activityArray objectAtIndex:my_activity_reg_end_time] intValue] >= currentTime)
        {
            statusString = @"报名中...";
        }
        else
        {
            int startTime = [[activityArray objectAtIndex:my_activity_begin_time] intValue];
            int endTime = [[activityArray objectAtIndex:my_activity_end_time] intValue];
            if (startTime > currentTime)
            {
                //即将开始
                statusString = @"即将开始...";
            }
            else if(startTime <= currentTime && endTime > currentTime)
            {
                //正在进行
                statusString = @"活动中...";
            }
            else
            {
                //已结束
                statusString = @"已结束...";
            }
        }
        cell.statusLabel.text = statusString;
        
        //图片
        NSString *picUrl = [activityArray objectAtIndex:my_activity_pic];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2)
            {
                cell.picView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
                cell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                
				if (tableView.dragging == NO && tableView.decelerating == NO)
				{
                    [cell.picView stopSpinner];
                    [cell.picView startSpinner];
					[self startIconDownload:picUrl forIndexPath:indexPath];
				}
            }
        }
        else
        {
            UIImage *defaultPic = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_S" ofType:@"png"]];
            cell.picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    activityDetailViewController *activityDetailView = [[activityDetailViewController alloc] init];
    
    NSArray *activityArray = [self.listArray objectAtIndex:[indexPath row]];
    activityDetailView.activityArray = activityArray;
    
    //活动图片处理
    if ([[activityArray objectAtIndex:my_activity_pics] isKindOfClass:[NSMutableArray class]])
    {
        activityDetailView.picArray = [activityArray objectAtIndex:my_activity_pics];
    }
    
    //用户图片处理
    if ([[activityArray objectAtIndex:my_activity_user_pics] isKindOfClass:[NSMutableArray class]])
    {
        activityDetailView.userPicArray = [activityArray objectAtIndex:my_activity_user_pics];
    }
    
    [self.navigationController pushViewController:activityDetailView animated:YES];
    [activityDetailView release];
}


//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
    
	for (NSIndexPath *indexPath in visiblePaths)
	{
		int countItems = [self.listArray count];
		if (countItems >[indexPath row])
		{
            NSArray *activityArray = [self.listArray objectAtIndex:[indexPath row]];
            
            activityCellViewController *activityCell = (activityCellViewController *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
            //图片
            NSString *picUrl = [activityArray objectAtIndex:my_activity_pic];
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
    int countItems = [self.listArray count];
	
	if (countItems > [indexPath row])
	{
		NSArray *activityArray = [self.listArray objectAtIndex:[indexPath row]];
        NSString *picUrl = [activityArray objectAtIndex:my_activity_pic];
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
    IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:indexPath];
    if (iconDownloader == nil && photoURL != nil && photoURL.length > 1)
    {
		if ([imageDownloadsInProgressDic count]>= 5) {
			imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:photoURL withIndexPath:indexPath withImageType:CUSTOMER_PHOTO];
			[imageDownloadsInWaitingArray addObject:one];
			[one release];
			return;
		}
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = photoURL;
        iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.imageType = CUSTOMER_PHOTO;
        iconDownloader.delegate = self;
        [imageDownloadsInProgressDic setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:indexPath];
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
		
		[imageDownloadsInProgressDic removeObjectForKey:indexPath];
		if ([imageDownloadsInWaitingArray count]>0)
		{
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaitingArray objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndexPath:one.indexPath];
			[imageDownloadsInWaitingArray removeObjectAtIndex:0];
		}
    }
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isAllowLoadingMore && !_loadingMore && [self.listArray count] > 0)
    {
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            label.text=@"松开加载更多";
        }
        else
        {
            label.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    if (!decelerate)
	{
		[self loadImagesForOnscreenRows];
    }
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            label.text=@" 加载中 ...";
            [indicatorView startAnimating];
            
            //数据
            [self accessMoreService];
        }
        else
        {
            label.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.listArray count] >= 20)
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

#pragma mark ----private method
- (void)accessService
{
    //添加loading图标
    UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f - 20.0f) / 2.0)];
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
    
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MYACTIVITY_LIST_COMMAND_ID accessAdress:@"member/joinactivitylist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectAtIndex:my_activity_join_time] intValue];
    //NSLog(@"lastId===%d",lastId);
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        [NSNumber numberWithInt:lastId],@"join_time",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MYACTIVITY_LIST_MORE_COMMAND_ID accessAdress:@"member/joinactivitylist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	//NSLog(@"=====%@",resultArray);
	switch (commandid) {
		case MYACTIVITY_LIST_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
		}
			break;
		case MYACTIVITY_LIST_MORE_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
        default:
			break;
	}
}

- (void)update:(NSMutableArray *)resultArray
{
    //移出loading
    [self.spinner removeFromSuperview];
    
    //NSLog(@"resultArray ========%@",resultArray);
	if ([resultArray count] == 0) {
		noItemView.hidden = NO;
        haveItemView.hidden = YES;
	}else {
        noItemView.hidden = YES;
        haveItemView.hidden = NO;
        
        self.listArray = resultArray;
        
        [self.myTableView reloadData];
    }	
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
	label.text = @"上拉加载更多";
	[indicatorView stopAnimating];
    
    _loadingMore = NO;
    
    if ([resultArray count] > 0)
    {
        int oldCount = [self.listArray count];
        
        //填充数组
        for (int i = 0; i < [resultArray count];i++ )
        {
            NSMutableArray *item = [resultArray objectAtIndex:i];
            [self.listArray addObject:item];
        }
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
        NSMutableArray *reloadIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
		for (int ind = 0; ind < [resultArray count]; ind++)
		{
			NSIndexPath *insertNewPath = [NSIndexPath indexPathForRow:(oldCount + ind) inSection:0];
			[insertIndexPaths insertObject:insertNewPath atIndex:0];
            
            NSIndexPath *reloadNewPath = [NSIndexPath indexPathForRow:ind inSection:0];
			[reloadIndexPaths insertObject:reloadNewPath atIndex:0];
		}
        
		[self.myTableView insertRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self.myTableView reloadRowsAtIndexPaths:reloadIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

//转换友好的时间格式
-(NSString *)getFriendDate:(int)startTime eTime:(int)endTime
{
    //当前时间
    //NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    //long long int currentTime = (long long int)cTime;
    NSString *dateString =@"";
    NSDate* currentDate = [NSDate date];
    
    //开始时间
    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    
    //当前年
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"yyyy"];
    NSString *currentYear = [outputFormat stringFromDate:currentDate];
    NSString *startYear = [outputFormat stringFromDate:startDate];
    
    //判断开始时间是否与当前年同年
    if ([currentYear isEqualToString:startYear])
    {
        //判断开始年跟结束年是否同年
        NSString *endYear = [outputFormat stringFromDate:endDate];
        if (([startYear isEqualToString:endYear]))
        {
            //判断是否同一天
            [outputFormat setDateFormat:@"MM/dd"];
            NSString *startMonthAndDay = [outputFormat stringFromDate:startDate];
            NSString *endMonthAndDay = [outputFormat stringFromDate:endDate];
            if (([startMonthAndDay isEqualToString:endMonthAndDay]))
            {
                //eg: 04/28 18:00 至 18:30
                [outputFormat setDateFormat:@"MM/dd HH:mm"];
                NSString *startDateString = [outputFormat stringFromDate:startDate];
                [outputFormat setDateFormat:@"HH:mm"];
                NSString *endDateString = [outputFormat stringFromDate:endDate];
                dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
            }
            else
            {
                //eg: 04/28 18:00 至 04/29 12:30
                [outputFormat setDateFormat:@"MM/dd HH:mm"];
                NSString *startDateString = [outputFormat stringFromDate:startDate];
                NSString *endDateString = [outputFormat stringFromDate:endDate];
                dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
            }
        }
        else
        {
            //eg: 12/28 18:00 至 2014/01/03 18:30
            [outputFormat setDateFormat:@"MM/dd HH:mm"];
            NSString *startDateString = [outputFormat stringFromDate:startDate];
            [outputFormat setDateFormat:@"yyyy/MM/dd HH:mm"];
            NSString *endDateString = [outputFormat stringFromDate:endDate];
            dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
        }
    }
    else
    {
        //eg: 2012/01/01 18:00 至 2012/01/01 18:30
        [outputFormat setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *startDateString = [outputFormat stringFromDate:startDate];
        NSString *endDateString = [outputFormat stringFromDate:endDate];
        dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
    }
    [outputFormat release];
    
    
    return dateString;
}

- (void)showActivity
{
    activityMainViewController * activityMainView = [[activityMainViewController alloc] init];
    [self.navigationController pushViewController:activityMainView animated:YES];
    [activityMainView release];
//    NSArray *arrayViewControllers = self.navigationController.viewControllers;
//    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
//    {
//        CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
//        tabViewController.selectedIndex = 0;
//        
//        UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90000];
//        [tabViewController selectedTab:btn];
//    }
//    else
//    {
//        tabEntranceViewController *tabViewController = [arrayViewControllers objectAtIndex:0];
//        tabViewController.selectedIndex = 0;
//        
//        [tabViewController tabBarController:tabViewController didSelectViewController:tabViewController.selectedViewController];
//    }
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
@end
