    //
//  BuyViewController.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BuyViewController.h"
#import "BuyCell.h"
#import "Encry.h"
#import "Common.h"
#import "DataManager.h"
#import "DBOperate.h"
#import "demandDetailViewController.h"

#define kHeightForRow 60.0f

@implementation BuyViewController
@synthesize buyTableView = _buyTableView;
@synthesize listArray = __listArray;
@synthesize userIdStr;
@synthesize rowValue;
@synthesize spinner;
@synthesize moreLabel;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)init{
    self = [super init];
    if (self) {
        __listArray = [[NSMutableArray alloc] init];
		
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"求购收藏";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
	progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	progressHUD.delegate = self;
	progressHUD.labelText = LOADING_TIPS;
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	[self accessService];
	
	_buyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	_buyTableView.delegate = self;
	_buyTableView.dataSource = self;
	//_buyTableView.rowHeight = kHeightForRow;
	[_buyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_buyTableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:_buyTableView];
	
	//下拉刷新控件
	//if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
//										   initWithFrame:CGRectMake(0.0f, 0.0f - _buyTableView.bounds.size.height, self.view.frame.size.width, _buyTableView.bounds.size.height)];
//		view.delegate = self;
//		[_buyTableView addSubview:view];
//		_refreshHeaderView = view;
//		[view release];
//		
//	}
//	[_refreshHeaderView refreshLastUpdatedDate];
	
	self.userIdStr = [NSString stringWithFormat:@"%d",[[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue]];
	
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
}


- (void)dealloc {      
	
	[_buyTableView release];
	_buyTableView = nil;
	[__listArray release];
	__listArray = nil;
	[progressHUD release];
	progressHUD = nil;
	[_refreshHeaderView release];
	_refreshHeaderView = nil;
	[userIdStr release];
	userIdStr = nil;
    [spinner release];
	spinner = nil;
    [moreLabel release];
    moreLabel = nil;
    [super dealloc];
}

#pragma mark - UITableView delegate
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
		return 72.0f;
	}else {
		return 0;
	}	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1)
    {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UILabel *tempMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 30)];
        tempMoreLabel.tag = 200;
        [tempMoreLabel setFont:[UIFont systemFontOfSize:14.0f]];
        tempMoreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
        tempMoreLabel.text = _loadingMore ? @"没有更多数据了" : @"上拉加载更多";
        tempMoreLabel.textAlignment = UITextAlignmentCenter;
        tempMoreLabel.backgroundColor = [UIColor clearColor];
        self.moreLabel = tempMoreLabel;
        [tempMoreLabel release];
		[vv addSubview:self.moreLabel];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.backgroundColor = [UIColor clearColor];
		btn.frame = CGRectMake(0, 0, 320, 50);
		[btn addTarget:self action:@selector(getMoreAction) forControlEvents:UIControlEventTouchUpInside];
		[vv addSubview:btn];
        
        //添加loading图标
        UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [tempSpinner setCenter:CGPointMake(vv.frame.size.width / 3, vv.frame.size.height / 2.0)];
        self.spinner = tempSpinner;
        [vv addSubview:self.spinner];
        [tempSpinner release];
		
		return vv;
        
	}
    else
    {
		return nil;		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 1 && self.listArray.count >= 20) {
		return 50;
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	//NSInteger row = [indexPath row];
	
	BuyCell *cell = (BuyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[BuyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
				
		cell.cTitle.text = @"";
		cell.cContact.text = @"";
		cell.cContent.text = @"";
        
    }
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *cellArray = [self.listArray objectAtIndex:indexPath.row];
		cell.cTitle.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:demand_favorite_title]];
		cell.cContact.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:demand_favorite_contact]];
		cell.cContent.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:demand_favorite_desc]];
		
		if ([[cellArray objectAtIndex:demand_favorite_recommend] intValue] == 1)
		{
			cell.recommendImageView.hidden = NO;
		}
		else 
		{
			cell.recommendImageView.hidden = YES;
		}
	}
	//cell.backgroundColor = [UIColor colorWithRed:0.935 green:0.935 blue:0.935 alpha:1.0f];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *demandArray = [[NSMutableArray alloc] initWithArray:[self.listArray objectAtIndex:[indexPath row]]];
	NSString *demandID = [demandArray objectAtIndex:demand_favorite_demand_id];
	
	demandDetailViewController *demandDetail = [[demandDetailViewController alloc] init];			
	demandDetail.demandID = demandID;
    demandDetail.commentTotal = [demandArray objectAtIndex:demand_favorite_commentTotal];
    demandDetail.isFrom = NO;
	
	[demandArray removeObjectAtIndex:0];
	[demandArray removeObjectAtIndex:0];
	[demandArray removeObjectAtIndex:1];
	[demandArray addObject:@""];
	NSMutableArray *demandInfoArray = [[NSMutableArray alloc] init];
	[demandInfoArray addObject:demandArray];
	demandDetail.demandArray = demandInfoArray;
	[demandInfoArray release];
	
	NSMutableArray *picArray = (NSMutableArray *)[DBOperate queryData:T_DEMAND_PIC_FAVORITE theColumn:@"demand_id" theColumnValue:demandID withAll:NO];
	NSMutableArray *allPic = [[NSMutableArray alloc] init];
	for (int i = 0; i < [picArray count]; i ++) {
		NSMutableArray *array = [picArray objectAtIndex:i];
		[array removeObjectAtIndex:2];
		[allPic addObject:array];
	}
	
	demandDetail.demandPicArray = allPic;
	[allPic release];

	[self.navigationController pushViewController:demandDetail animated:YES];
	[demandDetail release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	rowValue = indexPath.row;
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	_listId = [[self.listArray objectAtIndex:indexPath.row] objectAtIndex:demand_favorite_demand_id];
	//NSLog(@"_listId=======%d",[_listId intValue]);
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:4],@"type",
										[NSNumber numberWithInt:[_listId intValue]],@"info_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEDELETE_COMMAND_ID accessAdress:@"/member/delfavorite.do?param=%@" delegate:self withParam:jsontestDic];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return UITableViewCellEditingStyleDelete; 
} 

//ios7去掉cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{	
	_reloading = YES;	
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_buyTableView];
	
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	//	[self accessService];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed	
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
            [self getMoreAction];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.buyTableView.frame.size.height && [self.listArray count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
    
}


#pragma mark ----private methods
- (void)accessService
{
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getMemberVersion:_userId commandID:MEMBER_FAVORITEBUYLIST_COMMAND_ID],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt:_userId],@"user_id",
								 [NSNumber numberWithInt:4],@"type",
								 [NSNumber numberWithInt:0],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEBUYLIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void) accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:demand_favorite_favoriteId] intValue];
	
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt:-1 ],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:4],@"type",
										[NSNumber numberWithInt:lastId],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEBUYMORELIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];	
	
}

- (void)getMoreAction
{
    
    _loadingMore = YES;
    
	self.moreLabel.text=@" 加载中 ...";
	
    [self.spinner startAnimating];
    
	[self accessMoreService];
	
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case MEMBER_FAVORITEBUYLIST_COMMAND_ID:
		{
			if (ver == NEED_UPDATE ) {
				[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
			}
		}
			break;
		case MEMBER_FAVORITEDELETE_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(deleteResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
		case MEMBER_FAVORITEBUYMORELIST_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;	
		default:
			break;
	}
	
}

- (void)update
{
	self.listArray = (NSMutableArray *)[DBOperate queryData:T_DEMAND_FAVORITE theColumn:@"user_id" theColumnValue:self.userIdStr  withAll:NO];
	
	//NSLog(@"self.listArray========%@",self.listArray);
	//NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	
	if ([self.listArray count] == 0) {
		self.buyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = @"当前没有求购收藏数据";
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14.0f];
		[self.view addSubview:label];
		[label release];
	}
	
	[_buyTableView reloadData];
	
	if (progressHUD != nil) {
		if (progressHUD) {
			[progressHUD removeFromSuperview];
		}
	}
}

- (void)deleteResult:(NSMutableArray *)resultArray
{
	int retInt = [[[resultArray objectAtIndex:0] objectAtIndex:0] intValue];
	if (retInt == 1) {
		[DBOperate deleteData:T_DEMAND_FAVORITE tableColumn:@"demand_id" columnValue:_listId];
        [DBOperate deleteData:T_DEMAND_PIC_FAVORITE tableColumn:@"demand_id" columnValue:_listId];
		[self.listArray removeObjectAtIndex:rowValue];
            
		[self.buyTableView reloadData];
		
		if ([self.listArray count] == 0) {
			self.buyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
			label.text = @"当前没有求购收藏数据";
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor grayColor];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:14.0f];
			[self.view addSubview:label];
			[label release];
		}
	}else {
		MBProgressHUD *mbprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		mbprogressHUD.delegate = self;
		mbprogressHUD.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		mbprogressHUD.mode = MBProgressHUDModeCustomView; 
		mbprogressHUD.labelText = @"删除失败";
		[self.view addSubview:mbprogressHUD];
		[self.view bringSubviewToFront:mbprogressHUD];
		[mbprogressHUD show:YES];
		[mbprogressHUD hide:YES afterDelay:1];
		[mbprogressHUD release];
	}
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    //loading图标移除
    if (self.spinner != nil) {
        [self.spinner stopAnimating];
    }
    
    if ([resultArray count] > 0)
    {
        for (int i = 0; i < [resultArray count];i++ )
        {
            NSMutableArray *item = [resultArray objectAtIndex:i];
            [item insertObject:@"" atIndex:0];
            [self.listArray addObject:item];
        }
        
        [self.buyTableView reloadData];
        
        if ([resultArray count] >= 20)
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
        
    }
    else
    {
        if (self.moreLabel) {
            self.moreLabel.text = @"没有更多数据了";
        }
    }
	
}
@end
