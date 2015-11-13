//
//  demandRecommendViewController.m
//  Profession
//
//  Created by lai yun on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "demandRecommendViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "UIImageScale.h"
#import "demandDetailViewController.h"

#define MARGIN 5.0f

@implementation demandRecommendViewController

@synthesize myTableView;
@synthesize demandItems;
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
    
    self.title = @"店家求购";
	
	//求购数据初始化
	NSMutableArray *tempDemandArray = [[NSMutableArray alloc] init];
	self.demandItems = tempDemandArray;
	[tempDemandArray release];
    
    [self showDemand];
	
}

//显示求购列表
-(void)showDemand
{
	//从数据库中取出数据 
    self.demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_RECOMMEND theColumn:@"" theColumnValue:@""  withAll:YES];
    
    if ([self.demandItems count] == 0) 
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

//网络获取数据
-(void)accessItemService
{
	NSString *reqUrl = @"recomTrades.do?param=%@";
    NSNumber *ver = [Common getVersion:OPERAT_DEMAND_RECOMMEND_REFRESH];
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 ver,@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: 0],@"updatetime",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_DEMAND_RECOMMEND_REFRESH 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//网络获取更多数据
-(void)accessMoreService:(int)itemUpdateTime
{
	NSString *reqUrl = @"recomTrades.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: -1],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: itemUpdateTime],@"updatetime",
								 nil];
    
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_DEMAND_RECOMMEND_MORE 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//更新求购的操作
-(void)updateDemand;
{
	//从数据库中取出数据 
	self.demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_RECOMMEND theColumn:@"" theColumnValue:@""  withAll:YES];
	
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
                //求购刷新
			case OPERAT_DEMAND_RECOMMEND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
                break;
                
                //求购更多
			case OPERAT_DEMAND_RECOMMEND_MORE:
				[self performSelectorOnMainThread:@selector(appendTableWith:) withObject:resultArray waitUntilDone:NO];
				break;
                
			default:   ;
		}
	}
	else
	{
		switch(commandid)
		{
				//求购刷新
			case OPERAT_DEMAND_RECOMMEND_REFRESH:
				[self performSelectorOnMainThread:@selector(updateDemand) withObject:nil waitUntilDone:NO];
				break;
                
				//求购更多
			case OPERAT_DEMAND_RECOMMEND_MORE:
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
    
    //求购talbeView
    NSMutableArray *items = self.demandItems;
    int countItems = [self.demandItems count];
    
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
        
        NSArray *demandArray = [items objectAtIndex:[indexPath row]];
        
        [demandTitle setFrame:CGRectMake(MARGIN * 2 , MARGIN, cell.frame.size.width-6 * MARGIN, 20)];
        
        [detailTitle setFrame:CGRectMake(MARGIN * 2 , MARGIN * 5, cell.frame.size.width-6 * MARGIN, 40)];
        
        demandTitle.text = [demandArray objectAtIndex:demand_title];
        detailTitle.text = [demandArray objectAtIndex:demand_desc];
        
    }
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
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
            [self accessMoreService:updateTime];
            
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
            
            //取对应图片
            NSMutableArray *demandPicArray = (NSMutableArray *)[DBOperate queryData:T_DEMAND_PIC_RECOMMEND theColumn:@"demand_id" theColumnValue:demandID  withAll:NO];
            
            demandDetail.demandPicArray = demandPicArray;
            
            [self.navigationController pushViewController:demandDetail animated:YES];
            [demandDetail release];
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
            NSArray *demandArray = [self.demandItems objectAtIndex:[self.demandItems count]-1];
            int updateTime = [[demandArray objectAtIndex:demand_update_time] intValue];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.demandItems count] >= 20)
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
    self.demandItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	self.spinner = nil;
    self.moreLabel = nil;
}


- (void)dealloc {
	self.demandItems = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
	_refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
	self.spinner = nil;
    self.moreLabel = nil;
    [super dealloc];
}


@end

