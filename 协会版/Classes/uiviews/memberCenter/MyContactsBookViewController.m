//
//  MyContactsBookViewController.m
//  xieHui
//
//  Created by 来 云 on 12-11-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyContactsBookViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "alertCardViewController.h"
#import "CustomTabBar.h"
#import "MessageDetailViewController.h"
#import "browserViewController.h"

#define MARGIN 5.0f
@interface MyContactsBookViewController ()

@end

@implementation MyContactsBookViewController
@synthesize myTableView;
@synthesize currentTableView;
@synthesize memberItems;
@synthesize allMemberItems;
@synthesize activeMember;
@synthesize dicMember;
@synthesize catId;
@synthesize keys;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize spinner;
@synthesize searchBar;
@synthesize searchDisplay;
@synthesize rowValue;
@synthesize indexPathValue;
@synthesize senderId;
@synthesize sourceName;
@synthesize sourceImage;

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
    
    if (IOS_VERSION >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    self.title = @"我的名片夹";
	
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
	
	//数据初始化
	NSMutableArray *tempMemberArray = [[NSMutableArray alloc] init];
	self.memberItems = tempMemberArray;
	[tempMemberArray release];
    
    NSMutableArray *tempAllMemberArray = [[NSMutableArray alloc] init];
	self.allMemberItems = tempAllMemberArray;
	[tempAllMemberArray release];
    
    NSMutableDictionary *tempDicMember = [[NSMutableDictionary alloc] init];
	self.dicMember = tempDicMember;
	[tempDicMember release];
    
    NSMutableArray *tempKeys = [[NSMutableArray alloc] init];
	self.keys = tempKeys;
	[tempKeys release];
    
    //取所有活跃会员
    self.activeMember = (NSMutableArray *)[DBOperate selectActiveMember];
    
    //判断是否已经获取到通讯录数据 
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
    
    [self accessItemService];

}
//添加数据表视图
-(void)addTableView:(CGRect)tableFrame;
{
	//[self.myTableView removeFromSuperview];
    
    //初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:tableFrame];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
	[self.view sendSubviewToBack:self.myTableView];
	[self.myTableView reloadData];
    
    //ios7 去掉索引的背景色
    if (IOS_VERSION >= 7.0) {
        if ([self.myTableView respondsToSelector:@selector(setSectionIndexColor:)]) {
            self.myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
            self.myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        }
    }
    
    //添加字母显示
    UIView *letterView = [[UIView alloc] initWithFrame:CGRectMake( (self.view.frame.size.width / 2) - 40 , ([UIScreen mainScreen].bounds.size.height / 2) - 80.0f , 80.0f , 80.0f)];
    
    UIImageView *letterBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 80.0f , 80.0f)];
    UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"字母背景" ofType:@"png"]];
    letterBackImageView.image = backImage;
    [backImage release];
    [letterView addSubview:letterBackImageView];
    [letterBackImageView release];
    
    UILabel *letterLabel = [[UILabel alloc] initWithFrame: CGRectMake( 20.0f , 20.0f  , 40.0f , 40.0f)];
	letterLabel.textColor = [UIColor whiteColor];
	letterLabel.backgroundColor = [UIColor clearColor];
	letterLabel.font = [UIFont systemFontOfSize: 38];
	letterLabel.textAlignment = UITextAlignmentCenter;
    letterLabel.tag = 1001;
	[letterView addSubview: letterLabel];
    [letterLabel release];
    
    letterView.tag = 1000;
    letterView.alpha = 0.0;
    [self.view addSubview:letterView];
    [letterView release];
    
    
    //添加搜索插件
    if ([self.memberItems count] != 0) 
    {
        // Create a search bar
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
        self.searchBar.backgroundImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"通讯录搜索背景" ofType:@"png"]];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchBar.keyboardType = UIKeyboardTypeDefault;
        self.searchBar.delegate = self;
        //self.myTableView.tableHeaderView = self.searchBar;
        [self.view addSubview:self.searchBar];
        
        // Create the search display controller
        self.searchDisplay = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
        self.searchDisplay.delegate = self;
        self.searchDisplay.searchResultsDataSource = self;
        self.searchDisplay.searchResultsDelegate = self;
    }
    else
    {
        [self.myTableView setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , self.view.frame.size.height)];
    }
    
    self.currentTableView = self.myTableView;
}

//通讯录数据转化
-(void)makeMemberDictionary
{
    //先清空数据
    [self.dicMember removeAllObjects];
    [self.keys removeAllObjects];
    
    NSMutableDictionary *memberDic = [[NSMutableDictionary alloc] init];
    
    //NSDictionary
    for(NSArray *memberArray in self.memberItems)
    {
        NSString *letter = [memberArray objectAtIndex:contacts_book_letter];
        NSMutableArray *letterArray = [memberDic valueForKey:letter];
        if (letterArray == nil) 
        {
            NSMutableArray *infoArray = [[NSMutableArray alloc] init];
            [infoArray addObject:memberArray];
            [memberDic setObject:infoArray forKey:letter];
            [infoArray release];
        }
        else 
        {
            [letterArray addObject:memberArray];
        }
    }
    self.dicMember = memberDic;
    [memberDic release];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObjectsFromArray:[[self.dicMember allKeys] 
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.keys = keyArray;
    [keyArray release];
    
}

//更改自定义tabbar的位置
-(void)changeCustomTabBar:(BOOL)type
{
    if (type) 
    {
        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
        {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            [tabViewController.view setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , 460.0f)];
            [tabViewController.customTab setFrame:CGRectMake( 0.0f , 431.0f , 320.0f , 49.0f)];
        }
    }
    else
    {
        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
        {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            //[tabViewController.view setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , 416.0f)];
            //[tabViewController.customTab setFrame:CGRectMake( 0.0f , 367.0f , 320.0f , 49.0f)];
            
            CGRect customTabFrame = tabViewController.customTab.frame;
            customTabFrame.origin.y = 367.0f;
            
            // animations settings
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:0];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(setTabViewControllerHeight)];
            
            // set views with new info
            tabViewController.customTab.frame = customTabFrame;
            
            // commit animations
            [UIView commitAnimations];
        }
    }
}

//开始搜索数据
-(void)searching:(NSString *)keyword
{
    self.memberItems = nil;
    NSMutableArray *searchResult = [[NSMutableArray alloc]init];
    
    for(NSArray *memberArray in self.allMemberItems)
    {
        NSString *name = [memberArray objectAtIndex:contacts_book_user_name];
        NSString *post = [memberArray objectAtIndex:contacts_book_post];
        NSString *company_name = [memberArray objectAtIndex:contacts_book_company_name];
        NSString *letter = [memberArray objectAtIndex:contacts_book_letter];
        
        if ([name rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound || [post rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound || [company_name rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound || [letter rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [searchResult addObject:memberArray];
        }
    }
    
    self.memberItems = searchResult;
    [searchResult release];
    
    //转化数据
    [self makeMemberDictionary];
}

//滚动loading图片
- (void)loadImagesForOnscreenRows
{
	//NSLog(@"load images for on screen");
    if (self.memberItems != nil && [self.memberItems count] > 0) 
    {
        NSArray *visiblePaths = [self.currentTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSString *key = [self.keys objectAtIndex:[indexPath section]];  
            NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
            int sectionArrayCount = [memberSectionArray count];
            if (sectionArrayCount > [indexPath row])
            {
                //获取本地图片缓存
                UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
                
                UITableViewCell *cell = [self.currentTableView cellForRowAtIndexPath:indexPath];
                UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
                
                if (cardIcon == nil)
                {
                    if (self.currentTableView.dragging == NO && self.currentTableView.decelerating == NO)
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
}

//获取图片链接
-(NSString*)getPhotoURL:(NSIndexPath *)indexPath
{
    NSString *key = [self.keys objectAtIndex:[indexPath section]];  
    NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
    
	NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
	return [memberArray objectAtIndex:contactsbook_favorite_img];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	
	NSString *key = [self.keys objectAtIndex:[indexPath section]];  
    NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
    int sectionArrayCount = [memberSectionArray count];
	
	if (sectionArrayCount > [indexPath row]) 
	{
		NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[memberArray objectAtIndex:contactsbook_favorite_img] dataUsingEncoding: NSUTF8StringEncoding]];
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
	
	NSString *key = [self.keys objectAtIndex:[indexPath section]];  
    NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
    int sectionArrayCount = [memberSectionArray count];
	
	if (sectionArrayCount > [indexPath row]) 
	{
		NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[memberArray objectAtIndex:contactsbook_favorite_img] dataUsingEncoding: NSUTF8StringEncoding]];
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
        UITableViewCell *cell = [self.currentTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.memberItems = nil;
    self.activeMember = nil;
    self.dicMember = nil;
    self.keys = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.currentTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.spinner = nil;
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.searchDisplay.delegate = nil;
    self.searchDisplay = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
}

- (void)dealloc {
	self.memberItems = nil;
    self.activeMember = nil;
    self.dicMember = nil;
    self.keys = nil;
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.currentTableView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.spinner = nil;
    self.searchBar.delegate = nil;
    self.searchBar = nil;
    self.searchDisplay.delegate = nil;
    self.searchDisplay = nil;
    self.senderId = nil;
    self.sourceName = nil;
    self.sourceImage = nil;
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ----private methods
- (void)accessItemService
{
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [Common getMemberVersion:_userId commandID:MEMBER_FAVRITEBOOKLIST_COMMAND_ID],@"ver",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        [NSNumber numberWithInt:5],@"type",
                                        [NSNumber numberWithInt:0],@"favorite_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVRITEBOOKLIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	//NSLog(@"=====%@",resultArray);
	switch (commandid) {
		case MEMBER_FAVRITEBOOKLIST_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
			
		}
			break;
        case MEMBER_FAVORITEDELETE_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(deleteResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
        default:
			break;
	}
}

- (void)update
{
    NSString *memberId = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId];
    //查询数据库 获取到数据
    self.allMemberItems = (NSMutableArray *)[DBOperate queryData:T_CONTACTSBOOK_FAVORITE theColumn:@"memberId" theColumnValue:memberId withAll:NO];
    
    self.memberItems = self.allMemberItems;
    
    //转化数据
    [self makeMemberDictionary];
    
    //移出loading
    [self.spinner removeFromSuperview];
    
    //添加表视图
    CGFloat fixHeight = [UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f - 44.0f;
    CGRect tableFrame = CGRectMake( 0.0f , 44.0f , 320.0f , fixHeight);
    [self addTableView:tableFrame];

}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.memberItems count] == 0)
    {
        return 1;
    }
    else 
    {
        return [self.keys count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplay.searchResultsTableView)
    {
        return nil;
    }
    else 
    {
        if ([self.memberItems count] == 0)
        {
            return nil;
        }
        else 
        {
            NSString *key = [self.keys objectAtIndex:section];
            return key;
        }
    }
}  

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView  
{
    if (tableView == self.searchDisplay.searchResultsTableView)
    {
        return nil;
    }
    else 
    {
        if ([self.memberItems count] == 0)
        {
            return nil;
        }
        else 
        {
            //UITableViewIndexSearch 
            return self.keys;
        }
    }
} 


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.memberItems count] == 0)
    {
        return 1;
    }
    else
    {
        NSString *key = [self.keys objectAtIndex:section];  
        NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
        return [memberSectionArray count];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.memberItems != nil && [self.memberItems count] > 0)
    {
        //记录
        return 62.0f;
    }
    else
    {
        //没有记录
        return 50.0f;
    }
	
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    UIView *letterView = [self.view viewWithTag:1000];
    UILabel *letterLabel = (UILabel *)[letterView viewWithTag:1001];
	letterView.alpha = 1.0;
	letterLabel.text = title;
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 1.0];
	letterView.alpha = 0.0;
	[UIView commitAnimations];
	
	return (NSInteger)[self.keys indexOfObject: title];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
    NSString *key = nil;
	if (self.keys != nil && [self.keys count] > 0) {
        key = [self.keys objectAtIndex:[indexPath section]];
    }
    NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
    int sectionArrayCount = [memberSectionArray count];
    
	int countItems =  [self.memberItems count];
	if (self.memberItems != nil && countItems > 0)
    {
        //记录
        CellIdentifier = @"listCell";
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
		tableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.backgroundView = 
		//cell.selectedBackgroundView = 
		
        if (self.memberItems != nil && countItems > 0)
        {     
            tableView.separatorColor = [UIColor clearColor];
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
        else
        {
            UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
            noneLabel.tag = 201;
            [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
            noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
            noneLabel.text = @"没找到任何记录！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLabel];
            [noneLabel release];
        }
		
	}
	
	if ([indexPath row] != sectionArrayCount && sectionArrayCount != 0){
		
		UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
		UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:101];
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:103];
		UILabel *postLabel = (UILabel *)[cell.contentView viewWithTag:104];
		UILabel *companyLabel = (UILabel *)[cell.contentView viewWithTag:105];
		
		NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
		NSString *piclink = [memberArray objectAtIndex:contactsbook_favorite_img];
        
        //名字间距
        NSString *nameString = [memberArray objectAtIndex:contacts_book_user_name];
        CGSize constraint = CGSizeMake(20000.0f, 20.0f);
        CGSize size = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat fixWidth = size.width + 10.0f;
        
		if (piclink)
		{
			[nameLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f, MARGIN * 2, cell.frame.size.width-200.0f-6 * MARGIN, 20)];
            
            [cityLabel setFrame:CGRectMake(MARGIN * 2 + 165.0f, MARGIN * 2 + 20, cell.frame.size.width-180.0f-6 * MARGIN, 20)];
			
			[postLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f + fixWidth, MARGIN * 2, cell.frame.size.width-100.0f-6 * MARGIN, 20)];
			
			[companyLabel setFrame:CGRectMake(MARGIN * 2 + 50.0f, MARGIN * 6 + 2, cell.frame.size.width-100.0f-6 * MARGIN, 20)];
			
			[picView setFrame:CGRectMake(MARGIN, MARGIN, photoWith, photoHigh)];
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:indexPath]fillSize:CGSizeMake(photoWith, photoHigh)];
			
			if (cardIcon == nil)
			{
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员默认头像" ofType:@"png"]];
				picView.image = [img fillSize:CGSizeMake(photoWith, photoHigh)];
				[img release];
				if (tableView.dragging == NO && tableView.decelerating == NO)
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
            
            [cityLabel setFrame:CGRectMake(MARGIN * 2 + 165.0f, MARGIN * 2 + 20, cell.frame.size.width-180.0f-6 * MARGIN, 20)];
			
			[postLabel setFrame:CGRectMake(MARGIN * 2 + fixWidth, MARGIN * 2, cell.frame.size.width-60.0f-6 * MARGIN, 20)];
			
			[companyLabel setFrame:CGRectMake(MARGIN * 2, MARGIN * 6 + 2, cell.frame.size.width-60.0f-6 * MARGIN, 20)];
			
		}
		
		nameLabel.text = [memberArray objectAtIndex:contactsbook_favorite_user_name];
        cityLabel.text = [memberArray objectAtIndex:contactsbook_favorite_city];
		postLabel.text = [memberArray objectAtIndex:contactsbook_favorite_post];
		companyLabel.text = [memberArray objectAtIndex:contactsbook_favorite_company_name];
	}
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.memberItems count] > 0)
    {
        if (tableView == self.searchDisplay.searchResultsTableView)
        {
            [self.searchDisplay.searchBar resignFirstResponder];
        }
        
        NSString *key = [self.keys objectAtIndex:[indexPath section]];  
        NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
        NSMutableArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
        
        if (memberArray != nil)
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            alertCardViewController *alertCard = [[[alertCardViewController alloc] initWithFrame:window.bounds info:memberArray userID:[memberArray objectAtIndex:contactsbook_favorite_user_id]] autorelease];
            alertCard.delegate = self;
            [window addSubview:alertCard];
            [alertCard showFromPoint:[self.view center]];
            
            self.senderId = [memberArray objectAtIndex:contactsbook_favorite_user_id];
            self.sourceName = [memberArray objectAtIndex:contactsbook_favorite_user_name];
            self.sourceImage = [memberArray objectAtIndex:contactsbook_favorite_img];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView != self.searchDisplay.searchResultsTableView)
    {
        NSString *key = [self.keys objectAtIndex:[indexPath section]];  
        NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
        NSMutableArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
        
        //rowValue = indexPath.row;
        self.indexPathValue = indexPath;
        int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
        infoId = [memberArray objectAtIndex:contactsbook_favorite_id];
        
        NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [Common getSecureString],@"keyvalue",
                                            [NSNumber numberWithInt: SITE_ID],@"site_id",
                                            [NSNumber numberWithInt:_userId],@"user_id",
                                            [NSNumber numberWithInt:5],@"type",
                                            infoId,@"info_id",nil];
        
        [[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVORITEDELETE_COMMAND_ID accessAdress:@"/member/delfavorite.do?param=%@" delegate:self withParam:jsontestDic];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (tableView != self.searchDisplay.searchResultsTableView)
    {
        return UITableViewCellEditingStyleDelete; 
    }
    else 
    {
        return UITableViewCellEditingStyleNone;
    }
} 

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
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

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.currentTableView = self.searchDisplay.searchResultsTableView;
    //[self changeCustomTabBar:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	//NSLog(@"=========cancel");	
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self searching:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    
    [self searching:[self.searchDisplayController.searchBar text]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.currentTableView = self.myTableView;
    self.memberItems = self.allMemberItems;
    
    //转化数据
    [self makeMemberDictionary];
    
    //[self changeCustomTabBar:NO];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	//end do any thing...
}

#pragma mark-----cardDetailDelegate method
- (void)feedback
{
    self.searchDisplay.active = NO;
    MessageDetailViewController *msgDetail = [[MessageDetailViewController alloc] init];
    msgDetail.sourceStr = self.senderId;
    msgDetail.sourceName = self.sourceName;
    msgDetail.sourceImage = self.sourceImage;
    [self.navigationController pushViewController:msgDetail animated:YES];
    [msgDetail release];
}

- (void)goUrl:(NSString *)url
{
    self.searchDisplay.active = NO;
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = url;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

- (void)deleteResult:(NSMutableArray *)resultArray
{
	int retInt = [[[resultArray objectAtIndex:0] objectAtIndex:0] intValue];
	if (retInt == 1) {
		[DBOperate deleteData:T_CONTACTSBOOK_FAVORITE tableColumn:@"id" columnValue:infoId];
		
        //NSLog(@"[indexPathValue section]=====%d",[indexPathValue section]);
        NSString *key = [self.keys objectAtIndex:[self.indexPathValue section]];  
        NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
        NSMutableArray *memberArray = [memberSectionArray objectAtIndex:[self.indexPathValue row]];
        [memberArray removeObjectAtIndex:indexPathValue.row];
        
        [self.allMemberItems removeAllObjects];
        [self.dicMember removeAllObjects];
        
        NSString *memberId = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId];
        //查询数据库 获取到数据
        self.allMemberItems = (NSMutableArray *)[DBOperate queryData:T_CONTACTSBOOK_FAVORITE theColumn:@"memberId" theColumnValue:memberId withAll:NO];
        
        self.memberItems = self.allMemberItems;
        //转化数据
        [self makeMemberDictionary];
        [self.myTableView reloadData];
		
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

@end
