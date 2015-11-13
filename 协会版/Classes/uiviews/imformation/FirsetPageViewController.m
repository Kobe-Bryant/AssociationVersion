//
//  FirsetPageViewController.m
//  Profession
//
//  Created by MC374 on 12-8-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FirsetPageViewController.h"
#import "myImageView.h"
#import "Common.h"
#import "AutoScrollView.h"
#import "NewsDetailViewController.h"
#import "Encry.h"
#import "DataManager.h"
#import "IconDownLoader.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "callSystemApp.h"
#import "downloadParam.h"
#import "SearchViewController.h"
#import "browserViewController.h"
#import "MBProgressHUD.h"
#import "shopDetailViewController.h"
#import "NewestViewController.h"
#import "newestMemberViewController.h"
#import "alertCardViewController.h"
#import "MessageDetailViewController.h"
#import "activityMainViewController.h"
#import "CustomNavigationController.h"
#define CELLMARGIN 5
#define MARGIN 10

#define BUTTON_TAG 300
#define SEARCH_PIC_ID 400

#define BANNER_PIC_OFFSET 500
#define RECOMMEND_NEWS_PIC_OFFSET 600
#define RECOMMEND_SHOPS_PIC_OFFSET 700
#define FOOT_AD_PIC_OFFSET 800

#define PHOTOWIDTH 76
#define PHOTOHEIGHT 56
#define SHOPBACK_IMAGEVIEW_TAG 20000
#define RECOMMEND_SCROLLVIEW_TAG 10000

BOOL touchFlag = NO;

// dufu add 2013.05.03   ceshi 
#import "activityShareViewController.h"

@implementation FirsetPageViewController
@synthesize  myNavigationController;
@synthesize myTableView;
@synthesize mainScrollView;
@synthesize totalheight;
@synthesize adPicArray;
@synthesize adScrollView;
@synthesize topAdArray;
@synthesize footAdArray;
@synthesize recommendNewsArray;
@synthesize activeMember;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize iconDownLoad;
@synthesize recommendScrollView;
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
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor grayColor];
	
	//图片下载类初始化
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
	CGFloat fixHeight = [UIScreen mainScreen].bounds.size.height - CAT_HEIGHT - 49.0f - 44.0f - 20.0f;
	UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, fixHeight)];
	sc.pagingEnabled = NO;
	sc.delegate = self;
	sc.showsHorizontalScrollIndicator = NO;
	sc.showsVerticalScrollIndicator = YES;
	sc.backgroundColor = [UIColor whiteColor];
	sc.contentSize = CGSizeMake(320, 600);
	self.mainScrollView = sc;
	[sc release];
	[self.view addSubview:mainScrollView];
	
	//下拉刷新控件
	if (_refreshHeaderView == nil) {

		EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] 
											initWithFrame:CGRectMake(0.0f, 0.0f - mainScrollView.bounds.size.height, self.view.frame.size.width, mainScrollView.bounds.size.height)];
		refreshView.delegate = self;
		[mainScrollView addSubview:refreshView];
		_refreshHeaderView = refreshView;
		[refreshView release];
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
	
	
	myImageView *imageView = [[myImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 40) withImageId:SEARCH_PIC_ID];	
	UIImage *searchimage = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"首页搜索按钮" ofType:@"png"]];
	imageView.image = searchimage;
	imageView.mydelegate = self;
    [mainScrollView addSubview:imageView];	
    [imageView release];
	
	//添加banner广告和资讯列表
	UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 341)];
	tb.delegate = self;
	tb.dataSource = self;
	tb.scrollEnabled = NO;
	self.myTableView = tb;
	myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0f];
	[tb release];

    myTableView.hidden = YES;
	[mainScrollView addSubview:myTableView];
	
	totalheight = 40 + myTableView.frame.size.height;
	
	//添加4个按钮
	UIImageView *buttonImageView = [[UIImageView alloc] initWithFrame:
									CGRectMake(0, totalheight+4, 320, 224)];
	buttonImageView.backgroundColor = [UIColor whiteColor];
	buttonImageView.userInteractionEnabled = YES;
	[mainScrollView addSubview:buttonImageView];
    
    //最新会员
	UIButton *activityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[activityBtn setFrame:CGRectMake(4, 0, 154, 80)];
	[activityBtn addTarget:self action:@selector(handleFunction:)
			 forControlEvents:UIControlEventTouchUpInside];
	activityBtn.tag = BUTTON_TAG;
	UIImage *activityImg = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"首页_按钮_活动平台" ofType:@"png"]];
	[activityBtn setImage:activityImg forState:UIControlStateNormal];
	[activityImg release];
	UIImage *activityImg1 = [[UIImage alloc]initWithContentsOfFile:
							 [[NSBundle mainBundle] pathForResource:@"首页_按钮_活动平台" ofType:@"png"]];
	[activityBtn setImage:activityImg1 forState:UIControlStateSelected];
	[activityImg1 release];
	[buttonImageView addSubview:activityBtn];
    
    //最新会员
	UIButton *newsMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[newsMessageBtn setFrame:CGRectMake(162, 0, 154, 80)];
	[newsMessageBtn addTarget:self action:@selector(handleFunction:)
			 forControlEvents:UIControlEventTouchUpInside];
	newsMessageBtn.tag = BUTTON_TAG + 1;
	UIImage *turnbackImg = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"首页_按钮_最新会员" ofType:@"png"]];
	[newsMessageBtn setImage:turnbackImg forState:UIControlStateNormal];
	[turnbackImg release];
	UIImage *turnbackImg1 = [[UIImage alloc]initWithContentsOfFile:
							 [[NSBundle mainBundle] pathForResource:@"首页_按钮_最新会员" ofType:@"png"]];
	[newsMessageBtn setImage:turnbackImg1 forState:UIControlStateSelected ];
	[turnbackImg1 release];
	[buttonImageView addSubview:newsMessageBtn];
	
//	//最新资讯
//	UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//	[recommendBtn setFrame:CGRectMake(162, 0, 154, 80)];
//	[recommendBtn addTarget:self action:@selector(handleFunction:) 
//			 forControlEvents:UIControlEventTouchUpInside];
//	recommendBtn.tag = BUTTON_TAG + 1; 
//	UIImage *recommendImg = [[UIImage alloc]initWithContentsOfFile:
//							[[NSBundle mainBundle] pathForResource:@"首页最新资讯" ofType:@"png"]];
//	[recommendBtn setImage:recommendImg forState:UIControlStateNormal];
//	[recommendImg release];
//	UIImage *recommendIm2 = [[UIImage alloc]initWithContentsOfFile:
//							 [[NSBundle mainBundle] pathForResource:@"首页最新资讯" ofType:@"png"]];
//	[recommendBtn setImage:recommendIm2 forState:UIControlStateSelected ];
//	[recommendIm2 release];
//	[buttonImageView addSubview:recommendBtn];
	
	totalheight += 86;
	
	//活跃会员		
	UIImageView *activeMemberBackImageView = [[UIImageView alloc] initWithFrame:
									  CGRectMake(0,totalheight,320, 70)];		
	UIImage *activeMemberimage = [[UIImage alloc]initWithContentsOfFile:
						  [[NSBundle mainBundle] pathForResource:@"首页活跃会员背景" ofType:@"png"]];
	activeMemberBackImageView.image = activeMemberimage;
	activeMemberBackImageView.tag = SHOPBACK_IMAGEVIEW_TAG;
	[activeMemberimage release];
	[mainScrollView addSubview:activeMemberBackImageView];
	[activeMemberBackImageView release];
	
	//添加推荐商铺scroll控件
	UIScrollView *tempRecommendScrollView = [[UIScrollView alloc] initWithFrame:
										 CGRectMake(0, totalheight, 320, 70)];	
	tempRecommendScrollView.pagingEnabled = YES;
	tempRecommendScrollView.backgroundColor = [UIColor clearColor];
	tempRecommendScrollView.delegate = self;
	tempRecommendScrollView.showsHorizontalScrollIndicator = NO;
	tempRecommendScrollView.showsVerticalScrollIndicator = NO;
    self.recommendScrollView = tempRecommendScrollView;
	[mainScrollView addSubview:self.recommendScrollView];
	[tempRecommendScrollView release];
		
	totalheight += 70;
	
	mainScrollView.contentSize = CGSizeMake(320, totalheight);
	
	//添加loading控件
	progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
//	progressHUD.delegate = self;
	progressHUD.labelText = LOADING_TIPS;
	
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	//请求网络数据
	[self accessService];

//	[self update];
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
	self.mainScrollView = nil;
	bannerScrollView = nil;
	self.adPicArray = nil;
	self.adScrollView = nil;
	self.topAdArray = nil;
	self.footAdArray = nil;
	self.recommendNewsArray = nil;
	self.activeMember = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.iconDownLoad = nil;
	progressHUD = nil;
    self.recommendScrollView.delegate = nil;
    self.recommendScrollView = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
	[myNavigationController release];
	myNavigationController = nil;
	[myTableView release];
	myTableView = nil;
	[mainScrollView release];
	mainScrollView = nil;
	[bannerScrollView release];
	bannerScrollView = nil;
	[adPicArray release];
	adPicArray = nil;
	[adScrollView release];
	adScrollView = nil;
	[topAdArray release];
	topAdArray = nil;
	[footAdArray release];
	footAdArray = nil;
	[recommendNewsArray release];
	recommendNewsArray = nil;
	[activeMember release];
	activeMember = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	[imageDownloadsInProgress release];
	imageDownloadsInProgress = nil;
	[imageDownloadsInWaiting release];
	imageDownloadsInWaiting = nil;
	[iconDownLoad release];
	iconDownLoad = nil;
	[progressHUD release],progressHUD = nil;
	
	[_refreshHeaderView release];
	_refreshHeaderView = nil;
    self.recommendScrollView.delegate = nil;
    self.recommendScrollView = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    [super dealloc];
}

- (void)accessService{
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[Common getSecureString],@"keyvalue",
										[Common getVersion:ACCESS_ADVERTISE_COMMAND_ID],@"ver",
										[NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt: 1],@"is_activity",
                                        nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:ACCESS_ADVERTISE_COMMAND_ID 
								  accessAdress:@"ad/advertising.do?param=%@" delegate:self withParam:nil];
}

- (void)accessRecommentService{
	//md5加密字符串生成
	NSString *keystring = [NSString stringWithFormat:@"%d%@",SITE_ID,SignSecureKey];
	NSString *securekey = [Encry md5:keystring];
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 securekey,@"keyvalue",
								 [Common getVersion:ACCESS_RECOMMEND_NEWS_COMMAND_ID],@"ver_news",
								 [NSNumber numberWithInt: 0],@"ver_shops",
								 [Common getVersion:ACCESS_NEWS_CATS_COMMAND_ID],@"ver_cats",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: 1],@"edition",
                                 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:ACCESS_RCM_CATS_COMMAND_ID 
								  accessAdress:@"recommend.do?param=%@" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    
    if (commandid == ACCESS_RCM_CATS_COMMAND_ID) {
        [self accessService];
    }
    else if (commandid == ACCESS_ADVERTISE_COMMAND_ID)
    {
        [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
    }
	
}

- (void) update{	
    
	self.topAdArray = [DBOperate queryData:T_ADVERTISE_LIST 
								 theColumn:@"adType" theColumnValue:@"top" withAll:NO];
	self.footAdArray = [DBOperate queryData:T_ADVERTISE_LIST 
								  theColumn:@"adType" theColumnValue:@"foot" withAll:NO];
	self.activeMember = [DBOperate queryData:T_ACTIVE_MEMBER 
										  theColumn:nil theColumnValue:nil withAll:YES];
	self.recommendNewsArray = [DBOperate queryData:T_RECOMMEND_NEWS 
										 theColumn:nil theColumnValue:nil withAll:YES];
	[myTableView reloadData];
    myTableView.hidden = NO;
    
    //移出推荐商铺原先的内容
    NSArray *viewsToRemove = [self.recommendScrollView subviews]; 
    for (UIView *v in viewsToRemove) 
    {
        [v removeFromSuperview];
    }
	
	if (activeMember != nil && [activeMember count] > 0) {
		int pageCount = [activeMember count];
        
        //[self.recommendScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
		recommendScrollView.contentSize = CGSizeMake(pageCount * 320, 70);
		for(int i = RECOMMEND_SHOPS_PIC_OFFSET;i < RECOMMEND_SHOPS_PIC_OFFSET + pageCount;i++) {
			myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake((i - RECOMMEND_SHOPS_PIC_OFFSET) * 320,0,320, 70) withImageId:i];
			myiv.backgroundColor = [UIColor clearColor];
			myiv.mydelegate = self;
			myiv.tag = i;      
			
			//活跃会员
			UIImageView *activeMemberImageView = [[UIImageView alloc] 
										  initWithFrame:CGRectMake(20, MARGIN, 50, 50)];		
			activeMemberImageView.tag = 7000;
            activeMemberImageView.layer.masksToBounds = YES;
            activeMemberImageView.layer.cornerRadius = 5;
			[myiv addSubview:activeMemberImageView];
			
			//活跃会员数据
			NSArray *activeMemberArray = [activeMember objectAtIndex:(i - RECOMMEND_SHOPS_PIC_OFFSET)];
            NSString *picurl = [activeMemberArray objectAtIndex:active_member_img];
            NSString *picname = [Common encodeBase64:(NSMutableData *)[picurl dataUsingEncoding: NSUTF8StringEncoding]];
            
            UIImage *activeMemberimage = [[UIImage alloc]initWithContentsOfFile:
                                          [[NSBundle mainBundle] pathForResource:@"会员默认头像" ofType:@"png"]];
            activeMemberImageView.image = activeMemberimage;
            [activeMemberimage release];
			
			UIImage *img = [FileManager getPhoto:picname];
			if (img != nil) {
				activeMemberImageView.image = img;
			}else {
				if (picurl.length > 0) {
					[self startIconDownload: picurl forIndex:[NSIndexPath indexPathForRow:i inSection:0]];
				}
			}
			[activeMemberImageView release];
			
            //活跃会员
			UILabel *name = [[UILabel alloc] 
							 initWithFrame:CGRectMake(80, MARGIN + 1.0f, 80, 30)];
			name.text = [activeMemberArray objectAtIndex:active_member_user_name];
			name.font = [UIFont systemFontOfSize:16];
            name.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
			name.backgroundColor = [UIColor clearColor];
			[myiv addSubview:name];
			[name release];
            
            //名字间距
            NSString *nameString = [activeMemberArray objectAtIndex:active_member_user_name];
            CGSize constraint = CGSizeMake(20000.0f, 20.0f);
            CGSize size = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGFloat fixWidth = size.width + 10.0f;
            
            UILabel *postLabel = [[UILabel alloc] 
                                  initWithFrame:CGRectMake(80 + fixWidth, MARGIN + 5.0f, 100, 25)];
			postLabel.text = [activeMemberArray objectAtIndex:active_member_post];
			postLabel.textColor = [UIColor grayColor];
			postLabel.font = [UIFont systemFontOfSize:12];
			postLabel.backgroundColor = [UIColor clearColor];
			[myiv addSubview:postLabel];
			[postLabel release];
            
            UILabel *cityLabel = [[UILabel alloc] 
							 initWithFrame:CGRectMake(200, MARGIN + 12.0f, 100, 25)];
			cityLabel.text = [activeMemberArray objectAtIndex:active_member_city];
			cityLabel.font = [UIFont systemFontOfSize:12];
            cityLabel.textColor = [UIColor grayColor];
			cityLabel.backgroundColor = [UIColor clearColor];
            cityLabel.textAlignment = UITextAlignmentRight;
			[myiv addSubview:cityLabel];
			[cityLabel release];
			
			UILabel *companyLabel = [[UILabel alloc] 
							  initWithFrame:CGRectMake(80, MARGIN + 25, 200, 25)];
			companyLabel.text = [activeMemberArray objectAtIndex:active_member_company_name];
			companyLabel.textColor = [UIColor grayColor];
			companyLabel.font = [UIFont systemFontOfSize:12];
			companyLabel.backgroundColor = [UIColor clearColor];
			[myiv addSubview:companyLabel];
			[companyLabel release];
			
			[recommendScrollView addSubview:myiv];
		}
	}
    
    //先移出原先的广告
    if ([self.adScrollView isDescendantOfView:mainScrollView]) 
    {
        totalheight -= 50;
        [self.adScrollView removeFromSuperview];
    }
		
	//判断是否有广告，有的话，就加广告控件
	if (footAdArray != nil && [footAdArray count] > 0) {
        
		int adCount = [footAdArray count];	
		NSMutableArray *ay = [[NSMutableArray alloc] init];
		self.adPicArray = ay;
		[ay release];
		for (int i = 0; i < adCount; i++) {
			UIImage *image = [[UIImage alloc]initWithContentsOfFile:
							  [[NSBundle mainBundle] pathForResource:@"AD默认图片" ofType:@"png"]];
			[adPicArray addObject:image];
			[image release];
		}
        
		AutoScrollView *asv = [[AutoScrollView alloc] initWithFrame:
							   CGRectMake(0,totalheight, 321, 50) picArray:adPicArray];
		asv.delegate = self;
        asv.backgroundColor = [UIColor clearColor];
		self.adScrollView = asv;
		[asv release];
		[mainScrollView addSubview:adScrollView];
		
		//下载底部广告的图片
		for (int i = FOOT_AD_PIC_OFFSET ;i < FOOT_AD_PIC_OFFSET + adCount; i++) {
			NSArray *cc = [footAdArray objectAtIndex:(i - FOOT_AD_PIC_OFFSET)];				
			NSString *imageurl = [cc objectAtIndex:advertiselist_image];

			NSString *imagename = [cc objectAtIndex:advertiselist_image_name];
			UIImage *image = [FileManager getPhoto:imagename];
			if (image != nil) {
				[adScrollView updateImage:image picArrayIndex:(i- FOOT_AD_PIC_OFFSET)];
			}else {
				if (imageurl.length > 1)
				{
					[self startIconDownload: imageurl forIndex:[NSIndexPath indexPathForRow:i inSection:0]];
				}
			}
		}
		
		//增加scrollview的内容高度
		totalheight += 50;		
		mainScrollView.contentSize = CGSizeMake(320, totalheight);
	}
	if (progressHUD != nil) {
		if (progressHUD) {
			[progressHUD removeFromSuperview];
		}
	}
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}


- (void) handleFunction:(id) sender{
	UIButton *pressBtn = (UIButton*)sender;
	switch (pressBtn.tag)
    {
		//活动平台
		case BUTTON_TAG:
        {
            activityMainViewController * activityMainView = [[activityMainViewController alloc] init];
            [self.myNavigationController pushViewController:activityMainView animated:YES];
            [activityMainView release];
            break;
		}
		//最新会员
		case BUTTON_TAG + 1:
        {
            newestMemberViewController *newestMember = [[newestMemberViewController alloc] init];
            [self.myNavigationController pushViewController:newestMember animated:YES];
            [newestMember release];
			break;
		}
		default:
			break;
	}
}

//下拉刷新
#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mainScrollView];	
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self accessRecommentService];

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recommendNewsArray count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == 0){
		return 131.0f;
	}else{
		return 70.0f;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier;
	if (indexPath.row == 0) {
		CellIdentifier = @"bannercell";
	}else {
		CellIdentifier = @"newscell";
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];	
        self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
		if (indexPath.row == 0) {
			int pageCount = [topAdArray count];
			if (bannerScrollView == nil) {				
                bannerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 130)];
                bannerScrollView.contentSize = CGSizeMake(pageCount * self.view.frame.size.width, 130);
                bannerScrollView.pagingEnabled = YES;
                bannerScrollView.delegate = self;
                bannerScrollView.showsHorizontalScrollIndicator = NO;
                bannerScrollView.showsVerticalScrollIndicator = NO;
                bannerScrollView.tag = 5000;      
                
						
				if(pageControll == nil){
					
					pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];		

					pageControll.backgroundColor = [UIColor clearColor];
					pageControll.numberOfPages = pageCount;
					pageControll.currentPage = 0;
					[pageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
					
				}
				[cell.contentView addSubview:bannerScrollView];
				[cell.contentView addSubview:pageControll]; 
            }		                                   
		}else {
            
			UIImageView *newsBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELLMARGIN,CELLMARGIN,80 , 60)];
			UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:
								  [[NSBundle mainBundle] pathForResource:@"资讯列表图片背景" ofType:@"png"]];
			newsBackImageView.image = backImage;
			[backImage release];
			[cell.contentView addSubview:newsBackImageView];
			
			UIImageView *newsDefaultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2,2,PHOTOWIDTH, PHOTOHEIGHT)];
			UIImage *defaultImage = [[UIImage alloc]initWithContentsOfFile:
									 [[NSBundle mainBundle] pathForResource:@"默认图资讯列表" ofType:@"png"]];
			newsDefaultImageView.image = defaultImage;
			newsDefaultImageView.tag = 103;
			[defaultImage release];
			[newsBackImageView addSubview:newsDefaultImageView];
			[newsDefaultImageView release];
			[newsBackImageView release];
			
			UILabel *mtitle = [[UILabel alloc]initWithFrame:
							   CGRectMake(CELLMARGIN * 2 + 80, CELLMARGIN, cell.frame.size.width-PHOTOWIDTH-5 * CELLMARGIN - 20, 20)];
			mtitle.backgroundColor = [UIColor clearColor];
			mtitle.tag = 101;
			mtitle.text = @"";
			mtitle.font = [UIFont systemFontOfSize:16];
			mtitle.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];		
			[cell.contentView addSubview:mtitle];
			[mtitle release];
			
			UILabel *detailtitle = [[UILabel alloc]initWithFrame:
									CGRectMake(CELLMARGIN * 2 + 80, 25, cell.frame.size.width-PHOTOWIDTH-5 * CELLMARGIN - 20, 40)];
			detailtitle.backgroundColor = [UIColor clearColor];
			detailtitle.tag = 102;
			detailtitle.text = @"";
            detailtitle.numberOfLines = 2;
			detailtitle.font = [UIFont systemFontOfSize:12];
			detailtitle.textColor = [UIColor grayColor];			
			[cell.contentView addSubview:detailtitle];
			[detailtitle release];
			
//			UILabel *timetitle = [[UILabel alloc]initWithFrame:
//								  CGRectMake(CELLMARGIN * 2 + 80, 45, cell.frame.size.width-PHOTOWIDTH-5 * CELLMARGIN - 20, 20)];
//			timetitle.backgroundColor = [UIColor clearColor];
//			timetitle.tag = 104;
//			timetitle.text = @"";
//			timetitle.font = [UIFont systemFontOfSize:12];
//			timetitle.textColor = [UIColor grayColor];			
//			[cell.contentView addSubview:timetitle];
//			[timetitle release];
			
			//添加右箭头
			UIImageView *rightImage = [[UIImageView alloc]initWithFrame:
									   CGRectMake(self.view.frame.size.width - 16 - CELLMARGIN, 32, 16, 11)];
			UIImage *rimg;
			rimg = [[UIImage alloc]initWithContentsOfFile:
					[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
			rightImage.image = rimg;
			[rimg release];
			[cell.contentView addSubview:rightImage];
			[rightImage release];
            
            UIImageView *recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
            UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"头条" ofType:@"png"]];
            recommendImageView.image = recommendImage;
            [recommendImage release];
            [cell.contentView addSubview:recommendImageView];
            [recommendImageView release];
		}

	}
	
	if (indexPath.row == 0) {
        
        //移出原先的内容
        NSArray *viewsToRemove = [bannerScrollView subviews]; 
        for (UIView *v in viewsToRemove) 
        {
            [v removeFromSuperview];
        }
        
		if (topAdArray != nil && [topAdArray count] > 0) {
            
			int pageCount = [topAdArray count];
			bannerScrollView.contentSize = CGSizeMake(pageCount * self.view.frame.size.width, 130);
			pageControll.numberOfPages = pageCount;
            float pageWidth = pageCount * 18.0f;
            float pageMargin = 320.0f - pageWidth;
            [pageControll setFrame:CGRectMake(pageMargin, 107.0f, pageWidth, 16.0f)];
			
			for(int i = BANNER_PIC_OFFSET;i < BANNER_PIC_OFFSET + pageCount;i++) {
				NSArray *top_ay = [topAdArray objectAtIndex:(i - BANNER_PIC_OFFSET)];
				NSString *imagename = [top_ay objectAtIndex:advertiselist_image_name];
				NSString *imageurl = [top_ay objectAtIndex:advertiselist_image];

				NSString *bannertext = [top_ay objectAtIndex:advertiselist_desc];
				UIImage *image = [FileManager getPhoto:imagename];
				
				myImageView *myiv = [[myImageView alloc]initWithFrame:
									 CGRectMake((i - BANNER_PIC_OFFSET) * bannerScrollView.frame.size.width,0,
												self.view.frame.size.width, 132) withImageId:i];
				if (image != nil) {
					myiv.image = image;
				}else {
					UIImage *img = [[UIImage alloc]initWithContentsOfFile:
									[[NSBundle mainBundle] pathForResource:@"默认图banner" ofType:@"png"]];
					myiv.image = img;
					[img release];
					if ([imageurl length] > 0) {		
						[self startIconDownload:imageurl forIndex:[NSIndexPath indexPathForRow:i inSection:0]];
					}
				}				
				myiv.mydelegate = self;
				myiv.tag = i;                                        
				
				UITextView *textView = [[UITextView alloc] initWithFrame:
										CGRectMake(0, 102,self.view.frame.size.width,30)];
				textView.scrollEnabled = NO;
				textView.editable = NO;
				textView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
				//textView.backgroundColor = [UIColor clearColor];
				textView.text = bannertext;                  
				textView.textColor = [UIColor whiteColor];
				textView.font = [UIFont systemFontOfSize:14];
				textView.contentOffset = (CGPoint){.x = 0, .y = 4};
				[myiv addSubview:textView];
				[bannerScrollView addSubview:myiv];
				[textView release];
				[myiv release];					                   
			}
		}		
	}else {
		if (recommendNewsArray != nil && [recommendNewsArray count] > 0 && ([indexPath row] - 1) < [recommendNewsArray count]) {
			NSArray *news_ay = [recommendNewsArray objectAtIndex:[indexPath row]-1];
			NSString *piclink = [news_ay objectAtIndex:recommend_news_spic];
			NSString *titletext = [news_ay objectAtIndex:recommend_news_title];
			NSString *detailtext = [news_ay objectAtIndex:recommend_news_desc];
			//int createTime = [[news_ay objectAtIndex:recommend_news_created] intValue];
			NSString *picname = [news_ay objectAtIndex:recommend_news_spic_name];
			
			UILabel *mainTitle = (UILabel*)[cell.contentView viewWithTag:101];
			UILabel *detailTitle = (UILabel*)[cell.contentView viewWithTag:102];
			UIImageView *picView = (UIImageView*)[cell.contentView viewWithTag:103];
			//UILabel *timeLabel = (UILabel*)[cell.contentView viewWithTag:104];
			
			mainTitle.text = titletext;
			detailTitle.text = detailtext;
			
//			NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
//			NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
//			[outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
//			NSString *dateString = [outputFormat stringFromDate:date];
//			timeLabel.text = dateString;
//			[outputFormat release];
			
			UIImage *image = [FileManager getPhoto:picname];
			if (image != nil) {
				picView.image = image;
			}else {
				if ([piclink length] > 0) {
					NSUInteger idx;
					idx = [indexPath row];
					[self startIconDownload:piclink forIndex:[NSIndexPath indexPathForRow:(idx + RECOMMEND_NEWS_PIC_OFFSET) inSection:0]];
				}
			}
		}		
	}

	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (recommendNewsArray != nil && [recommendNewsArray count] > 0) {
		NSArray *ay = [recommendNewsArray objectAtIndex:(indexPath.row - 1)];
		
		NewsDetailViewController *detail = [[NewsDetailViewController alloc] init];
		detail.detailArray = ay;
        detail.commentTotal = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:recommend_news_commentTotal] intValue]];
        detail.isFrom = YES;
		[self.myNavigationController pushViewController:detail animated:YES];
		[detail release];
	}
	
}

- (void)imageTouchFlag
{
    touchFlag = NO;
}

#pragma mark 图片点击事件回调
- (void)imageViewTouchesEnd:(int)picId{
	if (picId >= RECOMMEND_SHOPS_PIC_OFFSET) {
        
        if (touchFlag == NO)  // dufu add 2013.05.02
        {
            touchFlag = YES; // dufu add 2013.05.02
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            
            NSMutableArray *memberArray = [activeMember objectAtIndex:(picId - RECOMMEND_SHOPS_PIC_OFFSET)];
            alertCardViewController *alertCard = [[[alertCardViewController alloc] initWithFrame:window.bounds info:memberArray  userID:[memberArray objectAtIndex:active_member_user_id]] autorelease];
            alertCard.delegate = self;
            [window addSubview:alertCard];
            [alertCard showFromPoint:[self.view center]];
            
            self.senderId = [memberArray objectAtIndex:active_member_user_id];
            self.sourceName = [memberArray objectAtIndex:active_member_user_name];
            self.sourceImage = [memberArray objectAtIndex:active_member_img];
            [self performSelector:@selector(imageTouchFlag) withObject:nil afterDelay:0.5]; // dufu add 2013.05.02
            
        }
	}
	if (picId == SEARCH_PIC_ID) {
		SearchViewController *sc = [[SearchViewController alloc] init];
		sc.selectIndex = 0;
		CustomNavigationController *navController = [[CustomNavigationController alloc]
												 initWithRootViewController:sc];
		
		[navController setModalPresentationStyle:UIModalPresentationCurrentContext]; 
		[self.myNavigationController presentModalViewController:navController animated:YES]; 
		[sc release];
		[navController release];
		
	}
	if (picId >= BANNER_PIC_OFFSET && picId < RECOMMEND_SHOPS_PIC_OFFSET) {
		
		NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											[Common getSecureString],@"keyvalue",
											[NSNumber numberWithInt: SITE_ID],@"site_id",
											[NSNumber numberWithInt:1],@"type",nil];
		[[DataManager sharedManager] accessService:jsontestDic command:PV_COMMAND_ID 
									  accessAdress:@"pvcount.do?param=%@" delegate:self withParam:nil];
        
        NSArray *array = [topAdArray objectAtIndex:picId - 500];
        //NSLog(@"[array objectAtIndex:advertiselist_url]===%@",[array objectAtIndex:advertiselist_url]);
        
        //判断是否为活动
        int infoId = [[array objectAtIndex:advertiselist_info_id] intValue];
        if (infoId != 0)
        {
            activityMainViewController * activityMainView = [[activityMainViewController alloc] init];
            
            if (infoId > 0)
            {
                activityMainView.isFromAd = YES;
                activityMainView.infoId = infoId;
            }
            
            [self.myNavigationController pushViewController:activityMainView animated:YES];
            [activityMainView release];
        }
        else
        {
            NSString *imagename = [array objectAtIndex:advertiselist_image_name];
            UIImage *shareImage = [FileManager getPhoto:imagename];
            
            browserViewController *browser = [[browserViewController alloc] init];
            browser.isShowTool = YES;
            browser.webTitle = [array objectAtIndex:advertiselist_desc];
            browser.url = [array objectAtIndex:advertiselist_url];
            browser.shareImage = shareImage;
            [self.myNavigationController pushViewController:browser animated:YES];
            [browser release];
        }
	}
}

#pragma mark -
#pragma mark AutoScrollViewDelegate 代理
-(void) onCloseButtonClick{
	totalheight -= 50;		
	mainScrollView.contentSize = CGSizeMake(320, totalheight);
	[adScrollView removeFromSuperview];
}
-(void) onAdClick:(int)imageId{
    NSArray *array = [footAdArray objectAtIndex:imageId];
    
    NSString *imagename = [array objectAtIndex:advertiselist_image_name];
    UIImage *shareImage = [FileManager getPhoto:imagename];
    
    //NSLog(@"array===%@",array);
	browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = YES;
    browser.webTitle = [array objectAtIndex:advertiselist_desc];
    browser.shareImage = shareImage;
    browser.url = [array objectAtIndex:advertiselist_url];
	[self.myNavigationController pushViewController:browser animated:YES];
	[browser release];
}

- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	bannerScrollView.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, 0.0f);
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{	

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView{
    if (aScrollView.tag == 5000) {
        CGPoint offset = aScrollView.contentOffset;
        pageControll.currentPage = offset.x / self.view.frame.size.width;
    }
}

#pragma mark 图片下载方法
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader == nil && imageURL != nil && imageURL.length > 1) 
    {
		if (imageURL != nil && imageURL.length > 1) 
		{
			if ([imageDownloadsInProgress count] >= DOWNLOAD_IMAGE_MAX_COUNT) {
				imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL 
																				withIndexPath:index 
																				withImageType:CUSTOMER_PHOTO];
				[imageDownloadsInWaiting addObject:one];
				[one release];
				return;
			}
			
			IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
			iconDownloader.downloadURL = imageURL;
			iconDownloader.indexPathInTableView = index;
			iconDownloader.imageType = CUSTOMER_PHOTO;
			iconDownloader.delegate = self;
			[imageDownloadsInProgress setObject:iconDownloader forKey:index];
			[iconDownloader startDownload];
			[iconDownloader release];   
		}
	}
    
}

#pragma mark 图片下载完成回调方法
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
	int index = [indexPath row];
    
	//下载banner图片
	if (index >= BANNER_PIC_OFFSET && index < RECOMMEND_NEWS_PIC_OFFSET) 
	{
		IconDownLoader *iconDownloader = nil;
		if ([imageDownloadsInProgress count] > 0) {
			iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
		}			
		myImageView *myiv = (myImageView*)[bannerScrollView viewWithTag:index];
		if (iconDownloader != nil)
		{
			if(iconDownloader.cardIcon.size.width>2.0){ 	
				NSArray *ay = [topAdArray objectAtIndex:(index - BANNER_PIC_OFFSET)];
				NSNumber *value = [ay objectAtIndex:advertiselist_imageid];
				
				UIImage *photo = iconDownloader.cardIcon;
				NSString *photoname = [callSystemApp getCurrentTime];
				if ([FileManager savePhoto:photoname withImage:photo]) {
					NSString *imageName = [ay objectAtIndex:advertiselist_image_name];
					[FileManager removeFile:imageName];
					[DBOperate updateData:T_ADVERTISE_LIST 
								tableColumn:@"imageName" columnValue:photoname 
									conditionColumn:@"imageid" conditionColumnValue:value];				
					
					self.topAdArray = [DBOperate queryData:T_ADVERTISE_LIST 
												 theColumn:@"adType" theColumnValue:@"top" withAll:NO];
				}
				myiv.image = photo;	
			}
			[imageDownloadsInProgress removeObjectForKey:indexPath];
			if ([imageDownloadsInWaiting count]>0) {
				imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
				[self startIconDownload:one.imageURL forIndex:one.indexPath];
				[imageDownloadsInWaiting removeObjectAtIndex:0];
			}		
		}
	}
	//下载新闻图片
	else if (index >= RECOMMEND_NEWS_PIC_OFFSET && index < RECOMMEND_SHOPS_PIC_OFFSET) 
	{
		IconDownLoader *iconDownloader = nil;
		if ([imageDownloadsInProgress count] > 0) {
			iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
		}
		NSIndexPath *path = [NSIndexPath indexPathForRow:(index - RECOMMEND_NEWS_PIC_OFFSET) inSection:0];
		
		UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:path];
		UIImageView *newsImageView = (UIImageView*)[cell.contentView viewWithTag:103];
		if (iconDownloader != nil)
		{
			if(iconDownloader.cardIcon.size.width>2.0){ 			
				UIImage *photo = iconDownloader.cardIcon;
				NSString *photoname = [callSystemApp getCurrentTime];
				NSArray *ay = [recommendNewsArray objectAtIndex:(index - RECOMMEND_NEWS_PIC_OFFSET - 1)];
				NSNumber *value = [ay objectAtIndex:recommend_news_nid];
				if ([FileManager savePhoto:photoname withImage:photo]) {
					[DBOperate updateData:T_RECOMMEND_NEWS
							  tableColumn:@"spicname" columnValue:photoname 
						  conditionColumn:@"nid" conditionColumnValue:value];				
					
					self.recommendNewsArray = [DBOperate queryData:T_RECOMMEND_NEWS 
												 theColumn:nil theColumnValue:nil withAll:YES];
				}
				newsImageView.image = photo;	
			}
			[imageDownloadsInProgress removeObjectForKey:iconDownloader.indexPathInTableView];
			if ([imageDownloadsInWaiting count]>0) {
				imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
				[self startIconDownload:one.imageURL forIndex:one.indexPath];
				[imageDownloadsInWaiting removeObjectAtIndex:0];
			}		
		}
	}
	//下载推荐商铺图片
	else if(index >= RECOMMEND_SHOPS_PIC_OFFSET && index < FOOT_AD_PIC_OFFSET){
		IconDownLoader *iconDownloader = nil;
		if ([imageDownloadsInProgress count] > 0) {
			iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
		}

		myImageView *myiv = (myImageView*)[self.recommendScrollView viewWithTag:index];
		UIImageView *imageview = (UIImageView*)[myiv viewWithTag:7000];
		
		if (iconDownloader != nil)
		{
			if(iconDownloader.cardIcon.size.width>2.0){
                
				NSArray *activeMemberArray = [activeMember objectAtIndex:(index - RECOMMEND_SHOPS_PIC_OFFSET)];
                NSString *picurl = [activeMemberArray objectAtIndex:active_member_img];
                NSString *photoname = [Common encodeBase64:(NSMutableData *)[picurl dataUsingEncoding: NSUTF8StringEncoding]];
				UIImage *photo = iconDownloader.cardIcon;
				[FileManager savePhoto:photoname withImage:photo];
                imageview.image = iconDownloader.cardIcon;
			}
			[imageDownloadsInProgress removeObjectForKey:indexPath];
			if ([imageDownloadsInWaiting count]>0) {
				imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
				[self startIconDownload:one.imageURL forIndex:one.indexPath];
				[imageDownloadsInWaiting removeObjectAtIndex:0];
			}
		}
	}
	//下载底部广告图片
	else if (index >= FOOT_AD_PIC_OFFSET)
	{
		IconDownLoader *iconDownloader = nil;
		if ([imageDownloadsInProgress count] > 0) {
			iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
		}
		if (iconDownloader != nil)
		{
			if(iconDownloader.cardIcon.size.width>2.0){
				NSString *photoname = [callSystemApp getCurrentTime];
				UIImage *photo = iconDownloader.cardIcon;
				if([FileManager savePhoto:photoname withImage:photo])
				{
					NSArray *one = [footAdArray objectAtIndex:(index - FOOT_AD_PIC_OFFSET)]; 
					NSNumber *value = [one objectAtIndex:advertiselist_imageid];
					[DBOperate updateData:T_ADVERTISE_LIST tableColumn:@"imageName" 
							  columnValue:photoname conditionColumn:@"imageid" conditionColumnValue:value];				
					self.footAdArray = [DBOperate queryData:T_ADVERTISE_LIST theColumn:@"adType" theColumnValue:@"foot" withAll:NO];
					[adScrollView updateImage:photo picArrayIndex:(index - FOOT_AD_PIC_OFFSET)];
				}			
			}
			[imageDownloadsInProgress removeObjectForKey:indexPath];
			if ([imageDownloadsInWaiting count]>0) {
				imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
				[self startIconDownload:one.imageURL forIndex:one.indexPath];
				[imageDownloadsInWaiting removeObjectAtIndex:0];
			}
			
		}
	}
}

#pragma mark ---- 回调
- (void)feedback
{
    if (_isLogin == YES) {
        MessageDetailViewController *msgDetail = [[MessageDetailViewController alloc] init];
        msgDetail.sourceStr = self.senderId;
        msgDetail.sourceName = self.sourceName;
        msgDetail.sourceImage = self.sourceImage;
        [self.myNavigationController pushViewController:msgDetail animated:YES];
        [msgDetail release];
    }else {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        [self.myNavigationController pushViewController:login animated:YES];
        [login release];
    }
}

- (void)favoriteLogin
{
    LoginViewController *login = [[LoginViewController alloc] init];
    login.delegate = self;
    [self.myNavigationController pushViewController:login animated:YES];
    [login release];
}

- (void)goUrl:(NSString *)url
{
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = url;
    [self.myNavigationController pushViewController:browser animated:YES];
    [browser release];
}

#pragma mark-----LoginViewDelegate method
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    
}

@end
