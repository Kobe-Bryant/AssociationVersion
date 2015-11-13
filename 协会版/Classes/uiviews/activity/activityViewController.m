//
//  activityViewController.m
//  xieHui
//
//  Created by siphp on 13-4-25.
//
//

#import "activityViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "ProfessionAppDelegate.h"
#import "activityDetailViewController.h"

@interface activityViewController ()

@end

@implementation activityViewController

@synthesize spinner;
@synthesize activityScrollView;
@synthesize pageControll;
@synthesize activityItems;
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
	// Do any additional setup after loading the view.
    
    activityView *tempActivityView = [[activityView alloc] initWithFrame:self.view.frame];
    tempActivityView.frame = CGRectMake( 0.0f , 0.0f ,self.view.frame.size.width , VIEW_HEIGHT - 20 - 44.0f - 40.0f);
    tempActivityView.delegate = self;
    self.view = tempActivityView;
    [tempActivityView release];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green: 0.95 blue: 0.95 alpha:1.0];
    self.view.clipsToBounds = YES;
    
    scrollWidth = self.view.frame.size.width - 60.0f;
    scrollHeight = [UIScreen mainScreen].bounds.size.height == 568.0f ? 400.0f : 340.0f;;
    picWidth = scrollWidth - 20.0f;
    picHeight = 170.0f;
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    //添加loading图标
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
    [loadingLabel release];
	[self.view addSubview:self.spinner];
	[self.spinner startAnimating];
	[tempSpinner release];
    
    //网络请求
    [self accessItemService];
    
}

//添加活动列表
-(void)addActivityScrollView
{
    //取广告数据
    self.activityItems = [DBOperate queryData:T_ACTIVITY
                              theColumn:@"" theColumnValue:@"" orderBy:@"id" orderType:@"desc" withAll:YES];
    
    if (![self.activityScrollView isDescendantOfView:self.view])
    {
        UIScrollView *tempActivityScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 30.0f , 18.0f , scrollWidth, scrollHeight)];
        tempActivityScrollView.contentSize = CGSizeMake(tempActivityScrollView.frame.size.width, tempActivityScrollView.frame.size.height);
        tempActivityScrollView.clipsToBounds = NO;
        tempActivityScrollView.pagingEnabled = YES;
        tempActivityScrollView.delegate = self;
        tempActivityScrollView.showsHorizontalScrollIndicator = NO;
        tempActivityScrollView.showsVerticalScrollIndicator = NO;
        self.activityScrollView = tempActivityScrollView;
        [tempActivityScrollView release];
        [self.view addSubview:self.activityScrollView];

    }

    int pageCount = [self.activityItems count];
    if (pageCount > 0)
    {
        for(int i = 0;i < pageCount;i++)
		{
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake( scrollWidth*i + 10.0f , 0.0f , scrollWidth - 20.0f, scrollHeight)];
            contentView.tag = 1000 + i;
            [self.activityScrollView addSubview:contentView];
            [contentView release];
            
            //图片
            myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake( 0.0f , 0.0f, picWidth, picHeight) withImageId:[NSString stringWithFormat:@"%d",i]];
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_M" ofType:@"png"]];
			myiv.image = img;
			[img release];
			myiv.mydelegate = self;
			myiv.tag = 2000 + i;
			
			[contentView addSubview:myiv];
            [myiv release];
			
            NSArray *activityArray = [self.activityItems objectAtIndex:i];
            NSString *picUrl = [activityArray objectAtIndex:activity_pic];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1)
            {
                UIImage *photo = [FileManager getPhoto:picName];
                if (photo.size.width > 2)
                {
                    myiv.image = [photo fillSize:CGSizeMake(picWidth,picHeight)];
                }
                else
                {
                    [myiv startSpinner];
                    [self startIconDownload:picUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }
            
            //描述文字
            UIView *descView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , picHeight , contentView.frame.size.width, scrollHeight - picHeight)];
            descView.backgroundColor = [UIColor whiteColor];
            [contentView addSubview:descView];
            [descView release];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 10.0f, 0.0f, descView.frame.size.width - 20.0f, 50.0f)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];//[UIFont systemFontOfSize:12];
            titleLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
            titleLabel.text = [activityArray objectAtIndex:activity_title];
            titleLabel.textAlignment = UITextAlignmentLeft;
            titleLabel.numberOfLines = 2;
            [descView addSubview:titleLabel];
            [titleLabel release];

            //线 
            UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(titleLabel.frame) , descView.frame.size.width, 1.0f)];
            lineView1.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
            [descView addSubview:lineView1];
            [lineView1 release];
            
            //发起单位
            UIImageView *companyImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(lineView1.frame) + 7.0f , 16.0f, 16.0f)];
            UIImage *companyImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_发起单位" ofType:@"png"]];
            companyImageView.image = companyImage;
            [companyImage release];
            [descView addSubview:companyImageView];
            [companyImageView release];
            
            UILabel *companyLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(companyImageView.frame) + 4.0f, CGRectGetMaxY(titleLabel.frame), descView.frame.size.width - 40.0f, 30.0f)];
            companyLabel.backgroundColor = [UIColor clearColor];
            companyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            companyLabel.font = [UIFont systemFontOfSize:12];
            companyLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
            companyLabel.text = [activityArray objectAtIndex:activity_organizer];
            companyLabel.textAlignment = UITextAlignmentLeft;
            companyLabel.numberOfLines = 1;
            [descView addSubview:companyLabel];
            [companyLabel release];
            
            //时间
            UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(companyLabel.frame) + 7.0f , 16.0f, 16.0f)];
            UIImage *timeImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_日期" ofType:@"png"]];
            timeImageView.image = timeImage;
            [timeImage release];
            [descView addSubview:timeImageView];
            [timeImageView release];
            
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(timeImageView.frame) + 4.0f, CGRectGetMaxY(companyLabel.frame), descView.frame.size.width - 30.0f, 30.0f)];
            timeLabel.backgroundColor = [UIColor clearColor];
            timeLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            timeLabel.font = [UIFont systemFontOfSize:12];
            timeLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
            timeLabel.text = [Common getFriendDate:[[activityArray objectAtIndex:activity_begin_time] intValue] eTime:[[activityArray objectAtIndex:activity_end_time] intValue]];
            timeLabel.textAlignment = UITextAlignmentLeft;
            timeLabel.numberOfLines = 1;
            [descView addSubview:timeLabel];
            [timeLabel release];
            
            //地址
            UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(timeLabel.frame) + 7.0f , 16.0f, 16.0f)];
            UIImage *addressImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_地址" ofType:@"png"]];
            addressImageView.image = addressImage;
            [addressImage release];
            [descView addSubview:addressImageView];
            [addressImageView release];
            
            UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(addressImageView.frame) + 4.0f, CGRectGetMaxY(timeLabel.frame), descView.frame.size.width - 40.0f, 30.0f)];
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            addressLabel.font = [UIFont systemFontOfSize:12];
            addressLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
            addressLabel.text = [activityArray objectAtIndex:activity_address];
            addressLabel.textAlignment = UITextAlignmentLeft;
            addressLabel.numberOfLines = 2;
            [descView addSubview:addressLabel];
            [addressLabel release];
            
            UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , descView.frame.size.height - 31.0f , descView.frame.size.width, 1.0f)];
            lineView2.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
            [descView addSubview:lineView2];
            [lineView2 release];
            
            UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake( descView.frame.size.width / 2 , descView.frame.size.height - 31.0f , 1.0f , 30.0f)];
            lineView3.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
            [descView addSubview:lineView3];
            [lineView3 release];
            
            //底部bar
            UILabel *interestLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(lineView2.frame), descView.frame.size.width / 2 , 30.0f)];
            interestLabel.backgroundColor = [UIColor clearColor];
            interestLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            interestLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
            interestLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
            interestLabel.text = [NSString stringWithFormat:@"感兴趣 %@",[activityArray objectAtIndex:activity_interests]];
            interestLabel.textAlignment = UITextAlignmentCenter;
            interestLabel.numberOfLines = 1;
            [descView addSubview:interestLabel];
            [interestLabel release];
            
            //判断活动状态
            NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
            long long int currentTime = (long long int)cTime;
            NSString *statusString = @"";
            if ([[activityArray objectAtIndex:activity_reg_end_time] intValue] >= currentTime)
            {
                statusString = @"报名中...";
            }
            else
            {
                int startTime = [[activityArray objectAtIndex:activity_begin_time] intValue];
                int endTime = [[activityArray objectAtIndex:activity_end_time] intValue];
                if (startTime > currentTime)
                {
                    //即将开始
                    statusString = @"即将开始...";
                }
                else if(startTime <= currentTime && endTime > currentTime)
                {
                    //正在进行
                    statusString = @"活动中...";
                }
                else
                {
                    //已结束
                    statusString = @"已结束...";
                }
            }
            
            UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(lineView3.frame) , CGRectGetMaxY(lineView2.frame), descView.frame.size.width / 2 , 30.0f)];
            statusLabel.backgroundColor = [UIColor clearColor];
            statusLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            statusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
            statusLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
            statusLabel.text = statusString;
            statusLabel.textAlignment = UITextAlignmentCenter;
            statusLabel.numberOfLines = 1;
            [descView addSubview:statusLabel];
            [statusLabel release];
            
            //添加隐藏按钮
            UIButton *contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [contentButton setFrame:CGRectMake( scrollWidth*i + 10.0f , 0.0f , scrollWidth - 20.0f, scrollHeight)];
            [contentButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            contentButton.backgroundColor = [UIColor clearColor];
            contentButton.userInteractionEnabled = YES;
            contentButton.tag = 100 + i;
            [self.activityScrollView addSubview:contentButton];
		}
        
        self.activityScrollView.contentSize = CGSizeMake(pageCount * scrollWidth, scrollHeight);
        
        /*
        if (pageCount > 1)
        {
            int pageUnitWidth = 20.0f;
            CGFloat pageControllWidth = pageUnitWidth * pageCount;
            CGFloat pageControllHeight = 15.0f;
            if(self.pageControll == nil)
            {
                UIPageControl *tempPageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.center.x - (pageControllWidth/2.0), CGRectGetMaxY(self.activityScrollView.frame) + pageControllHeight, pageControllWidth, pageControllHeight)];
                self.pageControll = tempPageControll;
                [tempPageControll release];
                [self.pageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
                self.pageControll.layer.masksToBounds = YES;
                self.pageControll.layer.cornerRadius = 3;
                self.pageControll.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
                [self.view addSubview:self.pageControll];
                
            }
            self.pageControll.numberOfPages = pageCount;
            self.pageControll.currentPage = 0;
        }
        */

    }
    else
    {
        UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height)];
        [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
        noneLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
        noneLabel.text = @"当前没有活动...";
        noneLabel.textAlignment = UITextAlignmentCenter;
        noneLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:noneLabel];
        [noneLabel release];
    }
}

//活动点击
-(void)buttonAction:(id)sender
{
    UIButton *currentButton = sender;
    ProfessionAppDelegate *ProfessionDelegate = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
    activityDetailViewController *activityDetailView = [[activityDetailViewController alloc] init];
    
    NSArray *activityArray = [self.activityItems objectAtIndex:currentButton.tag - 100];
    activityDetailView.activityArray = activityArray;
    
    //活动图片处理
    if ([[activityArray objectAtIndex:activity_pics] isKindOfClass:[NSMutableArray class]])
    {
        activityDetailView.picArray = [activityArray objectAtIndex:activity_pics];
    }
    else
    {
        activityDetailView.picArray = [DBOperate queryData:T_ACTIVITY_PIC
                                        theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_id] orderBy:@"id" orderType:@"asc" withAll:NO];
    }

    //用户图片处理
    if ([[activityArray objectAtIndex:activity_user_pics] isKindOfClass:[NSMutableArray class]])
    {
        activityDetailView.userPicArray = [activityArray objectAtIndex:activity_user_pics];
    }
    else
    {
        activityDetailView.userPicArray = [DBOperate queryData:T_ACTIVITY_USER_PIC
                                                 theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_id] orderBy:@"id" orderType:@"desc" withAll:NO];
    }
    
    [ProfessionDelegate.navController pushViewController:activityDetailView animated:YES];
    [activityDetailView release];
}

- (void)pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.activityScrollView.contentOffset = CGPointMake(scrollWidth * whichPage, 0.0f);
	[UIView commitAnimations];
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
    int countItems = [self.activityItems count];
    if (countItems > [indexPath row])
    {
        NSArray *activityArray = [self.activityItems objectAtIndex:[indexPath row]];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[[activityArray objectAtIndex:activity_pic] dataUsingEncoding: NSUTF8StringEncoding]];
        
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
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
            UIImage *pic = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
            UIView *currentContentView = (UIView *)[self.activityScrollView viewWithTag:1000 + [indexPath row]];
            myImageView *currentMyImageView = (myImageView *)[currentContentView viewWithTag:2000 + [indexPath row]];
            currentMyImageView.image = pic;
            [currentMyImageView stopSpinner];
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
    NSString *reqUrl = @"activitylist.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [Common getVersion:OPERAT_ACTIVITY_REFRESH],@"ver",
                                 [NSNumber numberWithInt: 1],@"type",
                                 [NSNumber numberWithInt: 0],@"info_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_ACTIVITY_REFRESH
								  accessAdress:reqUrl
									  delegate:self
									 withParam:nil];
}

//更新数据
-(void)update
{
    //添加滚动列表
    [self addActivityScrollView];
    [self backNormal];
    
    //发送广播 告知已load完
    [self performSelector:@selector(loadDone) withObject:nil afterDelay:0.5];

}

//回归常态
-(void)backNormal
{
	//loading图标移除
	if (self.spinner != nil) {
		[self.spinner stopAnimating];
	}
}

//发送广播 告知已load完
-(void)loadDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadActivity" object:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
}

#pragma mark
#pragma mark - hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self.view pointInside:point withEvent:event])
    {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - self.activityScrollView.frame.origin.x + self.activityScrollView.contentOffset.x;
        newPoint.y = point.y - self.activityScrollView.frame.origin.y + self.activityScrollView.contentOffset.y;
        if ([self.activityScrollView pointInside:newPoint withEvent:event])
        {
            return [self.activityScrollView hitTest:newPoint withEvent:event];
        }
        
        return self.activityScrollView;
    }
    
    return nil;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if(scrollView == self.activityScrollView)
//    {
//        CGPoint offset = self.activityScrollView.contentOffset;
//        self.pageControll.currentPage = offset.x / scrollWidth;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.spinner = nil;
    self.activityScrollView = nil;
    self.pageControll = nil;
    self.activityItems = nil;
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
}


- (void)dealloc {
    [self.spinner release];
    [self.activityScrollView release];
    [self.pageControll release];
    [self.activityItems release];
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	[self.imageDownloadsInProgress release];
	[self.imageDownloadsInWaiting release];
    [super dealloc];
}

@end
