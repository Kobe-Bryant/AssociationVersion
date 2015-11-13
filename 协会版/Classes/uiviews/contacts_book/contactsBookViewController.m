//
//  contactsBookViewController.m
//  xieHui
//
//  Created by lai yun on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "contactsBookViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "alertCardViewController.h"
#import "CustomTabBar.h"
#import "contactsBookCatViewController.h"
#import "MessageDetailViewController.h"
#import "browserViewController.h"

#define MARGIN 5.0f

@implementation contactsBookViewController

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
    
    //注册监视load通讯录的线程
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateMember) 
                                                 name:@"loadContactsBooks" 
                                               object:nil];	
	
	self.view.backgroundColor = [UIColor clearColor];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
	
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //判断是否已经获取到通讯录数据 
    if(is_get_contacts_book_done)
    {
        [self updateMember];
    }
    else
    {
        //添加loading图标 等待广播
        UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, self.view.frame.size.height / 2.0)];
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
        
        //[self accessItemService];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.searchDisplay.active = NO;
}

//添加数据表视图
-(void)addTableView:(CGRect)tableFrame;
{
	//[self.currentTableView removeFromSuperview];
    
    //初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:tableFrame];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
	[self.view sendSubviewToBack:self.myTableView];
	//[self.myTableView reloadData];
    
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
        self.searchDisplay = [[MySearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
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
    if (IOS_VERSION < 7.0) return;
    
    if (type) 
    {
        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
        {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            tabViewController.customTab.hidden = YES;
//            [tabViewController.view setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , 460.0f)];
//            [tabViewController.customTab setFrame:CGRectMake( 0.0f , 431.0f , 320.0f , 49.0f)];
        }
    }
    else
    {
        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
        {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            tabViewController.customTab.hidden = NO;
            //[tabViewController.view setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , 416.0f)];
            //[tabViewController.customTab setFrame:CGRectMake( 0.0f , 367.0f , 320.0f , 49.0f)];
            
//            CGRect customTabFrame = tabViewController.customTab.frame;
//            customTabFrame.origin.y = 367.0f;
//            
//            // animations settings
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationBeginsFromCurrentState:YES];
//            [UIView setAnimationDuration:0.25];
//            [UIView setAnimationCurve:0];
//            [UIView setAnimationDelegate:self];
//            [UIView setAnimationDidStopSelector:@selector(setTabViewControllerHeight)];
//            
//            // set views with new info
//            tabViewController.customTab.frame = customTabFrame;
//            
//            // commit animations
//            [UIView commitAnimations];
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
	return [memberArray objectAtIndex:contacts_book_img];
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
	
	NSString *key = [self.keys objectAtIndex:[indexPath section]];  
    NSMutableArray *memberSectionArray = [self.dicMember objectForKey:key];
    int sectionArrayCount = [memberSectionArray count];
	
	if (sectionArrayCount > [indexPath row]) 
	{
		NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
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

//网络获取数据
//-(void)accessItemService
//{
//	NSString *reqUrl = @"maillist.do?param=%@";
//    
//    NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
//								 [Common getSecureString],@"keyvalue",
//								 [Common getVersion:OPERAT_CONTACTS_BOOK_REFRESH],@"ver",
//								 [NSNumber numberWithInt: SITE_ID],@"site_id",
//                                 [NSNumber numberWithInt: 0],@"info_id",
//								 nil];
//	
//	[[DataManager sharedManager] accessService:jsontestDic
//									   command:OPERAT_CONTACTS_BOOK_REFRESH 
//								  accessAdress:reqUrl 
//									  delegate:self
//									 withParam:nil];
//}

//更新商铺的操作
-(void)updateMember
{
    //查询数据库 获取到数据
    if (self.catId != nil && [self.catId intValue] != 0)
    {
        //取分类名称
        NSMutableArray *catItems = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK_CAT theColumn:@"id" theColumnValue:self.catId withAll:NO];
        
        if ([catItems count] > 0) 
        {
            NSArray *catArray = [catItems objectAtIndex:0];
            self.title = [catArray objectAtIndex:shop_cat_name];
        }
        
        self.allMemberItems = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK theColumn:@"cat_id" theColumnValue:self.catId withAll:NO];
        
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
    else 
    {
        self.allMemberItems = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK theColumn:nil theColumnValue:nil withAll:YES];
        
        self.memberItems = self.allMemberItems;
        
        //转化数据
        [self makeMemberDictionary];
        
        //移出loading
        [self.spinner removeFromSuperview];
        
        //添加表视图
        CGFloat fixHeight = [UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f - 44.0f - 49.0f;
        CGRect tableFrame = CGRectMake( 0.0f , 44.0f , 320.0f , fixHeight);
        [self addTableView:tableFrame];
    }
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
//	switch(commandid)
//    {
//        case OPERAT_CONTACTS_BOOK_REFRESH:
//            [self performSelectorOnMainThread:@selector(updateMember) withObject:nil waitUntilDone:NO];
//            break;
//            
//        default:   ;
//    }
}

#pragma mark -
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
    
    NSMutableArray *memberSectionArray;
    int sectionArrayCount;
    
	int countItems =  [self.memberItems count];
	if (self.memberItems != nil && countItems > 0)
    {
        //记录
        CellIdentifier = @"listCell";
        
        NSString *key = [self.keys objectAtIndex:[indexPath section]];  
        memberSectionArray = [self.dicMember objectForKey:key];
        sectionArrayCount = [memberSectionArray count];
    }
    else
    {
        //没有记录
        CellIdentifier = @"noneCell";
        memberSectionArray = nil;
        sectionArrayCount = 0;
    }
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//tableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.backgroundView = 
		//cell.selectedBackgroundView =
        
        //ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
		
        if (self.memberItems != nil && countItems > 0)
        {     
            //tableView.separatorColor = [UIColor clearColor];
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
            noneLabel.text = @"没找到相关记录！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLabel];
            [noneLabel release];
        }
		
	}
	
	if ([indexPath row] != sectionArrayCount && sectionArrayCount != 0)
    {
		tableView.separatorColor = [UIColor clearColor];
		UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
		UIImageView *backImage = (UIImageView *)[cell.contentView viewWithTag:101];
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:103];
		UILabel *postLabel = (UILabel *)[cell.contentView viewWithTag:104];
		UILabel *companyLabel = (UILabel *)[cell.contentView viewWithTag:105];
		
		NSArray *memberArray = [memberSectionArray objectAtIndex:[indexPath row]];
		NSString *piclink = [memberArray objectAtIndex:contacts_book_img];
        
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
		
		nameLabel.text = [memberArray objectAtIndex:contacts_book_user_name];
        cityLabel.text = [memberArray objectAtIndex:contacts_book_city];
		postLabel.text = [memberArray objectAtIndex:contacts_book_post];
		companyLabel.text = [memberArray objectAtIndex:contacts_book_company_name];
	
    }
    else 
    {
        tableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
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
        
        if (memberArray != nil && [memberArray count] > 0)
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            alertCardViewController *alertCard = [[[alertCardViewController alloc] initWithFrame:window.bounds info:memberArray userID:[memberArray objectAtIndex:contacts_book_user_id]] autorelease];
            alertCard.delegate = self;
            [window addSubview:alertCard];
            [alertCard showFromPoint:[self.view center]];
            
            self.senderId = [memberArray objectAtIndex:contacts_book_user_id];
            self.sourceName = [memberArray objectAtIndex:contacts_book_user_name];
            self.sourceImage = [memberArray objectAtIndex:contacts_book_img];
        }
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
    [self changeCustomTabBar:YES];
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
    
    [self changeCustomTabBar:NO];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	//end do any thing...
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
}

#pragma mark ---- 回调
- (void)feedback
{
    self.searchDisplay.active = NO;
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
    self.searchDisplay.active = NO;
    LoginViewController *login = [[LoginViewController alloc] init];
    login.delegate = self;
    [self.navigationController pushViewController:login animated:YES];
    [login release];
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

#pragma mark-----LoginViewDelegate method
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    
}
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
    self.allMemberItems = nil;
    self.activeMember = nil;
    self.dicMember = nil;
    self.catId = nil;
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
    self.allMemberItems = nil;
    self.activeMember = nil;
    self.dicMember = nil;
    self.catId = nil;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end