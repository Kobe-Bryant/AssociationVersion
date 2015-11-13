    //
//  ShopsViewController.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopsViewController.h"
#import "ShopsCell.h"
#import "Encry.h"
#import "Common.h"
#import "DataManager.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "shopDetailViewController.h"
#import "UIImageScale.h"

#define kHeightForRow 95.0f

@implementation ShopsViewController
@synthesize shopsTableView = _shopsTableView;
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
	self.title = FAVORITE_SHOP_NAME;
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
	
	_shopsTableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	_shopsTableView.delegate = self;
	_shopsTableView.dataSource = self;
	//_shopsTableView.rowHeight = kHeightForRow;
	[_shopsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_shopsTableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:_shopsTableView];
	
	//下拉刷新控件
	//if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
//										   initWithFrame:CGRectMake(0.0f, 0.0f - _shopsTableView.bounds.size.height, self.view.frame.size.width, _shopsTableView.bounds.size.height)];
//		view.delegate = self;
//		[_shopsTableView addSubview:view];
//		_refreshHeaderView = view;
//		[view release];
//		
//	}
//	[_refreshHeaderView refreshLastUpdatedDate];
	
//	_isLoadMore == NO;
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
	[_shopsTableView release];
	_shopsTableView = nil;
	[__listArray release];
	__listArray = nil;
	[_refreshHeaderView release];
	_refreshHeaderView = nil;
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
		return 87.0f;
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
	
	ShopsCell *cell = (ShopsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[ShopsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		cell.cName.text = @"";
		cell.cTel.text = @"";
		cell.cAddress.text = @"";
        
    }
	//cell.backgroundColor = [UIColor colorWithRed:0.935 green:0.935 blue:0.935 alpha:1.0f];
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *cellArray = [self.listArray objectAtIndex:indexPath.row];
		cell.cName.text = [cellArray objectAtIndex:shop_favorite_title];
		cell.cTel.text = [cellArray objectAtIndex:shop_favorite_tel];
		cell.cAddress.text = [cellArray objectAtIndex:shop_favorite_address];
		
		if ([[cellArray objectAtIndex:shop_favorite_attestation] intValue] == 1)
		{
			cell.cAttestationImageView.hidden = NO;
		}
		else 
		{
			cell.cAttestationImageView.hidden = YES;
		}
		
		NSString *imageName = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:shop_favorite_pic_name]];
		UIImage *image = [FileManager getPhoto:imageName];
		NSString *imageUrl = [cellArray objectAtIndex:shop_favorite_pic];
		if (imageUrl.length > 1) 
		{
			//获取本地图片缓存
			UIImage *cardIcon = [image fillSize:CGSizeMake(75, 75)];
			if (cardIcon == nil)
			{
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺列表默认图片" ofType:@"png"]];
				cell.cImageView.image = [img fillSize:CGSizeMake(75, 75)];
				[img release];
				
				[self startIconDownload:imageUrl forIndex:indexPath];
			}
			else
			{
				cell.cImageView.image = cardIcon;
			}
			
		}
		else
		{
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺列表默认图片" ofType:@"png"]];
			cell.cImageView.image = [img fillSize:CGSizeMake(75, 75)];
			[img release];
		}
		
	}
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *shopArray = [[NSMutableArray alloc] initWithArray:[self.listArray objectAtIndex:[indexPath row]]];
	NSString *shopID = [shopArray objectAtIndex:shop_favorite_shop_id];
	shopDetailViewController *shopDetail = [[shopDetailViewController alloc] init];			
	
	shopDetail.shopID = shopID;
	
	[shopArray removeObjectAtIndex:0];
	[shopArray removeObjectAtIndex:0];
	[shopArray removeObjectAtIndex:1];
	
	NSMutableArray *shopInfoArray = [[NSMutableArray alloc] init];
	[shopInfoArray addObject:shopArray];
	shopDetail.shopItems = shopInfoArray;
	[shopInfoArray release];
	[self.navigationController pushViewController:shopDetail animated:YES];
	[shopDetail release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    rowValue = indexPath.row;
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	_listId = [[self.listArray objectAtIndex:indexPath.row] objectAtIndex:shop_favorite_shop_id];
	
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:1],@"type",
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
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_shopsTableView];
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.shopsTableView.frame.size.height && [self.listArray count] >= 20)
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
	ShopsCell *cell = (ShopsCell *)[self.shopsTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
	
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0){ 			
			UIImage *photo = iconDownloader.cardIcon;
			NSString *photoname = [callSystemApp getCurrentTime];
			if ([FileManager savePhoto:photoname withImage:photo]) {
				
				NSArray *one = [self.listArray objectAtIndex:iconDownloader.indexPathInTableView.row]; 
				NSNumber *value = [one objectAtIndex:shop_favorite_shop_uid];
			    [DBOperate updateData:T_SHOP_FAVORITE tableColumn:@"pic_name" 
						  columnValue:photoname conditionColumn:@"shop_uid" conditionColumnValue:value];
				if (_isLoadMore == NO) {
					self.listArray = (NSMutableArray *)[DBOperate queryData:T_SHOP_FAVORITE 
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
								 [Common getMemberVersion:_userId commandID:MEMBER_FAVORITESHOPSLIST_COMMAND_ID],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt:_userId],@"user_id",
								 [NSNumber numberWithInt:1],@"type",
								 [NSNumber numberWithInt:0],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITESHOPSLIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void) accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:shop_favorite_favoriteId] intValue];
	//NSLog(@"lastId====%d",lastId);
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt:-1],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:1],@"type",
										[NSNumber numberWithInt:lastId],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITESHOPSMORELIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

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
		case MEMBER_FAVORITESHOPSLIST_COMMAND_ID:
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
		case MEMBER_FAVORITESHOPSMORELIST_COMMAND_ID:
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
	int retInt = [[[resultArray objectAtIndex:0] objectAtIndex:0] intValue];
	if (retInt == 1) {
		[DBOperate deleteData:T_SHOP_FAVORITE tableColumn:@"shop_id" columnValue:_listId];
		[self.listArray removeObjectAtIndex:rowValue];
//		[self.shopsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:listIndexPath] 
//								 withRowAnimation:UITableViewRowAnimationFade];
		
		[self.shopsTableView reloadData];
		
		if ([self.listArray count] == 0) {
			self.shopsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
			label.text = TIPS_NONE_FAVORITE_SHOP_CONTENT;
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor grayColor];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:16.0f];
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
	self.listArray = (NSMutableArray *)[DBOperate queryData:T_SHOP_FAVORITE theColumn:@"user_id" theColumnValue:self.userIdStr  withAll:NO];
    
//	NSLog(@"self.listArray========%@",self.listArray);
//	NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	if ([self.listArray count] == 0) {
		self.shopsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = TIPS_NONE_FAVORITE_SHOP_CONTENT;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14.0f];
		[self.view addSubview:label];
		[label release];
	}
	[self.shopsTableView reloadData];
	
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
        
        [self.shopsTableView reloadData];
        
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
