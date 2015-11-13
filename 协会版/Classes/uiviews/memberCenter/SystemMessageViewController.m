//
//  SystemMessageViewController.m
//  xieHui
//
//  Created by LuoHui on 13-4-27.
//
//

#import "SystemMessageViewController.h"
#import "Common.h"
#import "DataManager.h"
#import "Encry.h"
#import "Common.h"
#import "UIImageScale.h"
#import <QuartzCore/QuartzCore.h>
#import "browserViewController.h"
@interface SystemMessageViewController ()

@end

@implementation SystemMessageViewController
@synthesize tableView = _tableView;
@synthesize listArray = __listArray;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
    self.title = @"小秘书";
    
    [self accessService];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = YES;
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_tableView];
    
    //下拉刷新控件
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]
										   initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
    _isLoadMore = NO;
}

- (void)dealloc
{
//    [_tableView release];
//    [__listArray release];
//    [spinner release];
//    [indicatorView release];
//    [_refreshHeaderView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self accessMoreService];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
		return [self.listArray count];
        //return 20;
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) {
		//return 80.0f;
        if (self.listArray != nil && [self.listArray count] > 0) {
            NSArray *commentArray = [self.listArray objectAtIndex:[indexPath row]];
			NSString *text = [commentArray objectAtIndex:systemMessage_content];
			float length = text.length * 20;
            float width = length > 200 ? 200 : length;
            CGSize titleSize = [text sizeWithFont:[UIFont systemFontOfSize:16]
                                constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                    lineBreakMode:UILineBreakModeWordWrap];
            //35为气泡上下间隔,40为头像高度 30为时间高度
            CGFloat height = (titleSize.height + 20) > 40 ? titleSize.height + 20 : 40;
			return height + 30 + 35;
        }else {
            return 0;
        }
	}else {
		return 0;
	}
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	if (section == 1) {
//		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//        UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
//		UIImageView *separatorImageView = [[UIImageView alloc] init];
//		[separatorImageView setFrame:CGRectMake(0, 0, 320, separatorImage.size.height)];
//		[separatorImageView setImage:separatorImage];
//		[vv addSubview:separatorImageView];
//		[separatorImageView release];
//
//		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(separatorImageView.frame), 320, 50)];
//		moreLabel.text = @"显示更多";
//		moreLabel.tag = 200;
//		moreLabel.textColor = [UIColor blackColor];
//		moreLabel.textAlignment = UITextAlignmentCenter;
//		moreLabel.backgroundColor = [UIColor clearColor];
//		[vv addSubview:moreLabel];
//		[moreLabel release];
//
//		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//		btn.backgroundColor = [UIColor clearColor];
//		btn.frame = CGRectMake(0, 0, 320, 50);
//		[btn addTarget:self action:@selector(getMoreAction) forControlEvents:UIControlEventTouchUpInside];
//		[vv addSubview:btn];
//
//		//添加loading图标
//		indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
//		[indicatorView setCenter:CGPointMake(320 / 3, 50 / 2.0)];
//		indicatorView.hidesWhenStopped = YES;
//		[vv addSubview:indicatorView];
//
//		UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 49, 320, 1)];
//		lab.backgroundColor = [UIColor grayColor];
//
//		[vv addSubview:lab];
//		[lab release];
//		return vv;
//	}else {
//		return nil;
//	}
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	if (section == 1 && self.listArray.count >= 20) {
//		return 50;
//	}else {
//		return 0;
//	}
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell = nil;
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] init];
        view.userInteractionEnabled = YES;
        view.tag = 'v';
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 'i';
        [view addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectZero;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 'l';
        label.textAlignment = UITextAlignmentLeft;
        [view addSubview:label];
        [label release];
        
        UILabel *strLabel = [[UILabel alloc] init];
        strLabel.text = @"";
        strLabel.textColor = [UIColor blueColor];
        strLabel.tag = 11;
        strLabel.font = [UIFont systemFontOfSize:16.0f];
        strLabel.textAlignment = UITextAlignmentLeft;
        strLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:strLabel];
        [strLabel release];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(didShow:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = indexPath.row + 10000;
        [view addSubview:btn];
        
        [cell.contentView addSubview:view];
        [view release];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.tag = 1;
        timeLabel.font = [UIFont systemFontOfSize:14.0f];
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
    }
    
    if (self.listArray != nil && [self.listArray count] > 0)
    {
        UILabel *time = (UILabel *)[cell.contentView viewWithTag:1];
        int createTime = [[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:systemMessage_created] intValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
        [outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *dateString = [outputFormat stringFromDate:date];
        time.text = dateString;
        [outputFormat release];
        
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:'l'];
        label.text = [NSString stringWithFormat:@"%@",[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:systemMessage_content]];
        float length = label.text.length * 20;
        float width = length > 200 ? 200 : length;
        
        CGSize titleSize = [label.text sizeWithFont:[UIFont systemFontOfSize:16]
                                  constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                      lineBreakMode:UILineBreakModeWordWrap];
        label.frame = CGRectMake(15, 10, titleSize.width, titleSize.height);
        
        UILabel *strlabel = (UILabel *)[cell.contentView viewWithTag:11];
        strlabel.frame = CGRectMake(15, CGRectGetMaxY(label.frame), 150, 30);
    
        if ([[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:systemMessage_url] isEqualToString:@""]) {
            strlabel.text = @"了解企业移动APP";
            
            titleSize.width = titleSize.width < 60 ? 120 : titleSize.width;
        }else {
            strlabel.text = @"阅读原文";
            
            titleSize.width = titleSize.width < 60 ? 70 : titleSize.width;
        }
        
        UIView *view = (UIView *)[cell.contentView viewWithTag:'v'];
        view.frame = CGRectMake(70, 30,  titleSize.width+20, titleSize.height+10 + 25);
        
        UIButton *button = (UIButton *)[view viewWithTag:indexPath.row + 10000];
        button.frame = CGRectMake(15, CGRectGetMaxY(label.frame), titleSize.width, 30);
        
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 50, 50)];
        headerImageView.tag = 'a';
        [cell.contentView addSubview:headerImageView];
        headerImageView.layer.masksToBounds = YES;
        headerImageView.layer.cornerRadius = 6;
        
        UIImage *headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_小秘书" ofType:@"png"]];
        headerImageView.image = [headerImage fillSize:CGSizeMake(50, 50)];
        
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:'i'];
        UIImage *balloonImg = [UIImage imageNamed:@"balloon_l.png"];;
        
        balloonImg = [balloonImg stretchableImageWithLeftCapWidth:10 topCapHeight:25];
        imgView.frame = CGRectMake(0, 0, titleSize.width+25, titleSize.height+20 + 25);
        imgView.image = balloonImg;
    }
    return cell;
}

#pragma mark -----private method
- (void)accessService
{
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
    
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [Common getMemberVersion:_userId commandID:SYSTEM_MESSAGE_COMMAND_ID],@"ver",
                                        [NSNumber numberWithInt:_userId],@"user_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:SYSTEM_MESSAGE_COMMAND_ID accessAdress:@"member/pushlist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:0] objectAtIndex:0] intValue];
    //NSLog(@"lastId===%d",lastId);
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt: -1],@"ver",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        [NSNumber numberWithInt:lastId],@"info_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:SYSTEM_MESSAGE_MORE_COMMAND_ID accessAdress:@"member/pushlist.do?param=%@" delegate:self withParam:jsontestDic];
    
    
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	switch (commandid) {
		case SYSTEM_MESSAGE_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
            
		}break;
        case SYSTEM_MESSAGE_MORE_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}break;
            
		default:
			break;
	}
}

- (void)update:(NSMutableArray *)resultArray
{
    //移出loading
    [self.spinner removeFromSuperview];
    
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    self.listArray = (NSMutableArray *)[DBOperate queryData:T_SYSTEMMESSAGE theColumn:@"user_id" theColumnValue:[NSString stringWithFormat:@"%d",_userId] withAll:NO];
    
	if ([self.listArray count] == 0) {
//		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.tableView.scrollEnabled = NO;
//		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//		label.text = @"您还未跟TA打过招呼哦，快招呼一声！";
//        label.tag = 11;
//		label.backgroundColor = [UIColor clearColor];
//		label.textColor = [UIColor grayColor];
//		label.textAlignment = UITextAlignmentCenter;
//		label.font = [UIFont systemFontOfSize:12.0f];
//		[self.view addSubview:label];
//		[label release];
	}else {
        self.tableView.scrollEnabled = YES;
        UILabel *label = (UILabel *)[self.view viewWithTag:11];
        if (label != nil) {
            [label removeFromSuperview];
        }
    }
    
    [self.tableView reloadData];
    
    //滚动到最后一行
    if ([self.listArray count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    if ([resultArray count] > 0)
    {
        int oldCount = [self.listArray count];
        
        //填充数组
        for (int i = [resultArray count]-1; i >= 0; i--)
        {
            NSMutableArray *item = [resultArray objectAtIndex:i];
            [self.listArray insertObject:item atIndex:0];
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
        
		[self.tableView insertRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadRowsAtIndexPaths:reloadIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    //下拉缩回
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
}


- (void)didShow:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    NSString *url = [[self.listArray objectAtIndex:btn.tag - 10000] objectAtIndex:systemMessage_url];
    
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    if ([url isEqualToString:@""]) {
        browser.url = SHOWAPP_URL;
    }else {
        browser.url = url;
    }
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

@end
