//
//  activityDetailViewController.m
//  xieHui
//
//  Created by siphp on 13-5-6.
//
//

#import "activityDetailViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "callSystemApp.h"
#import "alertView.h"
#import "BaiduMapViewController.h"
#import "activityShareViewController.h"
#import "browserViewController.h"
#import "picDetailViewController.h"
#import "activityUserPicDetailViewController.h"

#define ACTIVITY_NUM_COLOR_RED 0.7
#define ACTIVITY_NUM_COLOR_GREEN 0.5
#define ACTIVITY_NUM_COLOR_BLUE 0.23

#define PIC_BASE_TAG 1000
#define USER_PIC_BASE_TAG 2000

@interface activityDetailViewController ()

@end

@implementation activityDetailViewController

@synthesize spinner;
@synthesize progressHUD;
@synthesize mainScrollView;
@synthesize picScrollView;
@synthesize userPicScrollView;
@synthesize pageControll;
@synthesize imagePickerController;
@synthesize toolBar;
@synthesize userPicNumLable;
@synthesize interestButton;
@synthesize interestTitleLabel;
@synthesize interestLabel;
@synthesize interestImageView;
@synthesize joinButton;
@synthesize joinTitleLabel;
@synthesize joinLabel;
@synthesize joinImageView;
@synthesize activityArray;
@synthesize picArray;
@synthesize userPicArray;
@synthesize imageDownloadsInWaiting;
@synthesize imageDownloadsInProgress;
@synthesize userId;
@synthesize ShareSheet; // dufu  add 2013.05.10


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// dufu add 2013.05.10
//分享
-(void)share
{
    // 分享创建实例
    if (ShareSheet == nil) {
        ShareSheet = [[ShareAction alloc]init];
    }
    
    ShareSheet.shareDelegate = self;
    
    // 分享显示弹窗
    [ShareSheet shareActionShow:self.view navController:self.navigationController];
}

// dufu add 2013.05.10
// 添加右上角分享按钮
- (void)addNavRightButton
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
    [rightButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"分享操作icon" ofType:@"png"]] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"活动详情";
    
    picWidth = self.view.frame.size.width;
    picHeight = 240.0f;
    
    userPicWidth = 75.0f;
    userPicHeight = 75.0f;
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    [self addNavRightButton]; // dufu add 2013.05.10
    
    //添加上传成功后监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertUserPic:)
                                                 name:@"didFinishUploadImage"
                                               object:nil];
    
    //添加loading图标
    UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f) / 2.0)];
    self.spinner = tempSpinner;
    
    UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
    loadingLabel.font = [UIFont systemFontOfSize:14];
    loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
    loadingLabel.text = @"正在载入...";
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.backgroundColor = [UIColor clearColor];
    [self.spinner addSubview:loadingLabel];
    [loadingLabel release];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [tempSpinner release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //获取当前用户的user_id
	NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
	if ([memberArray count] > 0)
	{
		self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
	}
	else
	{
		self.userId = @"0";
	}
    
    //判断活动是否已结束
    NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    long long int currentTime = (long long int)cTime;
    int endTime = [[self.activityArray objectAtIndex:activity_end_time] intValue];
    status = currentTime > endTime ? NO : YES;
    
    //判断是否已感兴趣
    NSString *activityId =[self.activityArray objectAtIndex:activity_id];
    NSArray *interestedIds = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag"
                                   theColumnValue:@"interestedId" withAll:NO];
	if ([interestedIds count]>0)
    {
		NSString *interestedIdString = [[interestedIds objectAtIndex:0] objectAtIndex:1];
        
        if ([interestedIdString rangeOfString:@"," options:NSCaseInsensitiveSearch].location == NSNotFound)
        {
            isInterested = [interestedIdString isEqualToString:activityId] ? YES : NO;
        }
        else
        {
            NSArray *interestedIdArray = [interestedIdString componentsSeparatedByString:@","];
            isInterested = [interestedIdArray indexOfObject:activityId] == NSNotFound ? NO : YES;
        }
	}
    else
    {
        isInterested = NO;
    }
    
    //判断是否已参加
    NSArray *joinActivityIds = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag"
                                     theColumnValue:@"activityId" withAll:NO];
	if ([joinActivityIds count]>0)
    {
		NSString *joinActivityIdString = [[joinActivityIds objectAtIndex:0] objectAtIndex:1];
        
        if ([joinActivityIdString rangeOfString:@"," options:NSCaseInsensitiveSearch].location == NSNotFound)
        {
            isJoin = [joinActivityIdString isEqualToString:activityId] ? YES : NO;
        }
        else
        {
            NSArray *joinActivityIdArray = [joinActivityIdString componentsSeparatedByString:@","];
            isJoin = [joinActivityIdArray indexOfObject:activityId] == NSNotFound ? NO : YES;
        }
	}
    else
    {
        isJoin = NO;
    }
    
    //判断是否已截至报名
    int regEndTime = [[self.activityArray objectAtIndex:activity_reg_end_time] intValue];
    isEndJoin = currentTime > regEndTime ? YES : NO;
    
    
    //主视图
    if (self.mainScrollView == nil)
    {
        [self performSelector:@selector(addMainScrollView) withObject:nil afterDelay:0.0];
    }
    
}

//添加主视图
-(void)addMainScrollView
{
    UIScrollView *tempMainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height)];
    tempMainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, tempMainScrollView.frame.size.height);
    tempMainScrollView.pagingEnabled = NO;
    tempMainScrollView.showsHorizontalScrollIndicator = NO;
    tempMainScrollView.showsVerticalScrollIndicator = NO;
    tempMainScrollView.delegate = self;
    self.mainScrollView = tempMainScrollView;
    [tempMainScrollView release];
    [self.view addSubview:self.mainScrollView];
    
    int pageCount = [self.picArray count];
    if (pageCount > 0)
    {
        UIScrollView *tempPicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( -5.0f , 0.0f , picWidth + 10.0f, picHeight)];
        tempPicScrollView.contentSize = CGSizeMake(tempPicScrollView.frame.size.width, tempPicScrollView.frame.size.height);
        tempPicScrollView.pagingEnabled = YES;
        tempPicScrollView.delegate = self;
        tempPicScrollView.showsHorizontalScrollIndicator = NO;
        tempPicScrollView.showsVerticalScrollIndicator = NO;
        self.picScrollView = tempPicScrollView;
        [tempPicScrollView release];
        [self.mainScrollView addSubview:self.picScrollView];
        
        for(int i = 0;i < pageCount;i++)
		{
            myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake( (self.picScrollView.frame.size.width)*i + 5.0f, 0.0f, picWidth, picHeight) withImageId:PIC_BASE_TAG + i];
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"活动平台_活动图片_L" ofType:@"png"]];
			myiv.image = img;
			[img release];
			myiv.mydelegate = self;
			myiv.tag = PIC_BASE_TAG + i;
			
			[self.picScrollView addSubview:myiv];
            [myiv release];
			
            NSArray *pic = [self.picArray objectAtIndex:i];
            NSString *picUrl = [pic objectAtIndex:activity_pic_pic];
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
		}
        
        self.picScrollView.contentSize = CGSizeMake(pageCount * self.picScrollView.frame.size.width, picHeight);
        
        if (pageCount > 1)
        {
            int pageUnitWidth = 20.0f;
            CGFloat pageControllWidth = pageUnitWidth * pageCount;
            CGFloat pageControllHeight = 15.0f;
            if(self.pageControll == nil)
            {
                UIPageControl *tempPageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.center.x - (pageControllWidth/2.0), CGRectGetMaxY(self.picScrollView.frame) - pageControllHeight, pageControllWidth, pageControllHeight)];
                self.pageControll = tempPageControll;
                [tempPageControll release];
                [pageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
                [self.mainScrollView addSubview:self.pageControll];
                
            }
            self.pageControll.numberOfPages = pageCount;
            self.pageControll.currentPage = 0;
        }
    }
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 10.0f, CGRectGetMaxY(self.picScrollView.frame), self.mainScrollView.frame.size.width - 20.0f, 50.0f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];//[UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
    
    if (status)
    {
        if (isEndJoin)
        {
            titleLabel.text = [NSString stringWithFormat:@"%@ (已截止报名)",[self.activityArray objectAtIndex:activity_title]];
        }
        else
        {
            titleLabel.text = [self.activityArray objectAtIndex:activity_title];
        }
    }
    else
    {
        titleLabel.text = [self.activityArray objectAtIndex:activity_title];
    }
    
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.numberOfLines = 2;
    [self.mainScrollView addSubview:titleLabel];
    [titleLabel release];
    
    //线
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(titleLabel.frame) , self.mainScrollView.frame.size.width, 1.0f)];
    lineView1.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    [self.mainScrollView addSubview:lineView1];
    [lineView1 release];
    
    //发起单位
    UIImageView *companyImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(lineView1.frame) + 12.0f , 16.0f, 16.0f)];
    UIImage *companyImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_发起单位" ofType:@"png"]];
    companyImageView.image = companyImage;
    [companyImage release];
    [self.mainScrollView addSubview:companyImageView];
    [companyImageView release];
    
    UILabel *companyLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(companyImageView.frame) + 4.0f, CGRectGetMaxY(lineView1.frame), self.mainScrollView.frame.size.width - 40.0f, 40.0f)];
    companyLabel.backgroundColor = [UIColor clearColor];
    companyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    companyLabel.font = [UIFont systemFontOfSize:12];
    companyLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    companyLabel.text = [self.activityArray objectAtIndex:activity_organizer];
    companyLabel.textAlignment = UITextAlignmentLeft;
    companyLabel.numberOfLines = 1;
    [self.mainScrollView addSubview:companyLabel];
    [companyLabel release];
    
    //线
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(companyLabel.frame) , self.mainScrollView.frame.size.width, 1.0f)];
    lineView2.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    [self.mainScrollView addSubview:lineView2];
    [lineView2 release];
    
    //时间
    UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(lineView2.frame) + 12.0f , 16.0f, 16.0f)];
    UIImage *timeImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_日期" ofType:@"png"]];
    timeImageView.image = timeImage;
    [timeImage release];
    [self.mainScrollView addSubview:timeImageView];
    [timeImageView release];
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(timeImageView.frame) + 4.0f, CGRectGetMaxY(lineView2.frame), self.mainScrollView.frame.size.width - 30.0f, 40.0f)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    timeLabel.text = [Common getFriendDate:[[self.activityArray objectAtIndex:activity_begin_time] intValue] eTime:[[self.activityArray objectAtIndex:activity_end_time] intValue]];
    timeLabel.textAlignment = UITextAlignmentLeft;
    timeLabel.numberOfLines = 1;
    [self.mainScrollView addSubview:timeLabel];
    [timeLabel release];
    
    //线
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(timeLabel.frame) , self.mainScrollView.frame.size.width, 1.0f)];
    lineView3.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    [self.mainScrollView addSubview:lineView3];
    [lineView3 release];
    
    //电话
    UIImageView *telImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(lineView3.frame) + 12.0f , 16.0f, 16.0f)];
    UIImage *telImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_电话" ofType:@"png"]];
    telImageView.image = telImage;
    [telImage release];
    [self.mainScrollView addSubview:telImageView];
    [telImageView release];
    
    UIImageView *telRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 300.0 , CGRectGetMaxY(lineView3.frame) + 15.0f , 16.0f, 11.0f)];
    UIImage *telRightImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
    telRightImageView.image = telRightImage;
    [telRightImage release];
    [self.mainScrollView addSubview:telRightImageView];
    [telRightImageView release];
    
    UILabel *telLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(telImageView.frame) + 4.0f, CGRectGetMaxY(lineView3.frame), self.mainScrollView.frame.size.width - 40.0f, 40.0f)];
    telLabel.backgroundColor = [UIColor clearColor];
    telLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    telLabel.font = [UIFont systemFontOfSize:12];
    telLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    telLabel.text = [self.activityArray objectAtIndex:activity_phone];
    telLabel.textAlignment = UITextAlignmentLeft;
    telLabel.numberOfLines = 1;
    [self.mainScrollView addSubview:telLabel];
    [telLabel release];
    
    UIButton *telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [telButton setFrame:CGRectMake( 0.0f , CGRectGetMaxY(lineView3.frame) , self.mainScrollView.frame.size.width, 40.0f)];
    [telButton addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    telButton.backgroundColor = [UIColor clearColor];
    [self.mainScrollView addSubview:telButton];
    
    //线
    UIView *lineView4 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(telLabel.frame) , self.mainScrollView.frame.size.width, 1.0f)];
    lineView4.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    [self.mainScrollView addSubview:lineView4];
    [lineView4 release];
    
    //地址
    UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10.0 , CGRectGetMaxY(lineView4.frame) + 12.0f , 16.0f, 16.0f)];
    UIImage *addressImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_地址" ofType:@"png"]];
    addressImageView.image = addressImage;
    [addressImage release];
    [self.mainScrollView addSubview:addressImageView];
    [addressImageView release];
    
    UIImageView *addressRightImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 300.0 , CGRectGetMaxY(lineView4.frame) + 15.0f , 16.0f, 11.0f)];
    UIImage *addressRightImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
    addressRightImageView.image = addressRightImage;
    [addressRightImage release];
    [self.mainScrollView addSubview:addressRightImageView];
    [addressRightImageView release];
    
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(addressImageView.frame) + 4.0f, CGRectGetMaxY(lineView4.frame), self.mainScrollView.frame.size.width - 40.0f, 40.0f)];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    addressLabel.font = [UIFont systemFontOfSize:12];
    addressLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    addressLabel.text = [self.activityArray objectAtIndex:activity_address];
    addressLabel.textAlignment = UITextAlignmentLeft;
    addressLabel.numberOfLines = 2;
    [self.mainScrollView addSubview:addressLabel];
    [addressLabel release];
    
    UIButton *addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addressButton setFrame:CGRectMake(0.0f , CGRectGetMaxY(lineView4.frame) , self.mainScrollView.frame.size.width, 40.0f)];
    [addressButton addTarget:self action:@selector(showMapByCoord) forControlEvents:UIControlEventTouchUpInside];
    addressButton.backgroundColor = [UIColor clearColor];
    [self.mainScrollView addSubview:addressButton];
    
    //用户图片标题
    userPicNum = [[self.activityArray objectAtIndex:activity_activity_img_num] intValue];
    UILabel *tempUserPicLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, CGRectGetMaxY(addressLabel.frame), self.mainScrollView.frame.size.width , 20.0f)];
    tempUserPicLabel.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1];
    tempUserPicLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    tempUserPicLabel.font = [UIFont systemFontOfSize:12];
    tempUserPicLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    tempUserPicLabel.text = [NSString stringWithFormat:@"   秀一下您的现场照片吧 ( %d )",userPicNum];
    tempUserPicLabel.textAlignment = UITextAlignmentLeft;
    tempUserPicLabel.numberOfLines = 1;
    self.userPicNumLable = tempUserPicLabel;
    [self.mainScrollView addSubview:self.userPicNumLable];
    [tempUserPicLabel release];
    
    //用户现场图片
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(4.0f , CGRectGetMaxY(self.userPicNumLable.frame) + 4.0f , 75.0f , 75.0f)];
    [cameraButton addTarget:self action:@selector(cameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.backgroundColor = [UIColor clearColor];
    [cameraButton setBackgroundImage :[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_活动平台_照相机" ofType:@"png"]] forState:UIControlStateNormal];
    [self.mainScrollView addSubview:cameraButton];
    
    //现场滚动图片
    UIScrollView *tempUserPicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( CGRectGetMaxX(cameraButton.frame) + 4.0f , CGRectGetMaxY(self.userPicNumLable.frame) + 4.0f , 237.0f, 75.0f)];
    tempUserPicScrollView.contentSize = CGSizeMake(tempUserPicScrollView.frame.size.width, tempUserPicScrollView.frame.size.height);
    tempUserPicScrollView.pagingEnabled = NO;
    tempUserPicScrollView.delegate = self;
    tempUserPicScrollView.showsHorizontalScrollIndicator = NO;
    tempUserPicScrollView.showsVerticalScrollIndicator = NO;
    self.userPicScrollView = tempUserPicScrollView;
    [tempUserPicScrollView release];
    [self.mainScrollView addSubview:self.userPicScrollView];
    
    int userPicCount = [self.userPicArray count];
    if (userPicCount > 0)
    {
        for(int i = 0;i < userPicCount;i++)
        {
            myImageView *myiv = [[myImageView alloc]initWithFrame:
                                 CGRectMake( (userPicWidth + 4.0f) * i, 0.0f, userPicWidth, userPicHeight) withImageId:USER_PIC_BASE_TAG + i];
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"活动详情_现场照片_s" ofType:@"png"]];
            myiv.image = img;
            [img release];
            myiv.mydelegate = self;
            myiv.tag = USER_PIC_BASE_TAG + i;
            
            [self.userPicScrollView addSubview:myiv];
            [myiv release];
            
            NSArray *userPic = [self.userPicArray objectAtIndex:i];
            NSString *userPicUrl = [userPic objectAtIndex:activity_user_pic_thumb_pic];
            NSString *userPicName = [Common encodeBase64:(NSMutableData *)[userPicUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (userPicUrl.length > 1)
            {
                UIImage *photo = [FileManager getPhoto:userPicName];
                if (photo.size.width > 2)
                {
                    myiv.image = [photo fillSize:CGSizeMake(userPicWidth,userPicHeight)];
                }
                else
                {
                    [myiv startSpinner];
                    [self startIconDownload:userPicUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                }
            }
        }
        
        self.userPicScrollView.contentSize = CGSizeMake((userPicWidth + 4.0f) *userPicCount, userPicHeight);
    }
    else
    {
        UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, 0.0f , self.userPicScrollView.frame.size.width , self.userPicScrollView.frame.size.height)];
        noneLabel.backgroundColor = [UIColor clearColor];
        noneLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        noneLabel.font = [UIFont systemFontOfSize:12];
        noneLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        noneLabel.text = @"还没照片,赶紧拍一张!";
        noneLabel.textAlignment = UITextAlignmentCenter;
        noneLabel.numberOfLines = 1;
        [self.userPicScrollView addSubview:noneLabel];
        [noneLabel release];
    }
    
    //活动现场报道
    CGFloat descFixHeight = CGRectGetMaxY(cameraButton.frame);
    NSString *reportUrl = [self.activityArray objectAtIndex:activity_report_url];
    if (reportUrl.length > 0)
    {
        //线
        UIView *lineView5 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(cameraButton.frame) + 4.0f, self.mainScrollView.frame.size.width, 1.0f)];
        lineView5.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
        [self.mainScrollView addSubview:lineView5];
        [lineView5 release];
        
        UIButton *reportUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [reportUrlButton setFrame:CGRectMake( 10.0f , CGRectGetMaxY(lineView5.frame) + 4.0f , 300.0f , 44.0f)];
        [reportUrlButton addTarget:self action:@selector(reportUrl) forControlEvents:UIControlEventTouchUpInside];
        reportUrlButton.backgroundColor = [UIColor clearColor];
        [reportUrlButton setBackgroundImage :[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_个人中心_我的活动" ofType:@"png"]] forState:UIControlStateNormal];
        [self.mainScrollView addSubview:reportUrlButton];
        
        UILabel *reportUrlLabel = [[UILabel alloc]initWithFrame:CGRectMake( 50.0f, 0.0f , reportUrlButton.frame.size.width - 50.0f, reportUrlButton.frame.size.height)];
        reportUrlLabel.backgroundColor = [UIColor clearColor];
        reportUrlLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        reportUrlLabel.font = [UIFont systemFontOfSize:14];
        reportUrlLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        reportUrlLabel.text = @"活动现场报道";
        reportUrlLabel.textAlignment = UITextAlignmentLeft;
        reportUrlLabel.numberOfLines = 1;
        [reportUrlButton addSubview:reportUrlLabel];
        [reportUrlLabel release];
        
        descFixHeight = CGRectGetMaxY(reportUrlButton.frame);
    }
    
    //简介标题
    UILabel *descTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, descFixHeight + 4.0f, self.mainScrollView.frame.size.width , 20.0f)];
    descTitleLabel.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1];
    descTitleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    descTitleLabel.font = [UIFont systemFontOfSize:12];
    descTitleLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    descTitleLabel.text = @"   活动简介";
    descTitleLabel.textAlignment = UITextAlignmentLeft;
    descTitleLabel.numberOfLines = 1;
    [self.mainScrollView addSubview:descTitleLabel];
    [descTitleLabel release];
    
    UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[descInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
	descInfoLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
	descInfoLabel.backgroundColor = [UIColor clearColor];
	descInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
	descInfoLabel.numberOfLines = 0;
	NSString *descText = [NSString stringWithFormat:@"       %@",[self.activityArray objectAtIndex:activity_desc]];
	descInfoLabel.text = descText;
	CGSize constraint = CGSizeMake(300, 20000.0f);
	CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	float fixHeight = size.height + 10.0f;
	fixHeight = fixHeight == 0 ? 20.f : MAX(fixHeight,20.0f);
	[descInfoLabel setFrame:CGRectMake(10.0f , CGRectGetMaxY(descTitleLabel.frame) + 5.0f, 300, fixHeight)];
	[self.mainScrollView addSubview:descInfoLabel];
	[descInfoLabel release];
    
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, CGRectGetMaxY(descInfoLabel.frame));
    
    //下bar 工具栏背景
    if (!status && [[self.activityArray objectAtIndex:activity_sum] intValue] == 0)
    {
        //参加人数为0 则bar不出现
        self.mainScrollView.frame = CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height);
    }
    else
    {
        self.mainScrollView.frame = CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height - 40.0f);
        
        [self addToolBar];
    }
    
    [self backNormal];
}

//添加下bar
-(void)addToolBar
{
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mainScrollView.frame), self.view.frame.size.width, 40.0f)];
    [self.view addSubview:toolView];
    [toolView release];
    
    //背景
    UIImage *toolBackgroundImg = [[UIImage imageNamed:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *toolBackground = [[UIImageView alloc] initWithImage:toolBackgroundImg];
    toolBackground.frame = CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, 40.0f);
    toolBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [toolView addSubview:toolBackground];
    [toolBackground release];
    
    //线
    UIView *toolLineView = [[UIView alloc] initWithFrame:CGRectMake( toolView.frame.size.width / 2 , 0.0f , 1.0f , 40.0f)];
    toolLineView.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1];
    [toolView addSubview:toolLineView];
    [toolLineView release];
    
    //添加按钮
    UIButton *tempInterestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempInterestButton setFrame:CGRectMake( 5.0f , 0.0f , (toolView.frame.size.width / 2) - 10.0f , 40.0f)];
    [tempInterestButton addTarget:self action:@selector(interest:) forControlEvents:UIControlEventTouchUpInside];
    tempInterestButton.backgroundColor = [UIColor clearColor];
    self.interestButton = tempInterestButton;
    [toolView addSubview:self.interestButton];
    
    UILabel *tempInterestTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, 5.0f , self.interestButton.frame.size.width , 15.0f)];
    tempInterestTitleLabel.backgroundColor = [UIColor clearColor];
    tempInterestTitleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    tempInterestTitleLabel.font = [UIFont systemFontOfSize:12];
    tempInterestTitleLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
    tempInterestTitleLabel.text = @"感兴趣";
    tempInterestTitleLabel.textAlignment = UITextAlignmentCenter;
    tempInterestTitleLabel.numberOfLines = 1;
    self.interestTitleLabel = tempInterestTitleLabel;
    [self.interestButton addSubview:self.interestTitleLabel];
    [tempInterestTitleLabel release];
    
    UILabel *tempInterestLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, CGRectGetMaxY(interestTitleLabel.frame), self.interestButton.frame.size.width , 20.0f)];
    tempInterestLabel.backgroundColor = [UIColor clearColor];
    tempInterestLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    tempInterestLabel.font = [UIFont systemFontOfSize:12];
    tempInterestLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
    tempInterestLabel.text = @"感兴趣";
    tempInterestLabel.textAlignment = UITextAlignmentCenter;
    tempInterestLabel.numberOfLines = 1;
    self.interestLabel = tempInterestLabel;
    [self.interestButton addSubview:self.interestLabel];
    [tempInterestLabel release];
    
    UIImage *interestImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动详情_感兴趣" ofType:@"png"]];
    UIImageView *tempInterestImageView = [[UIImageView alloc]initWithFrame:CGRectMake(((self.interestButton.frame.size.width - interestImage.size.width)/2) , 0.0f , interestImage.size.width, interestImage.size.height)];
    tempInterestImageView.image = interestImage;
    [interestImage release];
    self.interestImageView = tempInterestImageView;
    [self.interestButton addSubview:self.interestImageView];
    [tempInterestImageView release];
    
    if (isInterested || !status)
    {
        self.interestButton.enabled = NO;
        self.interestImageView.hidden = YES;
        self.interestLabel.textColor = [UIColor colorWithRed:ACTIVITY_NUM_COLOR_RED green:ACTIVITY_NUM_COLOR_GREEN blue:ACTIVITY_NUM_COLOR_BLUE alpha:1];
        self.interestLabel.text = [self.activityArray objectAtIndex:activity_interests];
    }
    else
    {
        self.interestTitleLabel.hidden = YES;
    }
    
    
    UIButton *tempJoinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempJoinButton setFrame:CGRectMake( CGRectGetMaxX(toolLineView.frame) + 5.0f , 0.0f , (toolView.frame.size.width / 2) - 10.0f , 40.0f)];
    UIImage *joinButtonSelectImg = [[UIImage imageNamed:@"参加活动选中.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:40];
    [tempJoinButton setBackgroundImage:joinButtonSelectImg forState:UIControlStateSelected];
    tempJoinButton.adjustsImageWhenHighlighted = NO;
    tempJoinButton.adjustsImageWhenDisabled = NO;
    [tempJoinButton addTarget:self action:@selector(join:) forControlEvents:UIControlEventTouchUpInside];
    tempJoinButton.backgroundColor = [UIColor clearColor];
    self.joinButton = tempJoinButton;
    [toolView addSubview:self.joinButton];
    
    UILabel *tempJoinTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, 5.0f , self.joinButton.frame.size.width , 15.0f)];
    tempJoinTitleLabel.backgroundColor = [UIColor clearColor];
    tempJoinTitleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    tempJoinTitleLabel.font = [UIFont systemFontOfSize:12];
    tempJoinTitleLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
    tempJoinTitleLabel.text = @"参加数";
    tempJoinTitleLabel.textAlignment = UITextAlignmentCenter;
    tempJoinTitleLabel.numberOfLines = 1;
    self.joinTitleLabel = tempJoinTitleLabel;
    [self.joinButton addSubview:self.joinTitleLabel];
    [tempJoinTitleLabel release];
    
    UILabel *tempJoinLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f, CGRectGetMaxY(interestTitleLabel.frame), self.joinButton.frame.size.width , 20.0f)];
    tempJoinLabel.backgroundColor = [UIColor clearColor];
    tempJoinLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    tempJoinLabel.font = [UIFont systemFontOfSize:12];
    tempJoinLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
    tempJoinLabel.text = @"要参加";
    tempJoinLabel.textAlignment = UITextAlignmentCenter;
    tempJoinLabel.numberOfLines = 1;
    self.joinLabel = tempJoinLabel;
    [self.joinButton addSubview:self.joinLabel];
    [tempJoinLabel release];
    
    UIImage *joinImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动详情_要参加" ofType:@"png"]];
    UIImageView *tempJoinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(((self.interestButton.frame.size.width - joinImage.size.width)/2) , 0.0f , joinImage.size.width, joinImage.size.height)];
    tempJoinImageView.image = joinImage;
    [joinImage release];
    self.joinImageView = tempJoinImageView;
    [self.joinButton addSubview:self.joinImageView];
    [tempJoinImageView release];
    
    //判断活动是否结束
    if (status)
    {
        //判断是否已参加
        if (isJoin)
        {
            self.joinButton.selected = YES;
            self.joinImageView.hidden = YES;
            self.joinTitleLabel.text = @"已参加";
            self.joinTitleLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
            self.joinLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
            [self.joinButton setBackgroundImage:[[UIImage imageNamed:@"参加活动选中.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:40] forState:UIControlStateNormal];
            
            //开始时间
            NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:[[self.activityArray objectAtIndex:activity_begin_time] intValue]];
            NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
            [outputFormat setDateFormat:@"yyyy/MM/dd"];
            NSString *dateString = [outputFormat stringFromDate:startDate];
            [outputFormat release];
            self.joinLabel.text = dateString;
        }
        else
        {
            //活动还没结束 但报名已截止
            if (isEndJoin)
            {
                self.joinButton.enabled = NO;
                self.joinImageView.hidden = YES;
                self.joinLabel.textColor = [UIColor colorWithRed:ACTIVITY_NUM_COLOR_RED green:ACTIVITY_NUM_COLOR_GREEN blue:ACTIVITY_NUM_COLOR_BLUE alpha:1];
                self.joinLabel.text = [self.activityArray objectAtIndex:activity_sum];
            }
            else
            {
                self.joinTitleLabel.hidden = YES;
            }
            [self.joinButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    else
    {
        //已结束
        self.joinButton.enabled = NO;
        self.joinImageView.hidden = YES;
        self.joinLabel.textColor = [UIColor colorWithRed:ACTIVITY_NUM_COLOR_RED green:ACTIVITY_NUM_COLOR_GREEN blue:ACTIVITY_NUM_COLOR_BLUE alpha:1];
        self.joinLabel.text = [self.activityArray objectAtIndex:activity_sum];
    }
    
}

//拨打电话
-(void)callPhone
{
	NSString *phone = [self.activityArray objectAtIndex:activity_phone];
	if (phone.length > 1)
    {
		[callSystemApp makeCall:phone];
	}
}

//显示位置
-(void)showMapByCoord
{
	NSString *lat = [self.activityArray objectAtIndex:activity_point_lat];
	NSString *lng = [self.activityArray objectAtIndex:activity_point_lng];
    
    BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc] init];
    baiduMap.latitude = [lat doubleValue];
    baiduMap.longitude = [lng doubleValue];
    baiduMap.addrStr = [self.activityArray objectAtIndex:activity_address];
    baiduMap.phone = [self.activityArray objectAtIndex:activity_phone];
    baiduMap.title = @"活动地址";
    baiduMap.navigationItem.title = @"活动地图";
    [self.navigationController pushViewController:baiduMap animated:YES];
    [baiduMap release];
}

//点击摄像头按钮
-(void)cameraButtonClick
{
    callBackTpye = loginCallBackOpenCamera;
    
    //判断用户是否登陆
    if (_isLogin == YES)
    {
        if ([self.userId intValue] != 0)
        {
            [self openCamera];
        }
        else
        {
            LoginViewController *login = [[LoginViewController alloc] init];
            login.delegate = self;
            [self.navigationController pushViewController:login animated:YES];
            [login release];
        }
    }
    else
    {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        [self.navigationController pushViewController:login animated:YES];
        [login release];
    }
}

//打开摄像头
-(void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *tempImagePickerController = [[UIImagePickerController alloc] init];
        tempImagePickerController.delegate = self;
        tempImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //tempImagePickerController.allowsEditing = YES;
        self.imagePickerController = tempImagePickerController;
        [tempImagePickerController release];
        
        [self presentModalViewController:self.imagePickerController animated:YES];
        
        //获取UIImagePickerController 底部bar
        
        UIView *bottomBar=[self findView:self.imagePickerController.view withName:@"PLCropOverlayBottomBar"];
        
        UIImageView *bottomBarImageForCamera = [bottomBar.subviews objectAtIndex:1];
        
        //添加自定义button 打开图片库
        UIButton *photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSString *picName = [UIScreen mainScreen].bounds.size.height < 568 ? @"icon_相机_相册" : @"icon_相机_相册_ip5";
        CGFloat fixSize = [UIScreen mainScreen].bounds.size.height < 568 ? 30.0f : 36.0f;
        
        [photoLibraryButton setFrame:CGRectMake( (bottomBarImageForCamera.frame.size.width - fixSize) - 10.0f , ((bottomBarImageForCamera.frame.size.height - fixSize)/2) ,fixSize , fixSize)];
        [photoLibraryButton setBackgroundImage :[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:picName ofType:@"png"]] forState:UIControlStateNormal];
        [photoLibraryButton addTarget:self action:@selector(openPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
        photoLibraryButton.backgroundColor = [UIColor clearColor];
        if (IOS_VERSION >= 7.0)
        {
            photoLibraryButton.frame = CGRectMake(320-fixSize-23, [UIScreen mainScreen].bounds.size.height-fixSize-23, fixSize, fixSize);
            [self.imagePickerController.view addSubview:photoLibraryButton];
        }else{
            [bottomBarImageForCamera addSubview:photoLibraryButton];
        }
    }
}

//打开图片库
-(void)openPhotoLibrary
{
    [self dismissModalViewControllerAnimated:NO];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *tempImagePickerController = [[UIImagePickerController alloc] init];
        tempImagePickerController.delegate = self;
        tempImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //tempImagePickerController.allowsEditing = YES;
        self.imagePickerController = tempImagePickerController;
        [tempImagePickerController release];
        
        [self presentModalViewController:self.imagePickerController animated:YES];
    }
}

//打开图片库
-(void)reportUrl
{
    NSString *reportUrl = [self.activityArray objectAtIndex:activity_report_url];
    if (reportUrl.length > 0)
    {
        browserViewController *browser = [[browserViewController alloc] init];
        browser.isShowTool = NO;
        browser.isSignFlag = YES;
        browser.url = reportUrl;
        browser.titleString = @"现场报道";
        browser.webTitle = [self.activityArray objectAtIndex:activity_title];
        [self.navigationController pushViewController:browser animated:YES];
        [browser release];
    }
}

//查找名字为name的子类
-(UIView *)findView:(UIView *)aView withName:(NSString *)name
{
    Class cl = [aView class];
    NSString *desc = [cl description];
    
    if ([name isEqualToString:desc])
        return aView;
    
    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
    {
        UIView *subView = [aView.subviews objectAtIndex:i];
        subView = [self findView:subView withName:name];
        if (subView)
            return subView;
    }
    return nil;
}

//感兴趣
-(void)interest:(id)sender
{
    if (!isInterested)
    {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        self.progressHUD = progressHUDTmp;
        [progressHUDTmp release];
        self.progressHUD.delegate = self;
        self.progressHUD.labelText = @"请稍后... ";
        [self.view addSubview:self.progressHUD];
        [self.view bringSubviewToFront:self.progressHUD];
        [self.progressHUD show:YES];
        
        NSString *reqUrl = @"/activityinterest.do?param=%@";
        
        NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [Common getSecureString],@"keyvalue",
                                     [NSNumber numberWithInt: SITE_ID],@"site_id",
                                     [self.activityArray objectAtIndex:activity_id],@"info_id",
                                     nil];
        
        [[DataManager sharedManager] accessService:jsontestDic
                                           command:OPERAT_SEND_ACTIVITY_INTERESTING
                                      accessAdress:reqUrl
                                          delegate:self
                                         withParam:nil];
    }
}

//参加
-(void)join:(id)sender
{
    callBackTpye = loginCallBackJoin;
    
    //判断用户是否登陆
    if (_isLogin == YES)
    {
        if ([self.userId intValue] != 0)
        {
            //判断参加报名还是取消报名
            if (isJoin)
            {
                // 创建一个UIActionSheet实例
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                                        delegate:self
                                                               cancelButtonTitle:nil
                                                          destructiveButtonTitle:@"不去了"
                                                               otherButtonTitles:nil];
                // 设置actionSheet为默认模式
                actionSheet.actionSheetStyle = UIBarStyleDefault;
                [actionSheet addButtonWithTitle:@"取消"];
                actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
                [actionSheet showInView:self.view];
                [actionSheet release];
                
                return;
            }
            else
            {
                //报名前需要实时判断是否过了报名时间
                NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
                long long int currentTime = (long long int)cTime;
                int regEndTime = [[self.activityArray objectAtIndex:activity_reg_end_time] intValue];
                isEndJoin = currentTime > regEndTime ? YES : NO;
                
                if (isEndJoin)
                {
                    //提示 已截至报名
                    [alertView showAlert:@"对不起,您来晚了,已过了报名时间"];
                    
                    self.joinButton.enabled = NO;
                    self.joinImageView.hidden = YES;
                    self.joinTitleLabel.hidden = NO;
                    self.joinTitleLabel.text = @"参加数";
                    self.joinTitleLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
                    self.joinLabel.textColor = [UIColor colorWithRed:ACTIVITY_NUM_COLOR_RED green:ACTIVITY_NUM_COLOR_GREEN blue:ACTIVITY_NUM_COLOR_BLUE alpha:1];
                    self.joinLabel.text = [self.activityArray objectAtIndex:activity_sum];
                    [self.joinButton setBackgroundImage:nil forState:UIControlStateNormal];
                    return;
                }
                
                //调用接口
                [self accessJoinService:1];
            }
        }
        else
        {
            LoginViewController *login = [[LoginViewController alloc] init];
            login.delegate = self;
            [self.navigationController pushViewController:login animated:YES];
            [login release];
        }
    }
    else
    {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        [self.navigationController pushViewController:login animated:YES];
        [login release];
    }
    
}

//取消参加
-(void)accessJoinService:(int)type
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"请稍后... ";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
    
    NSString *reqUrl = @"/attendactivity.do?param=%@";
    
    NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [Common getSecureString],@"keyvalue",
                                 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 self.userId,@"user_id",
                                 [self.activityArray objectAtIndex:activity_id],@"info_id",
                                 [NSNumber numberWithInt: type],@"type",
                                 nil];
    
    [[DataManager sharedManager] accessService:jsontestDic
                                       command:OPERAT_SEND_ACTIVITY_JOIN
                                  accessAdress:reqUrl
                                      delegate:self
                                     withParam:nil];
    
}

- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.picScrollView.contentOffset = CGPointMake(self.picScrollView.frame.size.width * whichPage, 0.0f);
	[UIView commitAnimations];
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
    if ([indexPath section] == 0)
    {
        //活动图片
        int countItems = [self.picArray count];
        if (countItems > [indexPath row])
        {
            NSArray *pic = [self.picArray objectAtIndex:[indexPath row]];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[[pic objectAtIndex:activity_pic_pic] dataUsingEncoding: NSUTF8StringEncoding]];
            
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
    }
    else if([indexPath section] == 1)
    {
        //用户图片
        int countItems = [self.userPicArray count];
        if (countItems > [indexPath row])
        {
            NSArray *pic = [self.userPicArray objectAtIndex:[indexPath row]];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[[pic objectAtIndex:activity_user_pic_thumb_pic] dataUsingEncoding: NSUTF8StringEncoding]];
            
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
            
            if ([indexPath section] == 0)
            {
                UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth , picHeight)];
                //banner图片
                myImageView *currentMyImageView = (myImageView *)[self.picScrollView viewWithTag:PIC_BASE_TAG + [indexPath row]];
                currentMyImageView.image = photo;
                [currentMyImageView stopSpinner];
            }
            else if([indexPath section] == 1)
            {
                UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(userPicWidth , userPicHeight)];
                //活动图片
                myImageView *currentMyImageView = (myImageView *)[self.userPicScrollView viewWithTag:USER_PIC_BASE_TAG + [indexPath row]];
                currentMyImageView.image = photo;
                [currentMyImageView stopSpinner];
            }
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

//网络获取更多数据
-(void)accessPicMoreService
{
    NSString *reqUrl = @"activityimglist.do?param=%@";
    
    //取本地最后一条
    int userPicId = 0;
    if ([self.userPicArray count] > 0)
    {
        NSArray *array = [self.userPicArray objectAtIndex:([self.userPicArray count] - 1)];
        userPicId = [[array objectAtIndex:activity_user_pic_id] intValue];
    }
    
    NSString *activityId =[self.activityArray objectAtIndex:activity_id];
    
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: userPicId],@"info_id",
                                 activityId,@"activity_id",
								 nil];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  activityId,@"activityId",
								  nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_ACTIVITY_USER_PIC_MORE
								  accessAdress:reqUrl
									  delegate:self
									 withParam:param];
}

//回归常态
-(void)backNormal
{
    //移出loading
    [self.spinner removeFromSuperview];
}

//插入第一张用户图片
-(void)insertUserPic:(NSNotification *)note
{
    NSDictionary *info  = [note object];
    NSString *uploadId = [info objectForKey:@"id"];
    NSString *uploadDesc = [info objectForKey:@"desc"];
    
    if ([uploadId intValue] != 0)
    {
        NSString *activityId =[self.activityArray objectAtIndex:activity_id];
        
        NSMutableArray *userPic = [[NSMutableArray alloc] init];
        [userPic addObject:uploadId];
        [userPic addObject:activityId];
        [userPic addObject:[info objectForKey:@"url"]];
        [userPic addObject:[info objectForKey:@"lessen_url"]];
        [userPic addObject:uploadDesc];
        [self.userPicArray insertObject:userPic atIndex:0];
        [userPic release];
        
        //内容
        NSArray *viewsToRemove = [self.userPicScrollView subviews];
        for (UIView *v in viewsToRemove)
        {
            [v removeFromSuperview];
        }
        
        int userPicCount = [self.userPicArray count];
        for(int i = 0;i < userPicCount;i++)
        {
            myImageView *myiv = [[myImageView alloc]initWithFrame:
                                 CGRectMake( (userPicWidth + 4.0f) * i, 0.0f, userPicWidth, userPicHeight) withImageId:USER_PIC_BASE_TAG + i];
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"活动详情_现场照片_s" ofType:@"png"]];
            myiv.image = img;
            [img release];
            myiv.mydelegate = self;
            myiv.tag = USER_PIC_BASE_TAG + i;
            
            [self.userPicScrollView addSubview:myiv];
            [myiv release];
            
            NSArray *userPic = [self.userPicArray objectAtIndex:i];
            NSString *userPicUrl = [userPic objectAtIndex:activity_user_pic_thumb_pic];
            NSString *userPicName = [Common encodeBase64:(NSMutableData *)[userPicUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (userPicUrl.length > 1)
            {
                UIImage *photo = [FileManager getPhoto:userPicName];
                if (photo.size.width > 2)
                {
                    myiv.image = [photo fillSize:CGSizeMake(userPicWidth,userPicHeight)];
                }
                else
                {
                    [myiv startSpinner];
                    [self startIconDownload:userPicUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                }
            }
        }
        
        //更新图片数字
        userPicNum = userPicNum+1;
        self.userPicNumLable.text = [NSString stringWithFormat:@"   秀一下您的现场照片吧 ( %d )",userPicNum];
        
        self.userPicScrollView.contentSize = CGSizeMake((userPicWidth + 4.0f) *userPicCount, userPicHeight);
    }
    
}

//追加用户图片
-(void)appendUserPic:(NSMutableArray *)data
{
    if (data != nil && [data count] > 0)
	{
        int oldUserPicCount = [self.userPicArray count];
        
        //合并数据
		for (int i = 0; i < [data count];i++ )
		{
			NSArray *array = [data objectAtIndex:i];
			[self.userPicArray addObject:array];
		}
        
        int userPicCount = [self.userPicArray count];
		
		for(int i = oldUserPicCount;i < userPicCount;i++)
        {
            myImageView *myiv = [[myImageView alloc]initWithFrame:
                                 CGRectMake( (userPicWidth + 4.0f) * i, 0.0f, userPicWidth, userPicHeight) withImageId:USER_PIC_BASE_TAG + i];
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"活动详情_现场照片_s" ofType:@"png"]];
            myiv.image = img;
            [img release];
            myiv.mydelegate = self;
            myiv.tag = USER_PIC_BASE_TAG + i;
            
            [self.userPicScrollView addSubview:myiv];
            [myiv release];
            
            NSArray *userPic = [self.userPicArray objectAtIndex:i];
            NSString *userPicUrl = [userPic objectAtIndex:activity_user_pic_thumb_pic];
            NSString *userPicName = [Common encodeBase64:(NSMutableData *)[userPicUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (userPicUrl.length > 1)
            {
                UIImage *photo = [FileManager getPhoto:userPicName];
                if (photo.size.width > 2)
                {
                    myiv.image = [photo fillSize:CGSizeMake(userPicWidth,userPicHeight)];
                }
                else
                {
                    [myiv startSpinner];
                    [self startIconDownload:userPicUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                }
            }
        }
        
        self.userPicScrollView.contentSize = CGSizeMake((userPicWidth + 4.0f) *userPicCount, userPicHeight);
		
        _loadingMore = NO;
        
	}
    
    [self backNormal];
}

//感兴趣成功
- (void)didFinishInterest:(NSMutableArray *)data
{
    int isSuccess = 0;
    if (data != nil && [data count] >0)
    {
        isSuccess = [[data objectAtIndex:0] intValue];
    }
    
    if (isSuccess == 1)
    {
        isInterested = YES;
        self.interestButton.selected = YES;
        self.interestButton.enabled = NO;
        self.interestTitleLabel.hidden = NO;
        self.interestImageView.hidden = YES;
        self.interestLabel.textColor = [UIColor colorWithRed:ACTIVITY_NUM_COLOR_RED green:ACTIVITY_NUM_COLOR_GREEN blue:ACTIVITY_NUM_COLOR_BLUE alpha:1];
        self.interestLabel.text = [NSString stringWithFormat:@"%d",([[self.activityArray objectAtIndex:activity_interests] intValue] + 1)];
        
        NSString *activityId =[self.activityArray objectAtIndex:activity_id];
        
        //数据库记录 +1
        NSString *sql = [NSString stringWithFormat:@"update %@ set interests = interests + 1 where id = %@",T_ACTIVITY,activityId];
        [DBOperate querySql:sql];
        
        //记录已感兴趣
        NSArray *interestedIds = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag"
                                       theColumnValue:@"interestedId" withAll:NO];
        if ([interestedIds count]>0)
        {
            NSString *interestedIdString = [[interestedIds objectAtIndex:0] objectAtIndex:1];
            NSString *NewInterestedIdString = [NSString stringWithFormat:@"%@,%@",interestedIdString,activityId];
            
            NSString *sql = [NSString stringWithFormat:@"update %@ set value = '%@' where tag = 'interestedId'",T_SYSTEM_CONFIG,NewInterestedIdString];
            [DBOperate querySql:sql];
        }
        else
        {
            //不存在则添加一条
            NSString *sql = [NSString stringWithFormat:@"insert into %@ values('interestedId','%@')",T_SYSTEM_CONFIG,activityId];
            [DBOperate querySql:sql];
        }
        
        //移出提示层
        if (self.progressHUD)
        {
            [progressHUD hide:YES afterDelay:0.0f];
        }
        
    }
    else
    {
        if (self.progressHUD) {
            progressHUD.labelText = @"请求失败";
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            [progressHUD hide:YES afterDelay:1.0];
        }
    }
}

//参加成功
- (void)didFinishJoin:(NSMutableArray *)data
{
    int isSuccess = 0;
    if (data != nil && [data count] >0)
    {
        isSuccess = [[data objectAtIndex:0] intValue];
    }
    
    if (isSuccess == 1)
    {
        if (isJoin)
        {
            //取消报名
            isJoin = NO;
            self.joinButton.selected = NO;
            self.joinTitleLabel.hidden = YES;
            self.joinImageView.hidden = NO;
            self.joinLabel.textColor = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1];
            self.joinLabel.text = @"要参加";
            [self.joinButton setBackgroundImage:nil forState:UIControlStateNormal];
            
            NSString *activityId =[self.activityArray objectAtIndex:activity_id];
            
            //数据库记录 -1
            NSString *sql = [NSString stringWithFormat:@"update %@ set sum = sum - 1 where id = %@",T_ACTIVITY,activityId];
            [DBOperate querySql:sql];
            
            //删除已参加ID
            NSArray *joinActivityIds = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag"
                                             theColumnValue:@"activityId" withAll:NO];
            if ([joinActivityIds count]>0)
            {
                NSString *joinActivityIdString = [[joinActivityIds objectAtIndex:0] objectAtIndex:1];
                
                if ([joinActivityIdString rangeOfString:@"," options:NSCaseInsensitiveSearch].location == NSNotFound)
                {
                    if ([joinActivityIdString isEqualToString:activityId])
                    {
                        NSString *sql = [NSString stringWithFormat:@"delete from %@ where tag = 'activityId'",T_SYSTEM_CONFIG];
                        [DBOperate querySql:sql];
                    }
                }
                else
                {
                    NSMutableArray *joinActivityIdArray = (NSMutableArray *)[joinActivityIdString componentsSeparatedByString:@","];
                    if([joinActivityIdArray indexOfObject:activityId] != NSNotFound)
                    {
                        [joinActivityIdArray removeObject:activityId];
                        
                        NSString *NewJoinActivityIdString = [joinActivityIdArray componentsJoinedByString:@","];
                        NSString *sql = [NSString stringWithFormat:@"update %@ set value = '%@' where tag = 'activityId'",T_SYSTEM_CONFIG,NewJoinActivityIdString];
                        [DBOperate querySql:sql];
                        
                    }
                }
                
            }
            
            //移出提示层
            if (self.progressHUD)
            {
                [progressHUD hide:YES afterDelay:0.0];
            }
        }
        else
        {
            //报名成功
            isJoin = YES;
            self.joinButton.selected = YES;
            self.joinTitleLabel.hidden = NO;
            self.joinImageView.hidden = YES;
            self.joinTitleLabel.text = @"已参加";
            self.joinTitleLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
            self.joinLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
            [self.joinButton setBackgroundImage:[[UIImage imageNamed:@"参加活动选中.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:40] forState:UIControlStateNormal];
            
            //开始时间
            NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:[[self.activityArray objectAtIndex:activity_begin_time] intValue]];
            NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
            [outputFormat setDateFormat:@"yyyy/MM/dd"];
            NSString *dateString = [outputFormat stringFromDate:startDate];
            [outputFormat release];
            self.joinLabel.text = dateString;
            
            NSString *activityId =[self.activityArray objectAtIndex:activity_id];
            
            //数据库记录 +1
            NSString *sql = [NSString stringWithFormat:@"update %@ set sum = sum + 1 where id = %@",T_ACTIVITY,activityId];
            [DBOperate querySql:sql];
            
            //记录已参加
            NSArray *joinActivityIds = [DBOperate queryData:T_SYSTEM_CONFIG theColumn:@"tag"
                                             theColumnValue:@"activityId" withAll:NO];
            if ([joinActivityIds count]>0)
            {
                NSString *joinActivityIdString = [[joinActivityIds objectAtIndex:0] objectAtIndex:1];
                NSString *NewJoinActivityIdString = [NSString stringWithFormat:@"%@,%@",joinActivityIdString,activityId];
                
                NSString *sql = [NSString stringWithFormat:@"update %@ set value = '%@' where tag = 'activityId'",T_SYSTEM_CONFIG,NewJoinActivityIdString];
                [DBOperate querySql:sql];
            }
            else
            {
                //不存在则添加一条
                NSString *sql = [NSString stringWithFormat:@"insert into %@ values('activityId','%@')",T_SYSTEM_CONFIG,activityId];
                [DBOperate querySql:sql];
            }
            
            //移出提示层
            if (self.progressHUD)
            {
                progressHUD.labelText = @"报名成功";
                progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
                progressHUD.mode = MBProgressHUDModeCustomView;
                [progressHUD hide:YES afterDelay:1.5];
            }
            
        }
        
    }
    else
    {
        if (self.progressHUD) {
            progressHUD.labelText = @"请求失败";
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            [progressHUD hide:YES afterDelay:1.0];
        }
    }
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch(commandid)
    {
            //更多图片刷新
        case OPERAT_ACTIVITY_USER_PIC_MORE:
            [self performSelectorOnMainThread:@selector(appendUserPic:) withObject:resultArray waitUntilDone:NO];
            break;
            
            //感兴趣
        case OPERAT_SEND_ACTIVITY_INTERESTING:
            [self performSelectorOnMainThread:@selector(didFinishInterest:) withObject:resultArray waitUntilDone:NO];
            break;
            
            //参加
        case OPERAT_SEND_ACTIVITY_JOIN:
            [self performSelectorOnMainThread:@selector(didFinishJoin:) withObject:resultArray waitUntilDone:NO];
            break;
            
        default:   ;
    }
}

#pragma mark -
#pragma mark 图片滚动委托

- (void)imageViewTouchesEnd:(int)picId
{
    if (picId >= PIC_BASE_TAG && picId < USER_PIC_BASE_TAG)
    {
        //活动图片
        picDetailViewController *picDetail = [[picDetailViewController alloc] init];
        picDetail.picArray = self.picArray;
        picDetail.photoWith = 320.0f;
        picDetail.photoHigh = 240.0f;
        picDetail.chooseIndex = picId - PIC_BASE_TAG;
        [self.navigationController pushViewController:picDetail animated:YES];
        [picDetail release];
    }
    else if(picId >= USER_PIC_BASE_TAG)
    {
        //用户现场图片
        activityUserPicDetailViewController *picDetail = [[activityUserPicDetailViewController alloc] init];
        picDetail.picArray = [[NSMutableArray alloc] initWithArray:self.userPicArray];
        picDetail.photoWith = 320.0f;
        picDetail.photoHigh = 460.0f;
        picDetail.chooseIndex = picId - USER_PIC_BASE_TAG;
        [self.navigationController pushViewController:picDetail animated:YES];
        [picDetail release];
    }
    
}

#pragma mark - LoginViewDelegate Method
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    if (isLoginSuccess)
    {
        //获取当前用户的user_id
        NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
        if ([memberArray count] > 0)
        {
            self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
        }
        else
        {
            self.userId = @"0";
        }
        
        switch (callBackTpye)
        {
            case loginCallBackOpenCamera:
                
                //打开摄像头
                [self cameraButtonClick];
                
                break;
                
            case loginCallBackJoin:
                
                //判断是否已参加
                if (isJoin)
                {
                    self.joinButton.selected = YES;
                    self.joinImageView.hidden = YES;
                    self.joinTitleLabel.hidden = NO;
                    self.joinTitleLabel.text = @"已参加";
                    self.joinTitleLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
                    self.joinLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
                    [self.joinButton setBackgroundImage:[[UIImage imageNamed:@"参加活动选中.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:40] forState:UIControlStateNormal];
                    
                    //开始时间
                    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:[[self.activityArray objectAtIndex:activity_begin_time] intValue]];
                    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
                    [outputFormat setDateFormat:@"yyyy/MM/dd"];
                    NSString *dateString = [outputFormat stringFromDate:startDate];
                    [outputFormat release];
                    self.joinLabel.text = dateString;
                }
                else
                {
                    //没参加 直接参加操作
                    [self join:self.joinButton];
                    [self.joinButton setBackgroundImage:nil forState:UIControlStateNormal];
                }
                
                break;
                
            default:
                break;
        }
        
	}
}

#pragma mark -
#pragma mark actionsheet委托

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //调用接口
        [self accessJoinService:2];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    activityShareViewController *activityShareView = [[activityShareViewController alloc] init];
    
    if (image.size.height > image.size.width) {
        activityShareView.shareImage = [image fillSize:CGSizeMake( 320.0f , 480.0f )];
    } else {
        activityShareView.shareImage = [image fillSize:CGSizeMake( 480.0f , 320.0f )];
    }
    activityShareView.user_id = [self.userId intValue];
    activityShareView.info_id = [[self.activityArray objectAtIndex:activity_id] intValue];
    activityShareView.tableFlag = status;
    [self.navigationController pushViewController:activityShareView animated:YES];
    [activityShareView release];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        [navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    }
    
}

// 分享委托
#pragma mark - Share Delegate
- (NSDictionary *)shareSheetRetureValue  // dufu add 2013.05.10
{
    NSString *picUrl = [activityArray objectAtIndex:activity_pic];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    UIImage *image = nil;
    if (picUrl.length > 1)
    {
        UIImage *pic = [FileManager getPhoto:picName];
        if (pic.size.width > 2)
        {
            image = [pic fillSize:CGSizeMake(picWidth,picHeight)];
        }
        else
        {
            image = pic;
        }
    }
    
	NSString *link = [activityArray objectAtIndex:activity_report_url];
    
    if (link.length == 0) {
        link = [NSString stringWithFormat:@"%@/app/jump",DETAIL_SHARE_LINK];
    }
    
	NSString *content = [activityArray objectAtIndex:activity_title];
    
    NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
    NSDictionary *dict;
    if (image == nil) {
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl, nil];
    } else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                image,ShareImage,
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl, nil];
    }
    
    return dict;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    if (scrollView == self.userPicScrollView)
    //    {
    //        if (_isAllowLoadingMore && !_loadingMore)
    //        {
    //            float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
    //            if (rightEdge > scrollView.contentSize.width + 10.0f)
    //            {
    //                //松开 载入更多
    //                NSLog(@"------松开加载更多------");
    //
    //            }
    //            else
    //            {
    //                NSLog(@"------右拉加载更多------");
    //            }
    //        }
    //    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (scrollView == self.userPicScrollView)
    {
        if (_isAllowLoadingMore && !_loadingMore)
        {
            float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
            if (rightEdge > scrollView.contentSize.width + 10.0f)
            {
                //松开 载入更多
                _loadingMore = YES;
                
                //添加loading图标
                UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
                [tempSpinner setCenter:CGPointMake(self.userPicScrollView.contentSize.width + 20.0f, self.userPicScrollView.frame.size.height / 2.0)];
                self.spinner = tempSpinner;
                [self.userPicScrollView addSubview:self.spinner];
                [self.spinner startAnimating];
                [tempSpinner release];
                
                //数据
                [self accessPicMoreService];
                
            }
            else
            {
                //NSLog(@"----右拉加载更多------");
            }
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.userPicScrollView)
    {
        float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
        if (rightEdge >= scrollView.contentSize.width && rightEdge > self.userPicScrollView.frame.size.width && [self.userPicArray count] >= 6)
        {
            _isAllowLoadingMore = YES;
        }
        else
        {
            _isAllowLoadingMore = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == self.picScrollView)
    {
        CGPoint offset = scrollView.contentOffset;
        self.pageControll.currentPage = offset.x / self.picScrollView.frame.size.width;
    }
    
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
    self.progressHUD.delegate = nil;
	self.progressHUD = nil;
    self.mainScrollView.delegate = nil;
    self.mainScrollView = nil;
    self.picScrollView.delegate = nil;
    self.picScrollView = nil;
    self.userPicScrollView.delegate = nil;
    self.userPicScrollView = nil;
    self.pageControll = nil;
    self.imagePickerController = nil;
    self.toolBar = nil;
    self.userPicNumLable = nil;
    self.interestButton = nil;
    self.interestTitleLabel = nil;
    self.interestLabel = nil;
    self.interestImageView = nil;
    self.joinButton = nil;
    self.joinTitleLabel = nil;
    self.joinLabel = nil;
    self.joinImageView = nil;
    self.activityArray = nil;
    self.picArray = nil;
    self.userPicArray = nil;
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
    self.imageDownloadsInWaiting = nil;
    self.imageDownloadsInProgress = nil;
    self.userId = nil;
}


- (void)dealloc {
    
    self.spinner = nil;
    self.progressHUD.delegate = nil;
	self.progressHUD = nil;
    self.mainScrollView.delegate = nil;
    self.mainScrollView = nil;
    self.picScrollView.delegate = nil;
    self.picScrollView = nil;
    self.userPicScrollView.delegate = nil;
    self.userPicScrollView = nil;
    self.pageControll = nil;
    self.imagePickerController = nil;
    self.toolBar = nil;
    self.userPicNumLable = nil;
    self.interestButton = nil;
    self.interestTitleLabel = nil;
    self.interestLabel = nil;
    self.interestImageView = nil;
    self.joinButton = nil;
    self.joinTitleLabel = nil;
    self.joinLabel = nil;
    self.joinImageView = nil;
    [self.activityArray release];
    [self.picArray release];
    [self.userPicArray release];
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
    self.imageDownloadsInWaiting = nil;
    self.imageDownloadsInProgress = nil;
    self.userId = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ShareSheet release];  // dufu add 2013.05.10
    [super dealloc];
}

@end
