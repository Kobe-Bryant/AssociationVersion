//
//  HaveAppDownloadViewController.m
//  xieHui
//
//  Created by LuoHui on 13-4-23.
//
//

#import "HaveAppDownloadViewController.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "Common.h"
#import "UIImageScale.h"

@interface HaveAppDownloadViewController ()

@end

@implementation HaveAppDownloadViewController
@synthesize logoImageUrl;
@synthesize appName;
@synthesize appUrl;
@synthesize iconDownLoad;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"单位";
    self.view.backgroundColor = [UIColor clearColor];
    
    picWidth = 60;
    picHeight = 60;
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    UIImage *logoImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_无企业移动APP" ofType:@"png"]];
    logoView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - logoImg.size.width) * 0.5, self.view.frame.size.height * 0.5 * 0.5 * 0.5, logoImg.size.width, logoImg.size.height)];
    logoView.image = logoImg;
    logoView.layer.masksToBounds = YES;
    logoView.layer.cornerRadius = 10;
    [self.view addSubview:logoView];
    
    appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(logoView.frame) + 10, 260, 40)];
    appNameLabel.backgroundColor = [UIColor clearColor];
    appNameLabel.text = @"";
    appNameLabel.numberOfLines = 0;
    appNameLabel.textAlignment = UITextAlignmentCenter;
    appNameLabel.textColor = [UIColor darkTextColor];
    appNameLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:appNameLabel];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(appNameLabel.frame) + 30, 320, 20)];
    strLabel.backgroundColor = [UIColor clearColor];
    strLabel.text = @"下载企业移动APP，更多精彩即刻体验！";
    strLabel.textAlignment = UITextAlignmentCenter;
    strLabel.textColor = [UIColor darkGrayColor];
    strLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:strLabel];
    [strLabel release];
    
    UIImage *btnImage = [UIImage imageNamed:@"button_green.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((320 - 230) * 0.5, CGRectGetMaxY(strLabel.frame) + 10, 230, 50);
    [btn setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(downloadApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIImage *btnImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_iphone" ofType:@"png"]];
    UIImageView *btnView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (btn.frame.size.height - btnImg.size.height) * 0.5, btnImg.size.width, btnImg.size.height)];
    btnView.image = btnImg;
    [btn addSubview:btnView];
    [btnView release];
    
    UILabel *btnStr = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnView.frame) + 5, (btn.frame.size.height - 30) * 0.5, btn.frame.size.width - CGRectGetMaxX(btnView.frame) - 5, 30)];
    btnStr.backgroundColor = [UIColor clearColor];
    btnStr.text = @"iPhone版下载";
    btnStr.textAlignment = UITextAlignmentLeft;
    btnStr.textColor = [UIColor whiteColor];
    btnStr.font = [UIFont systemFontOfSize:16];
    [btn addSubview:btnStr];
    [btnStr release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *picName = [Common encodeBase64:(NSMutableData *)[logoImageUrl dataUsingEncoding: NSUTF8StringEncoding]];
    UIImage *img = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
    if (img != nil) {
        logoView.image = img;
    }else {
        if (logoImageUrl.length > 0) {
            [self startIconDownload:logoImageUrl forIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
    }
    
    appNameLabel.text = appName;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	imageDownloadsInWaiting = nil;
	imageDownloadsInProgress = nil;
}

- (void)dealloc
{
    [logoView release];
    [appNameLabel release];
    [logoImageUrl release];
    [appName release];
    [appUrl release];
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
    [imageDownloadsInWaiting release];
	[imageDownloadsInProgress release];
    [super dealloc];
}

#pragma mark ---- loadImage Method
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader == nil && imageURL != nil && imageURL.length > 1)
    {
		if ([imageDownloadsInProgress count] >= DOWNLOAD_IMAGE_MAX_COUNT) {
            imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL withIndexPath:index withImageType:CUSTOMER_PHOTO];
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

- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
			NSString *picName = [Common encodeBase64:(NSMutableData *)[logoImageUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if ([FileManager savePhoto:picName withImage:photo]) {
                logoView.image = photo;
            }
		}
		
		[imageDownloadsInProgress removeObjectForKey:indexPath];
		if ([imageDownloadsInWaiting count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaiting removeObjectAtIndex:0];
		}
    }
}

#pragma mark ----private method
- (void)downloadApp
{
    //NSLog(@"appUrl==== %@",appUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
}
@end
