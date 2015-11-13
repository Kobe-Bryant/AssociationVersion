//
//  newestMemberViewController.m
//  xieHui
//
//  Created by lai yun on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "newestMemberViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "alertCardViewController.h"
#import "MessageDetailViewController.h"
#import "browserViewController.h"

#define MARGIN 5.0f

@implementation newestMemberViewController

@synthesize myTableView;
@synthesize memberItems;
@synthesize activeMember;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize spinner;
@synthesize senderId;
@synthesize sourceName;
@synthesize sourceImage;
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
//	self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    self.title = @"最新会员";
	
	photoWith = 50;
	photoHigh = 50;
    
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    //活跃会员数据初始化
	NSMutableArray *tempActiveMemberArray = [[NSMutableArray alloc] init];
	self.activeMember = tempActiveMemberArray;
	[tempActiveMemberArray release];
	
	//商铺数据初始化
	NSMutableArray *tempMemberArray = [[NSMutableArray alloc] init];
	self.memberItems = tempMemberArray;
	[tempMemberArray release];
    
}

- (void) viewWillAppear:(BOOL)animated{
    
	[super viewWillAppear:animated];
    
    //取所有活跃会员
    self.activeMember = (NSMutableArray *)[DBOperate selectActiveMember];
    
    //从数据库中取出数据
	self.memberItems = (NSMutableArray *)[DBOperate queryData:T_NEWEST_MEMBER theColumn:nil theColumnValue:nil withAll:YES];
    
	if ([self.memberItems count] == 0)
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
	//[self.myTableView removeFromSuperview];
	
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
		int countItems = [self.memberItems count];
		if (countItems >[indexPath row])
		{
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
			
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
	NSArray *memberArray = [self.memberItems objectAtIndex:[indexPath row]];
	return [memberArray objectAtIndex:newest_member_img];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	
	int countItems = [self.memberItems count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *memberArray = [self.memberItems objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[memberArray objectAtIndex:newest_member_img] dataUsingEncoding: NSUTF8StringEncoding]];
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
	
	int countItems = [self.memberItems count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *memberArray = [self.memberItems objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[memberArray objectAtIndex:newest_member_img] dataUsingEncoding: NSUTF8StringEncoding]];
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
			UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
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
	NSString *reqUrl = @"newest.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getVersion:OPERAT_NEWEST_MEMBER_REFRESH],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_NEWEST_MEMBER_REFRESH 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//更新商铺的操作
-(void)updateMember
{
	
	//重新更新数据
	self.memberItems = (NSMutableArray *)[DBOperate queryData:T_NEWEST_MEMBER theColumn:nil theColumnValue:nil  withAll:YES];
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

//回归常态
-(void)backNormal
{
	//移除loading图标
	[self.spinner removeFromSuperview];
	
	//下拉缩回
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
	if (ver == NEED_UPDATE) 
	{
		[self performSelectorOnMainThread:@selector(updateMember) withObject:nil waitUntilDone:NO];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(updateMember) withObject:nil waitUntilDone:NO];
	}
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if ([self.memberItems count] == 0)
    {
        return 1;
    }
    else 
    {
        return [self.memberItems count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.memberItems != nil && [self.memberItems count] > 0)
    {
        if ([indexPath row] == [self.memberItems count])
        {
            //点击更多
            return 50.0f;
        }
        else 
        {
            //记录
            return 62.0f;
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
	
	NSMutableArray *items = self.memberItems;
	int countItems =  [self.memberItems count];
	
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
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.backgroundView = 
		//cell.selectedBackgroundView = 
		
        if (items != nil && countItems > 0)
        {
            self.myTableView.separatorColor = [UIColor clearColor];
            
            if([indexPath row] == countItems)
            {		
                UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 10, 120, 30)];
                moreLabel.tag = 200;
                moreLabel.text = @"查看更多";			
                moreLabel.textAlignment = UITextAlignmentCenter;
                moreLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:moreLabel];
                [moreLabel release];
                cell.tag = 201;
            }
            else
            {
                UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 0.0f , 60.0f, cell.frame.size.width, 2.0f)];
                UIImage * lineImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
                lineImageView.image = lineImg;
                [lineImg release];
                [cell.contentView addSubview:lineImageView];
                [lineImageView release];
                
                UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectZero];
                picView.tag = 100;
                picView.layer.masksToBounds = YES;
                picView.layer.cornerRadius = 5;
                [cell.contentView addSubview:picView];
                [picView release];
                
                UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.tag = 102;
                nameLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
                nameLabel.font = [UIFont systemFontOfSize:16];
                nameLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                cityLabel.backgroundColor = [UIColor clearColor];
                cityLabel.tag = 103;
                cityLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
                cityLabel.font = [UIFont systemFontOfSize:12];
                cityLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
                cityLabel.textAlignment = UITextAlignmentRight;
                [cell.contentView addSubview:cityLabel];
                [cityLabel release];
                
                UILabel *postLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                postLabel.backgroundColor = [UIColor clearColor];
                postLabel.tag = 104;
                postLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
                postLabel.font = [UIFont systemFontOfSize:12];
                postLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
                [cell.contentView addSubview:postLabel];
                [postLabel release];
                
                UILabel *companyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                companyLabel.backgroundColor = [UIColor clearColor];
                companyLabel.tag = 105;
                companyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
                companyLabel.font = [UIFont systemFontOfSize:12];
                companyLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
                [cell.contentView addSubview:companyLabel];
                [companyLabel release];
                
                cell.backgroundColor = [UIColor clearColor];
                
            }
        }
        else
        {
            UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
            noneLabel.tag = 201;
            [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
            noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
            noneLabel.text = @"没找到任何会员信息！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLabel];
            [noneLabel release];
        }
		
	}
	
	if ([indexPath row] != countItems && countItems != 0){
		
		UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
		UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:101];
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:103];
		UILabel *postLabel = (UILabel *)[cell.contentView viewWithTag:104];
		UILabel *companyLabel = (UILabel *)[cell.contentView viewWithTag:105];
		
		NSArray *memberArray = [items objectAtIndex:[indexPath row]];
		NSString *piclink = [memberArray objectAtIndex:newest_member_img];
        
        //名字间距
        NSString *nameString = [memberArray objectAtIndex:newest_member_user_name];
        CGSize constraint = CGSizeMake(20000.0f, 20.0f);
        CGSize size = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat fixWidth = size.width + 10.0f;
        
		if (piclink)
		{
			[nameLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f, MARGIN * 2, cell.frame.size.width-200.0f-6 * MARGIN, 20)];
            
            [cityLabel setFrame:CGRectMake(MARGIN * 2 + 180.0f, MARGIN * 2 + 9, cell.frame.size.width-180.0f-6 * MARGIN, 20)];
			
			[postLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f + fixWidth, MARGIN * 2, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
			
			[companyLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f, MARGIN * 6 + 2, cell.frame.size.width-80.0f-6 * MARGIN, 20)];
			
			[picView setFrame:CGRectMake(MARGIN, MARGIN, photoWith, photoHigh)];
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			if (cardIcon == nil)
			{
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员默认头像" ofType:@"png"]];
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
            
			[nameLabel setFrame:CGRectMake(MARGIN * 2, MARGIN * 2, cell.frame.size.width-6 * MARGIN, 20)];
            
            [cityLabel setFrame:CGRectMake(MARGIN * 2 + 180.0f, MARGIN * 2 + 9, cell.frame.size.width-180.0f-6 * MARGIN, 20)];
			
			[postLabel setFrame:CGRectMake(MARGIN * 2 + fixWidth, MARGIN * 2, cell.frame.size.width-6 * MARGIN, 20)];
			
			[companyLabel setFrame:CGRectMake(MARGIN * 2, MARGIN * 6 + 2, cell.frame.size.width-6 * MARGIN, 20)];
			
		}
		
		nameLabel.text = [memberArray objectAtIndex:newest_member_user_name];
        cityLabel.text = [memberArray objectAtIndex:newest_member_city];
		postLabel.text = [memberArray objectAtIndex:newest_member_post];
		companyLabel.text = [memberArray objectAtIndex:newest_member_company_name];
	}
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (self.memberItems != nil && [self.memberItems count] > 0)
	{
		if ([indexPath row] == [self.memberItems count])
		{
			//点击更多
		}
		else 
		{
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            
            NSMutableArray *memberArray = [self.memberItems objectAtIndex:[indexPath row]];
            alertCardViewController *alertCard = [[[alertCardViewController alloc] initWithFrame:window.bounds info:memberArray userID:[memberArray objectAtIndex:newest_member_user_id]] autorelease];
            alertCard.delegate = self;
            [window addSubview:alertCard];
            [alertCard showFromPoint:[self.view center]];
            self.senderId = [memberArray objectAtIndex:newest_member_user_id];
            self.sourceName = [memberArray objectAtIndex:newest_member_user_name];
            self.sourceImage = [memberArray objectAtIndex:newest_member_img];
		}
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	if (!decelerate)
	{
		[self loadImagesForOnscreenRows];
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

#pragma mark ---- 回调
- (void)feedback
{
    if (_isLogin == YES) {
        MessageDetailViewController *msgDetail = [[MessageDetailViewController alloc] init];
        msgDetail.sourceStr = self.senderId;
        msgDetail.sourceName = self.sourceName;
        msgDetail.sourceImage = self.sourceImage;
        [self.navigationController pushViewController:msgDetail animated:YES];
        [msgDetail release];
    }else {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        [self.navigationController pushViewController:login animated:YES];
        [login release];
    }
}

- (void)favoriteLogin
{
    LoginViewController *login = [[LoginViewController alloc] init];
    login.delegate = self;
    [self.navigationController pushViewController:login animated:YES];
    [login release];
}

- (void)goUrl:(NSString *)url
{
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = url;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

#pragma mark-----LoginViewDelegate method
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    
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
    self.memberItems = nil;
    self.activeMember = nil;
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
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
}


- (void)dealloc {
	self.memberItems = nil;
    self.activeMember = nil;
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
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    [super dealloc];
}


@end