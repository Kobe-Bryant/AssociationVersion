    //
//  aboutUsViewController.m
//  Profession
//
//  Created by siphp on 12-8-24.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "aboutUsViewController.h"
#import "Common.h"
#import "UIImageScale.h"
#import "callSystemApp.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "browserViewController.h"
#import "BaiduMapViewController.h"
@implementation aboutUsViewController

@synthesize scrollView;
@synthesize spinner;
@synthesize aboutUsItems;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
//	self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
	self.title = @"关于我们";
	
	logoWith = 300.0f;
	logoHigh = 80.0f;
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
	
	//关于我们数据初始化
	NSMutableArray *tempAboutUsArray = [[NSMutableArray alloc] init];
	self.aboutUsItems = tempAboutUsArray;
	[tempAboutUsArray release];

	UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height - 44.0f)];
	tmpScroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 44.0f);
	tmpScroll.pagingEnabled = NO;
	tmpScroll.showsHorizontalScrollIndicator = NO;
	tmpScroll.showsVerticalScrollIndicator = NO;
	tmpScroll.bounces = YES;
	self.scrollView = tmpScroll;
	[self.view addSubview:self.scrollView];
	[tmpScroll release];  
	
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
	[self.scrollView addSubview:self.spinner];
	[self.spinner startAnimating];
	[tempSpinner release];
	
	//网络获取
	[self accessItemService];
}

//拨打电话
-(void)callPhone
{
	NSMutableArray *aboutUsInfo = [self.aboutUsItems objectAtIndex:0];
	NSString *tel = [[aboutUsInfo objectAtIndex:aboutus_info_tel] length] > 1 ? [aboutUsInfo objectAtIndex:aboutus_info_tel] : [aboutUsInfo objectAtIndex:aboutus_info_mobile];
	if (tel.length > 1)
	{
		[callSystemApp makeCall:tel];
	}
}

//官方微博  dufu  add  2013.05.02
-(void)weiboOpen
{
	browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = [[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_weibo];
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

//官方网站  dufu  add  2013.05.02
-(void)websiteOpen
{
	browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = [[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_url];
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}


//发送邮件
-(void)sendEmail
{
	NSString *mail = [[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_mail];
	if (mail.length > 1) 
	{
		//收件人，cc：抄送  subject：主题   body：内容
		[callSystemApp sendEmail:mail cc:@"" subject:SHARE_CONTENTS body:@""];
	}
}

//打开地图
-(void)showMapByCoord
{
	BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc] init];
    baiduMap.latitude = [[[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_lat] doubleValue];
    baiduMap.longitude = [[[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_lng] doubleValue];
    baiduMap.addrStr = [[self.aboutUsItems objectAtIndex:0] objectAtIndex:aboutus_info_address];
    NSMutableArray *aboutUsInfo = [self.aboutUsItems objectAtIndex:0];
	baiduMap.phone = [[aboutUsInfo objectAtIndex:aboutus_info_tel] length] > 1 ? [aboutUsInfo objectAtIndex:aboutus_info_tel] : [aboutUsInfo objectAtIndex:aboutus_info_mobile];
    baiduMap.title = @"企业地址";
    baiduMap.navigationItem.title = @"我的位置";
    [self.navigationController pushViewController:baiduMap animated:YES];
    [baiduMap release];
}

//获取本地缓存的图片
-(UIImage*)getPhoto:(NSIndexPath *)indexPath
{
	NSMutableArray *aboutUsInfo = [self.aboutUsItems objectAtIndex:0];
	NSString *picName = [Common encodeBase64:(NSMutableData *)[[aboutUsInfo objectAtIndex:aboutus_info_logo] dataUsingEncoding: NSUTF8StringEncoding]];
	if (picName.length > 1) {
		return [FileManager getPhoto:picName];
	}
	else {
		return nil;
	}
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
	NSMutableArray *aboutUsInfo = [self.aboutUsItems objectAtIndex:0];
	NSString *picName = [Common encodeBase64:(NSMutableData *)[[aboutUsInfo objectAtIndex:aboutus_info_logo] dataUsingEncoding: NSUTF8StringEncoding]];
	
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
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{ 
			//保存图片
			[self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
			
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(logoWith, logoHigh)];
			UIImageView *picView = (UIImageView *)[self.scrollView viewWithTag:100];
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
	NSString *reqUrl = @"more/about.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getVersion:OPERAT_ABOUTUS_INFO],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic 
									   command:OPERAT_ABOUTUS_INFO
								  accessAdress:reqUrl 
									  delegate:self 
									 withParam:nil];
}

//更新数据的操作
-(void)updateAboutUs
{
	//移出loading提示
	[self.spinner removeFromSuperview];
	
	//读取关于我们数据
	self.aboutUsItems = (NSMutableArray *)[DBOperate queryData:T_ABOUTUS_INFO theColumn:@"" theColumnValue:@""  withAll:YES];
	
	if ([self.aboutUsItems count] != 0) 
	{
		NSMutableArray *aboutUsInfo = [self.aboutUsItems objectAtIndex:0];
		
		//构建视图
		UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 10.0f, logoWith, logoHigh)];
		picView.tag = 100;
		[self.scrollView addSubview:picView];
		[picView release];
		
		//loading商铺logo图片
		UIImageView *logoPicView = (UIImageView *)[self.scrollView viewWithTag:100];
		NSString *logoUrl = [aboutUsInfo objectAtIndex:aboutus_info_logo];
		if (logoUrl.length > 1) 
		{
			NSIndexPath *logoIndexPath = [NSIndexPath indexPathForRow:10000 inSection:0];
			
			//获取本地图片缓存
			UIImage *cardIcon = [[self getPhoto:logoIndexPath]fillSize:CGSizeMake(logoWith, logoHigh)];
			if (cardIcon == nil)
			{
				UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多默认logo" ofType:@"png"]];
				logoPicView.image = [img fillSize:CGSizeMake(logoWith, logoHigh)];
				[img release];
				
				[self startIconDownload:logoUrl forIndexPath:logoIndexPath];
			}
			else
			{
				logoPicView.image = cardIcon;
			}
			
		}
		else
		{
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多默认logo" ofType:@"png"]];
			logoPicView.image = [img fillSize:CGSizeMake(logoWith, logoHigh)];
			[img release];
		}
        
        //内容
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[contentLabel setFont:[UIFont systemFontOfSize:14.0f]];
		contentLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.lineBreakMode = UILineBreakModeWordWrap;
		contentLabel.numberOfLines = 0;
		NSString *contentText = [aboutUsInfo objectAtIndex:aboutus_info_content];
		contentLabel.text = contentText;
		CGSize constraint = CGSizeMake(280.0f, 20000.0f);
		CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
		float fixHeight = size.height + 10.0f;
		fixHeight = fixHeight == 0 ? 30.f : MAX(fixHeight,30.0f);
		[contentLabel setFrame:CGRectMake(20.0f, 100.0f, 280.0f, fixHeight)];
		[self.scrollView addSubview:contentLabel];
		[contentLabel release];
        
        // dufu  add  2013.05.02
        CGFloat buttonHeight = 44.f;
        CGFloat height = 100.f + fixHeight;
        // 电话号码button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10.f, height, 300.f, buttonHeight);
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形上" ofType:@"png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        // 拨打的start icon
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
        UIImage *callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"电话icon" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 拨打的end icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 电话号码label
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 200.0f, 44.0f)];
		label.font = [UIFont systemFontOfSize:16];
		label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0];
		label.text = [[aboutUsInfo objectAtIndex:aboutus_info_tel] length] > 1 ? [aboutUsInfo objectAtIndex:aboutus_info_tel] : [aboutUsInfo objectAtIndex:aboutus_info_mobile];
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
		[button addSubview:label];
		[label release];
        
        height += buttonHeight;
        
        // 官方微博button
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10.f, height, 300.f, buttonHeight);
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形中" ofType:@"png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(weiboOpen) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        // 官方微博的start icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多微博设置icon" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 官方微博的end icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_向右箭头" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 官方微博label
        label = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 200.0f, 44.0f)];
		label.font = [UIFont systemFontOfSize:16];
		label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0];
		label.text = @"官方微博";
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
		[button addSubview:label];
		[label release];
        
        height += buttonHeight;
        
        // 官方网站button
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10.f, height, 300.f, buttonHeight);
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形中" ofType:@"png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(websiteOpen) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        // 官方网站的start icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"网站icon" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 官方网站的end icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_向右箭头" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 官方网站label
        label = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 200.0f, 44.0f)];
		label.font = [UIFont systemFontOfSize:16];
		label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0];
		label.text = @"官方网站";
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
		[button addSubview:label];
		[label release];
        
        height += buttonHeight;
        
        // 地址button
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10.f, height, 300.f, buttonHeight);
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形下" ofType:@"png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showMapByCoord) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        // 地址的start icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_关于我们_公司地址" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 地址的end icon
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.0f, 8.0f, 30, 30)];
        callImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"定位icon" ofType:@"png"]];
        imageView.image = callImage;
        [button addSubview:imageView];
        [imageView release];
        // 地址label
        label = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 200.0f, 44.0f)];
		label.font = [UIFont systemFontOfSize:16];
		label.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0];
		label.text = [aboutUsInfo objectAtIndex:aboutus_info_address];
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
        if ([[aboutUsInfo objectAtIndex:aboutus_info_address] length] < 10)
        {
            label.font = [UIFont systemFontOfSize:16];
            label.numberOfLines = 1;
        }
        else if([[aboutUsInfo objectAtIndex:aboutus_info_address] length] < 25)
        {
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 2;
        }
        else
        {
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 2;
        }
        [button addSubview:label];
		[label release];
        
        height += buttonHeight;
        
		self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height + 10.0f);
		
	}
	
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
	[self performSelectorOnMainThread:@selector(updateAboutUs) withObject:nil waitUntilDone:NO];
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
    self.scrollView = nil;
	self.spinner = nil;
	self.aboutUsItems = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
}


- (void)dealloc {
	self.scrollView = nil;
	self.spinner = nil;
	self.aboutUsItems = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    [super dealloc];
}


@end
