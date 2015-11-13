    //
//  ProductViewController.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductCell.h"
#import "Encry.h"
#import "Common.h"
#import "DataManager.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "supplyDetailViewController.h"
#import "UIImageScale.h"
#define kHeightForRow 75.0f

@implementation ProductViewController
@synthesize productTableView= _productTableView;
@synthesize listArray = __listArray;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize iconDownLoad;
@synthesize dbArray = __dbArray;
@synthesize userIdStr;
@synthesize rowValue;
@synthesize spinner;
@synthesize moreLabel;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)init {
    self = [super init];
    if (self) {

		__listArray = [[NSMutableArray alloc] init];
		__dbArray = [[NSArray alloc] init];
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
	
	self.title = FAVORITE_SUPPLY_NAME;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
	progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	progressHUD.delegate = self;
	progressHUD.labelText = LOADING_TIPS;
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	[self accessService];
	//NSLog(@"self.listArray=====%@",self.listArray);
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
	
	_productTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44.0f) style:UITableViewStylePlain];
	_productTableView.delegate = self;
	_productTableView.dataSource = self;
	_productTableView.scrollEnabled = YES;
	//productTableView.rowHeight = kHeightForRow;
	[_productTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_productTableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:_productTableView];
	
	//下拉刷新控件
//	if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
//										   initWithFrame:CGRectMake(0.0f, 0.0f - _productTableView.bounds.size.height, self.view.frame.size.width, _productTableView.bounds.size.height)];
//		view.delegate = self;
//		[_productTableView addSubview:view];
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

	[_productTableView release];
	_productTableView = nil;
	[__listArray release];
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
	[_refreshHeaderView release];
	_refreshHeaderView = nil;
	[__dbArray release];
	__dbArray = nil;
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
		return 76.0f;
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
	
	ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[ProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
		cell.pTitle.text = @"";
		cell.pContent.text = @"";
		cell.pMoney.text = @"";
		cell.pLevel.text = @"";
			
    }
	//cell.backgroundColor = [UIColor colorWithRed:0.935 green:0.935 blue:0.935 alpha:1.0f];
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *ay = [self.listArray objectAtIndex:indexPath.row];
		cell.pTitle.text = [NSString stringWithFormat:@"%@",[ay objectAtIndex:supply_favorite_title]];
		cell.pContent.text = [NSString stringWithFormat:@"%@",[ay objectAtIndex:supply_favorite_desc]];
        if ([[ay objectAtIndex:supply_favorite_price] intValue] != 0) {
            cell.pMoney.text = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:supply_favorite_price] intValue]];
            cell.pLevel.text = [NSString stringWithFormat:@"%d", [[ay objectAtIndex:supply_favorite_favorite] intValue]];
        } else {
            cell.moneyView.hidden = YES;
            cell.levelView.hidden = YES;
            CGSize labelSize = [@"你" sizeWithFont:[UIFont boldSystemFontOfSize:12.0f]];
            CGRect rect = cell.pContent.frame;
            rect.size.height = labelSize.height*3;
            cell.pContent.frame = rect;
        }
		
		if ([[ay objectAtIndex:supply_favorite_recommend] intValue] == 1)
		{
			cell.recommendImageView.hidden = NO;
		}
		else 
		{
			cell.recommendImageView.hidden = YES;
		}
		
		NSString *imageUrl = [ay objectAtIndex:supply_favorite_pic];
		//NSString *imageUrl = @"http://demo1.3g.yunlai.cn/userfiles/000/000/101/recent_img/112610324.jpg";
		NSString *imageName = [NSString stringWithFormat:@"%@",[ay objectAtIndex:supply_favorite_picName]];
		UIImage *image = [FileManager getPhoto:imageName];
		if (image != nil) {
			cell.pImageView.image = [image fillSize:CGSizeMake(62, 62)];
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
	//NSLog(@"self.listArray====%@",self.listArray);
	NSMutableArray *supplyArray = [[NSMutableArray alloc] initWithArray:[self.listArray objectAtIndex:[indexPath row]]];
	//NSLog(@"supplyArray====%@",supplyArray);
	//NSLog(@"[supplyArray count]=====%d",[supplyArray count]);
	NSString *supplyID = [supplyArray objectAtIndex:supply_favorite_supply_id];
	
	supplyDetailViewController *supplyDetail = [[supplyDetailViewController alloc] init];
	
	supplyDetail.supplyID = supplyID;
    supplyDetail.commentTotal = [supplyArray objectAtIndex:supply_favorite_commentTotal];
    supplyDetail.isFrom = NO;
	
	[supplyArray removeObjectAtIndex:0];
	[supplyArray removeObjectAtIndex:0];
	[supplyArray removeObjectAtIndex:1];
	[supplyArray removeObjectAtIndex:9];
	[supplyArray addObject:@""];
	//NSLog(@"supplyArray====%@",supplyArray);
	
	
	NSMutableArray *supplyInfoArray = [[NSMutableArray alloc] init];
	[supplyInfoArray addObject:supplyArray];
	supplyDetail.supplyArray = supplyInfoArray;
	[supplyInfoArray release];
	
	NSMutableArray *picArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_PIC_FAVORITE theColumn:@"supply_id" theColumnValue:[NSString stringWithFormat:@"%@",supplyID] withAll:NO];
	//NSLog(@"=====%@",picArray);
	NSMutableArray *allPic = [[NSMutableArray alloc] init];
	for (int i = 0; i < [picArray count]; i ++) {
		NSMutableArray *array = [picArray objectAtIndex:i];
		[array removeObjectAtIndex:2];
		[allPic addObject:array];
	}

	supplyDetail.supplyPicArray = allPic;
	
	[self.navigationController pushViewController:supplyDetail animated:YES];
	[supplyDetail release];
	[allPic release];
	[supplyArray release];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    rowValue = indexPath.row;
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    //NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	//NSLog(@"self.listArray =====%@",self.listArray);
	_supplyId = [[self.listArray objectAtIndex:indexPath.row] objectAtIndex:supply_favorite_supply_id];
	//NSLog(@"_supplyId=======%d",[_supplyId intValue]);
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt:_userId],@"user_id",
								 [NSNumber numberWithInt:2],@"type",
								 [NSNumber numberWithInt: [_supplyId intValue]],@"info_id",nil];
	
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
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_productTableView];	
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
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.productTableView.frame.size.height && [self.listArray count] >= 20)
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
	ProductCell *cell = (ProductCell *)[self.productTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
	
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0){ 			
			UIImage *photo = iconDownloader.cardIcon;
			NSString *photoname = [callSystemApp getCurrentTime];
			if ([FileManager savePhoto:photoname withImage:photo]) {
				
				NSArray *one = [self.listArray objectAtIndex:iconDownloader.indexPathInTableView.row]; 
				NSNumber *value = [one objectAtIndex:supply_favorite_supply_id];
			    [DBOperate updateData:T_SUPPLY_FAVORITE tableColumn:@"picName" 
					     columnValue:photoname conditionColumn:@"supply_id" conditionColumnValue:value];				
			    if (_isLoadMore == NO) {
					self.listArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_FAVORITE 
																  theColumn:@"user_id" theColumnValue:self.userIdStr withAll:NO];
				}
				
			}
			cell.pImageView.image = [photo fillSize:CGSizeMake(62, 62)];	
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
								 [Common getMemberVersion:_userId commandID:MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt:_userId],@"user_id",
								 [NSNumber numberWithInt:2],@"type",
								 [NSNumber numberWithInt:0],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:supply_favorite_favoriteId] intValue];
	//NSLog(@"lastId====%d",lastId);
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[NSNumber numberWithInt:-1],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
										[NSNumber numberWithInt:_userId],@"user_id",
										[NSNumber numberWithInt:2],@"type",
										[NSNumber numberWithInt:lastId],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
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
	//NSLog(@"=====%@",resultArray);
	switch (commandid) {
		case MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID:
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
		case MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID:
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
	self.listArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_FAVORITE theColumn:@"user_id" theColumnValue:self.userIdStr  withAll:NO];
	//NSLog(@"self.listArray========%@",self.listArray);
	//NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	
	if ([self.listArray count] == 0) {
		self.productTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = TIPS_NONE_FAVORITE_SUPPLY_CONTENT;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14.0f];
		[self.view addSubview:label];
		[label release];
	}
	
	[_productTableView reloadData];
	
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
		[DBOperate deleteData:T_SUPPLY_FAVORITE tableColumn:@"supply_id" columnValue:_supplyId];
        [DBOperate deleteData:T_SUPPLY_PIC_FAVORITE tableColumn:@"supply_id" columnValue:_supplyId];
        [self.listArray removeObjectAtIndex:rowValue];
		
		[self.productTableView reloadData];
		
		if ([self.listArray count] == 0) {
			self.productTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
			label.text = TIPS_NONE_FAVORITE_SUPPLY_CONTENT;
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
        
        [self.productTableView reloadData];
        
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
