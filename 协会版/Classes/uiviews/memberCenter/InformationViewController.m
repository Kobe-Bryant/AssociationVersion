    //
//  InformationViewController.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InformationViewController.h"
#import "InformationCell.h"
#import "Encry.h"
#import "Common.h"
#import "DataManager.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "NewsDetailViewController.h"

#define kHeightForRow  75.0f

@implementation InformationViewController
@synthesize informationTableView = _informationTableView;
@synthesize listArray = __listArray;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize iconDownLoad;
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
	self.title = FAVORITE_NEWS_NAME;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
	progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	progressHUD.delegate = self;
	progressHUD.labelText = LOADING_TIPS;
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	[self accessService];
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
	
	_informationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	_informationTableView.delegate = self;
	_informationTableView.dataSource = self;
	//_informationTableView.rowHeight = kHeightForRow;
	[_informationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_informationTableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:_informationTableView];
	
	//下拉刷新控件
	//if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
//										   initWithFrame:CGRectMake(0.0f, 0.0f - self.informationTableView.bounds.size.height, self.view.frame.size.width, self.informationTableView.bounds.size.height)];
//		view.delegate = self;
//		[_informationTableView addSubview:view];
//		_refreshHeaderView = view;
//		[view release];
//		
//	}
//	[_refreshHeaderView refreshLastUpdatedDate];
	
	
	_isLoadMore = NO;
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
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	[imageDownloadsInProgressDic release];
	imageDownloadsInProgressDic = nil;
	[imageDownloadsInWaitingArray release];
	imageDownloadsInWaitingArray = nil;
	[iconDownLoad release];
	iconDownLoad = nil;
}


- (void)dealloc {
	[_informationTableView release];
	[__listArray release];
	_informationTableView = nil;
	__listArray = nil;
	for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	[imageDownloadsInProgressDic release];
	imageDownloadsInProgressDic = nil;
	[imageDownloadsInWaitingArray release];
	imageDownloadsInWaitingArray = nil;
	[iconDownLoad release];
	iconDownLoad = nil;
	[progressHUD release];
	progressHUD = nil;
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
	
	InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[InformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
		cell.cTitle.text = @"";
		cell.cContent.text = @"";
		//cell.cTime.text = @"";
		
    }
	//cell.backgroundColor = [UIColor colorWithRed:0.935 green:0.935 blue:0.935 alpha:1.0f];
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *cellArray = [self.listArray objectAtIndex:indexPath.row];
		cell.cTitle.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:favoritenews_title]];
		cell.cContent.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:favoritenews_desc]];
		//cell.cTime.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:favoritenews_created]];
		
		if ([[cellArray objectAtIndex:favoritenews_recommend] intValue] == 1)
		{
			cell.recommendImageView1.hidden = NO;
			cell.recommendImageView2.hidden = YES;
		}
		else 
		{
			if ([[cellArray objectAtIndex:favoritenews_push_time] intValue] != 0) {
				cell.recommendImageView2.hidden = NO;
				cell.recommendImageView1.hidden = YES;
			}
		}
		
		NSString *imageUrl = [cellArray objectAtIndex:favoritenews_opic];
		//NSString *imageUrl = @"http://demo1.3g.yunlai.cn/userfiles/000/000/101/recent_img/112610324.jpg";
		NSString *imageName = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:favoritenews_picName]];		
		UIImage *image = [FileManager getPhoto:imageName];
		if (image != nil) {
			cell.cImageView.image = image;
		}else {
			//xiazai 
			//NSLog(@"imageUrl======%@",imageUrl);
			if (imageUrl.length > 1) {
				[self startIconDownload:imageUrl forIndex:indexPath];
			}
			
		}
	}
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *ay = [[NSMutableArray alloc] initWithArray:[self.listArray objectAtIndex:[indexPath row]]];
	[ay removeObjectAtIndex:0];
	[ay removeObjectAtIndex:0];
	[ay removeObjectAtIndex:1];
	[ay insertObject:@"" atIndex:8];
	
	NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
	detail.detailArray = ay;
    detail.commentTotal = [[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:favoritenews_commentTotal];
    detail.isFrom = NO;
	[self.navigationController pushViewController:detail animated:YES];
	[detail release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    rowValue = indexPath.row;
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	_listId = [[self.listArray objectAtIndex:indexPath.row] objectAtIndex:favoritenews_nid];
	
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:3],@"type",
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
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_informationTableView];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.informationTableView.frame.size.height && [self.listArray count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
    
}

#pragma mark ---- loadImage Method
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:index];
    if (iconDownloader == nil && imageURL != nil && imageURL.length > 1) 
    {
		if (imageURL != nil && imageURL.length > 1) 
		{
			if ([imageDownloadsInProgressDic count] >= DOWNLOAD_IMAGE_MAX_COUNT) {
				imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL withIndexPath:index withImageType:CUSTOMER_PHOTO];
				[imageDownloadsInWaitingArray addObject:one];
				[one release];
				return;
			}
			
			IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
			iconDownloader.downloadURL = imageURL;
			iconDownloader.indexPathInTableView = index;
			iconDownloader.imageType = CUSTOMER_PHOTO;
			iconDownloader.delegate = self;
			[imageDownloadsInProgressDic setObject:iconDownloader forKey:index];
			[iconDownloader startDownload];
			[iconDownloader release];   
		}
	}    
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:indexPath];
	InformationCell *cell = (InformationCell *)[self.informationTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
	
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0){ 			
			UIImage *photo = iconDownloader.cardIcon;
			NSString *photoname = [callSystemApp getCurrentTime];
			if ([FileManager savePhoto:photoname withImage:photo]) {
				
				NSArray *one = [self.listArray objectAtIndex:iconDownloader.indexPathInTableView.row]; 
				NSNumber *value = [one objectAtIndex:favoritenews_nid];
			    [DBOperate updateData:T_FAVORITE_NEWS tableColumn:@"picName" 
						  columnValue:photoname conditionColumn:@"nid" conditionColumnValue:value];	
				if (_isLoadMore == NO) {
					self.listArray = (NSMutableArray *)[DBOperate queryData:T_FAVORITE_NEWS 
																  theColumn:@"user_id" theColumnValue:self.userIdStr withAll:NO];
				}
			}
			cell.cImageView.image = photo;	
		}
		[imageDownloadsInProgressDic removeObjectForKey:indexPath];
		if ([imageDownloadsInWaitingArray count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaitingArray objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaitingArray removeObjectAtIndex:0];
		}		
    }
}

#pragma mark ----private methods
- (void)accessService
{
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getMemberVersion:_userId commandID:MEMBER_FAVORITEINFOLIST_COMMAND_ID],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt:_userId],@"user_id",
								 [NSNumber numberWithInt:3],@"type",
								 [NSNumber numberWithInt:0],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEINFOLIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void) accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:favoriyenews_favoriteId] intValue];
	//NSLog(@"lastId====%d",lastId);
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt:-1],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:3],@"type",
										[NSNumber numberWithInt:lastId],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEINFOMORELIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];}

- (void)getMoreAction
{
    _loadingMore = YES;
    
	self.moreLabel.text=@" 加载中 ...";
	
    [self.spinner startAnimating];
    
    _isLoadMore = YES;
	[self accessMoreService];
	
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case MEMBER_FAVORITEINFOLIST_COMMAND_ID:
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
		case MEMBER_FAVORITEINFOMORELIST_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
			
		default:
			break;
	}
}

- (void)deleteResult:(NSMutableArray *)resultArray
{
    //NSLog(@"===%@",self.listArray);
	int retInt = [[[resultArray objectAtIndex:0] objectAtIndex:0] intValue];
	if (retInt == 1) {
		[DBOperate deleteData:T_FAVORITE_NEWS tableColumn:@"nid" columnValue:_listId];
		[self.listArray removeObjectAtIndex:rowValue];

		[self.informationTableView reloadData];
		
		if ([self.listArray count] == 0) {
			self.informationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
			label.text = TIPS_NONE_FAVORITE_NEWS_CONTENT;
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
- (void)update
{
	self.listArray = (NSMutableArray *)[DBOperate queryData:T_FAVORITE_NEWS theColumn:@"user_id" theColumnValue:self.userIdStr  withAll:NO];
	
	//NSLog(@"self.listArray========%@",self.listArray);
	
	if ([self.listArray count] == 0) {
		self.informationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = TIPS_NONE_FAVORITE_NEWS_CONTENT;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14.0f];
		[self.view addSubview:label];
		[label release];
	}
	
	[self.informationTableView reloadData];
	
	if (progressHUD != nil) {
		if (progressHUD) {
			[progressHUD removeFromSuperview];
		}
	}
}

- (void)getMoreResult:(NSMutableArray *)resultArray{
    
    _isLoadMore = NO;
    
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
        
        [self.informationTableView reloadData];
        
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
