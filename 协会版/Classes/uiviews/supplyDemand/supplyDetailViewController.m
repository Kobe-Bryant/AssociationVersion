//
//  supplyDetailViewController.m
//  Profession
//
//  Created by siphp on 12-8-14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "supplyDetailViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "UIImageScale.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "picDetailViewController.h"
#import "callSystemApp.h"   
//#import "ShareToBlogViewController.h"  // dufu mod 2013.04.25
#import "alertView.h"
#import "shopDetailViewController.h"
#import "LoginViewController.h"
#import "CommentViewController.h"

@implementation supplyDetailViewController

@synthesize supplyID;
@synthesize supplyArray;
@synthesize supplyPicArray;
@synthesize scrollView;
@synthesize showPicScrollView;
@synthesize pageControll;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize containerView;
@synthesize textView;
@synthesize tempTextContent;
@synthesize progressHUD;
//@synthesize actionSheet;  // dufu mod 2013.04.25
@synthesize userId;
@synthesize commentTotal;
@synthesize isFrom;

@synthesize ShareSheet; // dufu add 2013.04.25

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

-(id)init
{
	self = [super init];
	if(self)
	{
		//注册键盘通知
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillHide:) 
													 name:UIKeyboardWillHideNotification 
												   object:nil];		
	}
	
	return self;
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
////    commentTotal = [NSString stringWithFormat:@"%d",[[[self.supplyArray objectAtIndex:0] objectAtIndex:supply_commentTotal] intValue]];
//    NSString *str = [NSString stringWithFormat:@"%@评论",commentTotal];
//    barbutton = [[UIBarButtonItem alloc] 
//								 initWithTitle:str 
//								 style:UIBarButtonItemStyleBordered 
//								 target:self action:@selector(commentListAction)]; 
//    self.navigationItem.rightBarButtonItem = barbutton;  
//	//[barbutton release]; 
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
    
	photoWith = 220.0f;
	photoHigh = 220.0f;
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
	
	self.tempTextContent = @"";
	
	UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height - 40.0f)];
	tmpScroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	tmpScroll.pagingEnabled = NO;
	tmpScroll.delegate = self;
	tmpScroll.showsHorizontalScrollIndicator = NO;
	tmpScroll.showsVerticalScrollIndicator = NO;
	tmpScroll.bounces = YES;
	self.scrollView = tmpScroll;
	[self.view addSubview:self.scrollView];
	[tmpScroll release];  
	
	//取供应的数据
	if (self.supplyArray == nil || [self.supplyArray count] == 0) 
	{
		self.supplyArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY theColumn:@"id" theColumnValue:supplyID  withAll:NO];
	}
	
	NSString *supplyTitle = [[self.supplyArray objectAtIndex:0] objectAtIndex:supply_title];
	self.title = supplyTitle;
	
	//取该记录对应的图片数据
	if (self.supplyPicArray == nil || [self.supplyPicArray count] == 0)
	{
        NSString *picCatId = [[self.supplyArray objectAtIndex:0] objectAtIndex:supply_catid];
        self.supplyPicArray = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_PIC theColumn:@"supply_id" equalValue:supplyID theColumn:@"cat_id" equalValue:picCatId];
	}
	
	if (self.supplyPicArray == nil || [self.supplyPicArray count] == 0) 
	{
		supplyShowHeight = 0.0f;
	}
	else
	{
		supplyShowHeight = photoHigh;
		[self showSupplyPic];
	}
	
	NSArray *supplyInfo = [self.supplyArray objectAtIndex:0];
    
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
	
	//判断该信息是否为当前用户收藏
	NSMutableArray *favorite = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_FAVORITE theColumn:@"supply_id" equalValue:supplyID theColumn:@"user_id" equalValue:self.userId];
	
	if (favorite == nil || [favorite count] == 0) 
	{
		//没有收藏
		isFavorite = NO;
	}
	else 
	{
		//已收藏
		isFavorite = YES;
	}	
	
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, supplyShowHeight + 5, 280, 30)];
	[titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
	titleLabel.textColor = [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];
	titleLabel.text = [supplyInfo objectAtIndex:supply_title];
	titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
	titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    CGSize labelsize = [titleLabel.text sizeWithFont:[UIFont systemFontOfSize:18.0f] constrainedToSize:CGSizeMake(280, 1000) lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"labelsize.height = %f",labelsize.height);
    titleLabel.frame = CGRectMake(20, supplyShowHeight + 5, 280, labelsize.height);
	[self.scrollView addSubview:titleLabel];
	[titleLabel release];
    
    supplyShowHeight += labelsize.height + 15.f; // dufu add 2013.04.28
    
    int price = [[supplyInfo objectAtIndex:supply_price] intValue]; // dufu add 2013.04.28
	
    if (price > 0) {  // dufu add 2013.04.28
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, supplyShowHeight, 280, 30)];
        [priceLabel setFont:[UIFont systemFontOfSize:14.0f]];
        priceLabel.textColor = [UIColor colorWithRed:0.2 green: 0.2 blue: 0.2 alpha:1.0];
        priceLabel.text = @"价        格 :";
        priceLabel.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:priceLabel];
        [priceLabel release];
        
        UILabel *priceInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, supplyShowHeight, 280, 30)];
        [priceInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        priceInfoLabel.textColor = [UIColor colorWithRed:1 green: 0.6 blue: 0 alpha:1.0];
        priceInfoLabel.text = [supplyInfo objectAtIndex:supply_price];
        priceInfoLabel.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:priceInfoLabel];
        [priceInfoLabel release];
        
        supplyShowHeight += 30.f;  // dufu add 2013.04.28
        
        UILabel *favoriteLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, supplyShowHeight, 280, 30)];
        [favoriteLabel setFont:[UIFont systemFontOfSize:14.0f]];
        favoriteLabel.textColor = [UIColor colorWithRed:0.2 green: 0.2 blue: 0.2 alpha:1.0];
        favoriteLabel.text = @"收        藏 :";
        favoriteLabel.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:favoriteLabel];
        [favoriteLabel release];
        
        UILabel *favoriteInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, supplyShowHeight, 280, 30)];
        favoriteInfoLabel.tag = 1000;
        [favoriteInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
        favoriteInfoLabel.textColor = [UIColor colorWithRed:0.2 green: 0.2 blue: 0.2 alpha:1.0];
        favoriteInfoLabel.text = [supplyInfo objectAtIndex:supply_favorite];
        favoriteInfoLabel.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:favoriteInfoLabel];
        [favoriteInfoLabel release];
        
        supplyShowHeight += 20.f;  // dufu add 2013.04.28
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, supplyShowHeight, 280, 30)];
        [descLabel setFont:[UIFont systemFontOfSize:14.0f]];
        descLabel.textColor = [UIColor colorWithRed:0.2 green: 0.2 blue: 0.2 alpha:1.0];
        descLabel.text = @"介        绍 :";
        descLabel.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:descLabel];
        [descLabel release];
        
        supplyShowHeight += 20.f;  // dufu add 2013.04.28
    }

	UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[descInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
	descInfoLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
	descInfoLabel.backgroundColor = [UIColor clearColor];
	descInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
	descInfoLabel.numberOfLines = 0;
	NSString *descText = [supplyInfo objectAtIndex:supply_desc];
	descInfoLabel.text = descText;
	CGSize constraint = CGSizeMake(280, 20000.0f);
	CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	float fixHeight = size.height + 10.0f;
	fixHeight = fixHeight == 0 ? 30.f : MAX(fixHeight,30.0f);
	[descInfoLabel setFrame:CGRectMake(20, supplyShowHeight, 280, fixHeight)];
	[self.scrollView addSubview:descInfoLabel];
	[descInfoLabel release];
    
    supplyShowHeight += fixHeight + 5.0f;  // dufu add 2013.04.28
	
    // 公司名称背景
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10.0f, supplyShowHeight, 300.0f, 44.0f);
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形上" ofType:@"png"]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showCompany) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    // 公司前图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 7.f, 30.f, 30.0f)];
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"地址icon" ofType:@"png"]];
    [button addSubview:imageView];
    [imageView release];
    // 公司名称
    UILabel *companyInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.f, 0.f, 200.f, 44.f)];
	[companyInfoLabel setFont:[UIFont systemFontOfSize:16.0f]];
	companyInfoLabel.textColor = [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];
	companyInfoLabel.text = [supplyInfo objectAtIndex:supply_company_name];
	companyInfoLabel.backgroundColor = [UIColor clearColor];
	companyInfoLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	[button addSubview:companyInfoLabel];
	[companyInfoLabel release];
    // 公司后图片
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.f, 7.f, 30.f, 30.0f)];
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_向右箭头" ofType:@"png"]];
    [button addSubview:imageView];
    [imageView release];
	
    supplyShowHeight += 44.f;  // dufu add 2013.04.28
    
    // 电话号码背景
    UIButton *buttonphone = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonphone.frame = CGRectMake(10.0f, supplyShowHeight, 300.0f, 44.0f);
    [buttonphone setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形下" ofType:@"png"]] forState:UIControlStateNormal];
    [buttonphone addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:buttonphone];
    // 电话号码前图片
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 7.f, 30.f, 30.0f)];
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"电话icon" ofType:@"png"]];
    [buttonphone addSubview:imageView];
    [imageView release];
    // 电话号码
    UILabel *telLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.f, 0.f, 200.f, 44.f)];
	[telLabel setFont:[UIFont systemFontOfSize:16.0f]];
	telLabel.textColor = [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];
	telLabel.text = [supplyInfo objectAtIndex:supply_tel];
	telLabel.backgroundColor = [UIColor clearColor];
	telLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	[buttonphone addSubview:telLabel];
	[telLabel release];
    // 电话号码后图片
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(260.f, 7.f, 30.f, 30.0f)];
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
    [buttonphone addSubview:imageView];
    [imageView release];
    
    supplyShowHeight += 44.f;  // dufu add 2013.04.28
	
	self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, supplyShowHeight + 50.0f);
	
	//底部工具栏
	self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 84, 320, 40)];
	self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 235, 40)];
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 3;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.textColor = [UIColor grayColor]; 
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.textView.text = @"说两句";
    
	//工具栏背景
	UIImage *toolBackgroundImg = [[UIImage imageNamed:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *toolBackground = [[UIImageView alloc] initWithImage:toolBackgroundImg];
    toolBackground.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    toolBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	//文本框
	UIImage *rawEntryBackground = [[UIImage imageNamed:@"MessageEntryInputField.png"]  stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:rawEntryBackground];
    entryImageView.frame = CGRectMake(5, 0, 240, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	entryImageView.tag = 2000;
	
	[self.containerView addSubview:toolBackground];
	[self.containerView addSubview:self.textView];
	[self.containerView addSubview:entryImageView];
	
	//分享按钮
	UIImageView *shareButton = [[UIImageView alloc]initWithFrame:CGRectMake(240.0f, 0.0f, 40.0f, 40.0f)];
	shareButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"分享按钮" ofType:@"png"]];
	shareButton.tag = 2001;
	
	//绑定点击事件
	shareButton.userInteractionEnabled = YES;
	UITapGestureRecognizer *shareSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share)];
	[shareButton addGestureRecognizer:shareSingleTap];
	[shareSingleTap release];
	
	[self.containerView addSubview:shareButton];
	[shareButton release];
	
	//收藏按钮
	UIImageView *favoriteButton = [[UIImageView alloc]initWithFrame:CGRectMake(280.0f, 0.0f, 40.0f, 40.0f)];
	
	if (isFavorite) 
	{
		favoriteButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"已收藏按钮" ofType:@"png"]];
		favoriteButton.tag = 2002;
	}
	else
	{
		favoriteButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"收藏按钮" ofType:@"png"]];
		favoriteButton.tag = 2002;
		
		//绑定点击事件
		favoriteButton.userInteractionEnabled = YES;
		UITapGestureRecognizer *favoriteSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favorite)];
		[favoriteButton addGestureRecognizer:favoriteSingleTap];
		[favoriteSingleTap release];
	}
	
	[self.containerView addSubview:favoriteButton];
	[favoriteButton release];
	
	//字数统计
	UILabel *remainCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(265.0f, 5.0f, 50.0f, 20.0f)];
	[remainCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
	remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	remainCountLabel.tag = 2004;
	remainCountLabel.text = @"140/140";
	remainCountLabel.hidden = YES;
	remainCountLabel.backgroundColor = [UIColor clearColor];
	remainCountLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	remainCountLabel.textAlignment = UITextAlignmentCenter;
	[self.containerView addSubview:remainCountLabel];
	[remainCountLabel release];
	
	//添加发送按钮
	UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
	UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
	
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(self.containerView.frame.size.width - 55, 8, 50, 27);
	sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendBtn setTitle:@"发送" forState:UIControlStateNormal];
	[sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
	sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
	sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	sendBtn.tag = 2003;
	sendBtn.hidden = YES;
	[sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendBtn addTarget:self action:@selector(publishComment:) forControlEvents:UIControlEventTouchUpInside];
	[sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
	[sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.containerView addSubview:sendBtn];
	
	[self.view addSubview:self.containerView];
    
    NSString *str = [NSString stringWithFormat:@"%@评论",commentTotal];
    barbutton = [[UIBarButtonItem alloc] 
                 initWithTitle:str 
                 style:UIBarButtonItemStyleBordered 
                 target:self action:@selector(commentListAction)]; 
    self.navigationItem.rightBarButtonItem = barbutton;  
    self.navigationItem.title = @"详情";   // dufu add 2013.04.28
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
	
	//判断该信息是否为当前用户收藏
	NSMutableArray *favorite = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_FAVORITE theColumn:@"supply_id" equalValue:supplyID theColumn:@"user_id" equalValue:self.userId];
	
	if (favorite == nil || [favorite count] == 0) 
	{
		//没有收藏
		isFavorite = NO;
	}
	else 
	{
		//已收藏
		isFavorite = YES;
	}
}  

-(void)showSupplyPic
{
	UIImageView *showBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, photoHigh)];
	UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"详情图片背景" ofType:@"png"]];
	
	showBackGround.image = [img fillSize:CGSizeMake(self.view.frame.size.width, photoHigh)];
	[img release];
	[self.scrollView addSubview:showBackGround];
	[showBackGround release];
	
	int pageCount = [self.supplyPicArray count];
	
	if (self.showPicScrollView == nil && self.supplyPicArray != nil && pageCount > 0)
	{
		UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, photoHigh)];
		tmpScroll.contentSize = CGSizeMake(pageCount * self.view.frame.size.width, photoHigh);
		tmpScroll.pagingEnabled = YES;
		tmpScroll.delegate = self;
		tmpScroll.showsHorizontalScrollIndicator = NO;
		tmpScroll.showsVerticalScrollIndicator = NO;
		tmpScroll.tag = 100;
		self.showPicScrollView=tmpScroll;
		[tmpScroll release];                
		
		for(int i = 0;i < pageCount;i++)
		{
			myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake(i * self.showPicScrollView.frame.size.width + 50,0,
											photoWith, photoHigh) withImageId:i];
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"供应详情默认图片" ofType:@"png"]];
			myiv.image = img;
			[img release];
			myiv.mydelegate = self;
			myiv.tag = 200+i;                                        
			
			[self.showPicScrollView addSubview:myiv];
			[myiv release];
			
			if (self.supplyPicArray != nil && pageCount > 0 && i < pageCount) 
			{
				NSArray *supplyPic = [self.supplyPicArray objectAtIndex:i];
				
				NSString *photoUrl = [supplyPic objectAtIndex:supply_pic_pic];
				
				NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
				
				if (photoUrl.length > 1) 
				{
					UIImage *photo = [FileManager getPhoto:picName];
					if (photo.size.width > 2)
					{
						myiv.image = [photo fillSize:CGSizeMake(photoWith,photoHigh)];
					}
					else
					{
						[myiv startSpinner];
						[self startIconDownload:photoUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
					}
				}
			}
		}		
	}		            
	if(self.pageControll == nil && self.supplyPicArray != nil && pageCount > 0)
	{
		UIPageControl *pc = [[UIPageControl alloc] initWithFrame:CGRectMake(120, 200, 80, 16)];
		self.pageControll = pc;			
		[pc release];
		self.pageControll.backgroundColor = [UIColor clearColor];
		self.pageControll.numberOfPages = pageCount;
		self.pageControll.currentPage = 0;
		[pageControll addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
		
	}
	[self.scrollView addSubview:self.showPicScrollView];
	[self.scrollView addSubview:self.pageControll]; 
	
}

//保存缓存图片
-(BOOL)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
	
	int countItems = [self.supplyPicArray count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *supplyPic = [self.supplyPicArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[supplyPic objectAtIndex:supply_pic_pic] dataUsingEncoding: NSUTF8StringEncoding]];
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
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
			myImageView *currentMyImageView = (myImageView *)[self.view viewWithTag:200+[indexPath row]];
			currentMyImageView.image = photo;
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

//查看公司黄页
-(void)showCompany
{
    for (UIViewController *currentController in self.navigationController.viewControllers) 
	{
		if ([currentController isKindOfClass:[shopDetailViewController class]]) {
			[self.navigationController popToViewController:currentController animated:YES];
            return;
		}
	}
	//这里跳转到黄页详情页面
	NSString *shopID = [[supplyArray objectAtIndex:0] objectAtIndex:supply_company_id];
	shopDetailViewController *shopDetail = [[shopDetailViewController alloc] init];			
	shopDetail.shopID = shopID;
	[self.navigationController pushViewController:shopDetail animated:YES];
	[shopDetail release];
}

//拨打电话
-(void)callPhone
{
	NSString *supplyTel = [[supplyArray objectAtIndex:0] objectAtIndex:supply_tel];
	if (supplyTel.length > 1) {
		[callSystemApp makeCall:supplyTel];
	}
}

-(void)buttonChange:(BOOL)isKeyboardShow
{
	//判断软键盘显示
	if (isKeyboardShow) 
	{
        UIButton *sendBtn = (UIButton *)[self.containerView viewWithTag:2003];
        
		//增长输入框
        if (sendBtn.hidden) 
        {
            UIImageView *entryImageView = (UIImageView *)[self.containerView viewWithTag:2000];
            CGRect entryFrame = entryImageView.frame;
            entryFrame.size.width += 20.0f;
            
            CGRect textFrame = self.textView.frame;
            textFrame.size.width += 20.0f;
            
            entryImageView.frame = entryFrame;
            self.textView.frame = textFrame;
        }
        
        //隐藏分享 收藏按钮 
		UIImageView *shareButton = (UIImageView *)[self.containerView viewWithTag:2001];
		UIImageView *favoriteButton = (UIImageView *)[self.containerView viewWithTag:2002];
		shareButton.hidden = YES;
		favoriteButton.hidden = YES;
		
		//显示字数统计
		UILabel *remainCountLabel = (UILabel *)[self.containerView viewWithTag:2004];
		remainCountLabel.hidden = NO;
		
		//显示发送按钮
		sendBtn.hidden = NO;
        
	}
	else
	{
		//显示分享 收藏按钮 
		UIImageView *shareButton = (UIImageView *)[self.containerView viewWithTag:2001];
		UIImageView *favoriteButton = (UIImageView *)[self.containerView viewWithTag:2002];
		shareButton.hidden = NO;
		favoriteButton.hidden = NO;
		
		//隐藏字数统计
		UILabel *remainCountLabel = (UILabel *)[self.containerView viewWithTag:2004];
		remainCountLabel.hidden = YES;
		
		//隐藏发送按钮
		UIButton *sendBtn = (UIButton *)[self.containerView viewWithTag:2003];
		sendBtn.hidden = YES;
		
		//缩小输入框
		UIImageView *entryImageView = (UIImageView *)[self.containerView viewWithTag:2000];
		CGRect entryFrame = entryImageView.frame;
		entryFrame.size.width -= 20.0f;
		
		CGRect textFrame = self.textView.frame;
		textFrame.size.width -= 20.0f;
		
		entryImageView.frame = entryFrame;
		self.textView.frame = textFrame; 
        
	}
    
}

//发表评论
-(void)publishComment:(id)sender
{
	NSString *content = self.textView.text;
	
	//把回车 转化成 空格
	content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
	content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	if ([content length] > 0) 
	{
		if ([content length] > 140)
		{
			[alertView showAlert:@"评论内容不能超过140个字符"];
		}
		else
		{
			MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
			self.progressHUD = progressHUDTmp;
			[progressHUDTmp release];
			self.progressHUD.delegate = self;
			self.progressHUD.labelText = @"发送中... ";
			[self.view addSubview:self.progressHUD];
			[self.view bringSubviewToFront:self.progressHUD];
			[self.progressHUD show:YES];
			
			NSString *reqUrl = @"comment/pro.do?param=%@";
			
			NSArray *supplyInfo = [supplyArray objectAtIndex:0];
			
			NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
										 [Common getSecureString],@"keyvalue",
										 [NSNumber numberWithInt: SITE_ID],@"site_id",
										 self.userId,@"user_id",
										 [NSNumber numberWithInt: 1],@"type",
										 [supplyInfo objectAtIndex:supply_id],@"info_id",
										 [supplyInfo objectAtIndex:supply_title],@"title",
										 content,@"content",
										 nil];
			
			[[DataManager sharedManager] accessService:jsontestDic 
											   command:OPERAT_SEND_SUPPLY_COMMENT 
										  accessAdress:reqUrl 
											  delegate:self 
											 withParam:nil];
			
			[self.textView resignFirstResponder];
            
		}
	}
	else 
	{
		//[alertView showAlert:@"请输入留言内容"];
		[self.textView resignFirstResponder];
	}
}



//分享
-(void)share
{
// dufu mod 2013.04.25
//	NSArray *actionSheetMenu = [NSArray arrayWithObjects:
//                                @"分享到微信朋友圈",
//                                @"分享到微信好友",
//                                @"分享到新浪微博",
//                                @"分享到腾讯微博",
//                                @"分享到手机用户",nil];
//	manageActionSheet *tempActionsheet = [[manageActionSheet alloc]initActionSheetWithStrings:actionSheetMenu];
//	tempActionsheet.manageDeleage = self;
//	self.actionSheet = tempActionsheet;
//	[tempActionsheet release];
//	[tempActionsheet showActionSheet:self.view];
	
    // dufu  add 2013.04.25
    // 分享创建实例
    if (ShareSheet == nil) {
        ShareSheet = [[ShareAction alloc]init];
    }
    
    ShareSheet.shareDelegate = self;
    
    // 分享显示弹窗
    [ShareSheet shareActionShow:self.view navController:self.navigationController];
}

// 分享委托
#pragma mark - Share Delegate
- (NSDictionary *)shareSheetRetureValue  // dufu add 2013.04.25
{
    NSString *str = @"product/view/";
	NSString *link = [NSString stringWithFormat:@"%@%@%d",DETAIL_SHARE_LINK,str,[supplyID intValue]];
	NSString *content = [[self.supplyArray objectAtIndex:0] objectAtIndex:supply_title];
	NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
    
    // 分享的内容信息字典
    NSDictionary *dict;
    
    if ([self.supplyPicArray count] > 0) {
        NSArray *supplyPic = [self.supplyPicArray objectAtIndex:0];
        NSString *photoUrl = [supplyPic objectAtIndex:supply_pic_pic];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (photoUrl.length > 1) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [FileManager getPhoto:picName],ShareImage,
                    [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                    content,ShareContent,
                    link,ShareUrl,  nil];
        } else {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                    content,ShareContent,
                    link,ShareUrl,  nil];
        }
    } else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl,  nil];
    }

    return dict;
}

//收藏
-(void)favorite
{
	if (!isFavorite) 
	{
		//判断用户是否登陆
		if (_isLogin == YES) 
		{
			if ([self.userId intValue] != 0)
			{
				MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
				self.progressHUD = progressHUDTmp;
				[progressHUDTmp release];
				self.progressHUD.delegate = self;
				self.progressHUD.labelText = @"发送中... ";
				[self.view addSubview:self.progressHUD];
				[self.view bringSubviewToFront:self.progressHUD];
				[self.progressHUD show:YES];
				
				NSString *reqUrl = @"member/favorites.do?param=%@";
				
				NSArray *supplyInfo = [supplyArray objectAtIndex:0];
				
				NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
											 [Common getSecureString],@"keyvalue",
											 [NSNumber numberWithInt: SITE_ID],@"site_id",
											 self.userId,@"user_id",
											 [supplyInfo objectAtIndex:supply_id],@"info_id",
											 [NSNumber numberWithInt: 2],@"info_type",
											 [supplyInfo objectAtIndex:supply_title],@"title",
											 nil];
				
				[[DataManager sharedManager] accessService:jsontestDic 
												   command:OPERAT_SEND_SUPPLY_FAVORITE
											  accessAdress:reqUrl 
												  delegate:self 
												 withParam:nil];
			}
			else
			{
				LoginViewController *login = [[LoginViewController alloc] init];
                login.delegate = self;
                operateType = 2;
				[self.navigationController pushViewController:login animated:YES];
				[login release];
			}
			
		}
		else 
		{
			LoginViewController *login = [[LoginViewController alloc] init];
            login.delegate = self;
            operateType = 2;
			[self.navigationController pushViewController:login animated:YES];
			[login release];
		}
		
	}
}

//编辑中
-(void)doEditing
{
	UILabel *remainCountLabel = (UILabel *)[self.containerView viewWithTag:2004];
	int textCount = [self.textView.text length];
	if (textCount > 140)
    {
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
	}
    else
    {
		remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	}
	
	remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - [self.textView.text length]];
}

//关闭键盘
-(void)hiddenKeyboard
{
    //输入内容 存起来
	self.tempTextContent = self.textView.text;
    self.textView.text = @"说两句";
	self.textView.textColor = [UIColor grayColor]; 
	[self.textView resignFirstResponder];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

//评论成功
- (void)commentSuccess:(NSMutableArray *)resultArray
{	
	self.tempTextContent = @"";
    self.textView.text = @"说两句";
    self.textView.textColor = [UIColor grayColor]; 
	if (self.progressHUD) {
		[progressHUD hide:YES afterDelay:1.0f];
	}
    
    if (isFrom == YES) {
        NSString *num = [resultArray objectAtIndex:1];
        commentTotal = num;
        NSString *str = [NSString stringWithFormat:@"%@评论",commentTotal];
        [barbutton setTitle:str];
    }
}

//收藏成功
- (void)favoriteSuccess
{
	isFavorite = YES;
	UIImageView *favoriteButton = (UIImageView *)[self.containerView viewWithTag:2002];
	favoriteButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"已收藏按钮" ofType:@"png"]];
	if (self.progressHUD) {
		[progressHUD hide:YES afterDelay:1.0f];
	}
    
    UILabel *favoriteInfoLabel = (UILabel *)[self.scrollView viewWithTag:1000];
    NSString *favoriteNum = favoriteInfoLabel.text;
    favoriteInfoLabel.text = [NSString stringWithFormat:@"%d",[favoriteNum intValue]+1];
}

//收藏失败
- (void)favoriteFail
{	
	if (self.progressHUD) {
		progressHUD.labelText = @"收藏失败";
        progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
        progressHUD.mode = MBProgressHUDModeCustomView;
        [progressHUD hide:YES afterDelay:1.0f];
	}
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	
	NSMutableArray* array = (NSMutableArray*)resultArray;
	int isSuccess = [[array objectAtIndex:0] intValue];
	
	if (commandid == OPERAT_SEND_SUPPLY_COMMENT) 
	{
		if (isSuccess == 1 ) {
			if (self.progressHUD) {
				self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
				self.progressHUD.mode = MBProgressHUDModeCustomView;
				self.progressHUD.labelText = @"评论成功";
			}
		}else if(isSuccess == 0 ){
			if (self.progressHUD) {
				self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
				//self.progressHUD.mode = MBProgressHUDModeDeterminate;
				self.progressHUD.mode = MBProgressHUDModeCustomView;
				self.progressHUD.labelText = @"发送失败";
			}
		}
		
		[self performSelectorOnMainThread:@selector(commentSuccess:) withObject:resultArray waitUntilDone:NO];
	}
	else if(commandid == OPERAT_SEND_SUPPLY_FAVORITE)
	{
		if (isSuccess == 1 ) {
			if (self.progressHUD) {
				self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
				self.progressHUD.mode = MBProgressHUDModeCustomView;
				self.progressHUD.labelText = @"收藏成功";
				
				if ([self.userId intValue] != 0) 
				{
					//收藏信息入库
					NSArray *supplyInfo = [self.supplyArray objectAtIndex:0];
					NSMutableArray *infoArray = [[NSMutableArray alloc]init];
					
					[infoArray addObject:@"0"];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_id]];
					[infoArray addObject:self.userId];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_catid]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_title]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_desc]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_price]];
                    [infoArray addObject:[supplyInfo objectAtIndex:supply_company_id]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_company_name]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_tel]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_pic]];
					[infoArray addObject:@""];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_favorite]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_created]];
					[infoArray addObject:[supplyInfo objectAtIndex:supply_update_time]];
                    [infoArray addObject:[supplyInfo objectAtIndex:supply_recommend]];
                    [infoArray addObject:@""];
                    
					//插入数据库
					[DBOperate insertData:infoArray tableName:T_SUPPLY_FAVORITE];
					[infoArray release];
                    
					//添加对应的图片
					if ([self.supplyPicArray count] > 0) 
					{
						for (NSArray *picInfo in self.supplyPicArray) 
						{
							NSMutableArray *pic = [[NSMutableArray alloc] init];
							[pic addObject:[supplyInfo objectAtIndex:supply_id]];
							[pic addObject:self.userId];
							[pic addObject:[picInfo objectAtIndex:supply_pic_pic]];
							[pic addObject:@""];
							[pic addObject:[picInfo objectAtIndex:supply_pic_thumb_pic]];
							[pic addObject:@""];
							[DBOperate insertData:pic tableName:T_SUPPLY_PIC_FAVORITE];
							[pic release];
						}
					}
				}
				
				[self performSelectorOnMainThread:@selector(favoriteSuccess) withObject:nil waitUntilDone:NO];
			}
		}else if(isSuccess == 0 ){
			if (self.progressHUD) {
				self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
				//self.progressHUD.mode = MBProgressHUDModeDeterminate;
				self.progressHUD.mode = MBProgressHUDModeCustomView;
				self.progressHUD.labelText = @"收藏失败";
				[self performSelectorOnMainThread:@selector(favoriteFail) withObject:nil waitUntilDone:NO];
			}
		}else if(isSuccess == 2 ){
			if (self.progressHUD) {
				self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
				//self.progressHUD.mode = MBProgressHUDModeDeterminate;
				self.progressHUD.mode = MBProgressHUDModeCustomView;
				self.progressHUD.labelText = @"该信息已收藏";
				[self performSelectorOnMainThread:@selector(favoriteFail) withObject:nil waitUntilDone:NO];
			}
		}
		
	}
}

#pragma mark -
#pragma mark progressHUD委托
//在该函数 [progressHUD hide:YES afterDelay:1.0f] 执行后回调

- (void)hudWasHidden:(MBProgressHUD *)hud{
	
	if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
		self.progressHUD = nil;
	}
	
}

#pragma mark -
#pragma mark 图片滚动委托

- (void)imageViewTouchesEnd:(int)picId
{	
	picDetailViewController *picDetail = [[picDetailViewController alloc] init];			
	picDetail.picArray = self.supplyPicArray;
	picDetail.chooseIndex = picId;
	[self.navigationController pushViewController:picDetail animated:YES];
	[picDetail release];
}

- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.showPicScrollView.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, 0.0f);
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{	
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView{
    if (aScrollView.tag == 100) {
		CGPoint offset = aScrollView.contentOffset;
		self.pageControll.currentPage = offset.x / self.view.frame.size.width;
	}
}

#pragma mark -
#pragma mark 键盘通知调用
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
	
	//新增一个遮罩按钮
	UIButton *backGrougBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	backGrougBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (keyboardBounds.size.height + containerFrame.size.height));
	backGrougBtn.tag = 2005;
	[backGrougBtn addTarget:self action:@selector(hiddenKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backGrougBtn];
	
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
	
	//更改按钮状态
	[self buttonChange:YES];
	
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
    
	//移出遮罩按钮
	UIButton *backGrougBtn = (UIButton *)[self.view viewWithTag:2005];
	[backGrougBtn removeFromSuperview];
	
	//更改按钮状态
	[self buttonChange:NO];
}

#pragma mark -
#pragma mark HPGrowingTextView 委托
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
	//判断用户是否登陆
	if (_isLogin == YES) 
	{
		if ([self.userId intValue] != 0)
		{
			return YES;
		}
		else
		{
			LoginViewController *login = [[LoginViewController alloc] init];
            login.delegate = self;
            operateType = 1;
			[self.navigationController pushViewController:login animated:YES];
			[login release];
			return NO;
		}
        
	}
	else 
	{
		LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        operateType = 1;
		[self.navigationController pushViewController:login animated:YES];
		[login release];
		return NO;
	}
    
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
	if([growingTextView.text isEqualToString:@"说两句"])
	{
        //内容设置回来
		growingTextView.text = self.tempTextContent;
	}
	growingTextView.textColor = [UIColor blackColor];
	
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
	return YES;
}

// dufu mod 2013.04.25
//#pragma mark -
//#pragma mark actionsheet委托
//
//- (void) actionSheetAppear:(int)actionID actionSheet:(UIActionSheet *)actionSheet{
//	
//}
//
//- (void)getChoosedIndex:(int)actionID chooseIndex:(int)index
//{
//    NSString *str = @"product/view/";
//	NSString *link = [NSString stringWithFormat:@"%@%@%d",DETAIL_SHARE_LINK,str,[supplyID intValue]];
//	NSString *content = [[self.supplyArray objectAtIndex:0] objectAtIndex:supply_title];
//	NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
//	
//	switch (index) {
//		case 0:
//		{
//			[callSystemApp sendMessageTo:@"" inUIViewController:self withContent:content];
//			break;
//		}
//		case 1:
//		{	
//			//收件人，cc：抄送  subject：主题   body：内容
//			[callSystemApp sendEmail:@"" cc:@"" subject:content body:allContent];
//			break;
//		}
//		case 2:
//		{
//			//这里是新浪微博分享
//			NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" 
//										theColumnValue:SINA withAll:NO];
//			if (weiboArray != nil && [weiboArray count] > 0)
//			{
//				ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
//				share.weiBoType = 0;
//				
//				if ([self.supplyPicArray count] > 0) 
//				{
//					NSArray *supplyPic = [self.supplyPicArray objectAtIndex:0];
//					
//					NSString *photoUrl = [supplyPic objectAtIndex:supply_pic_pic];
//					
//					NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
//					
//					if (photoUrl.length > 1) 
//					{
//						UIImage *photo = [FileManager getPhoto:picName];
//						share.shareImage = photo;
//						share.checkBoxSelected = YES;
//					}
//					else 
//					{
//						share.shareImage = nil;
//						share.checkBoxSelected = NO;
//					}
//				}
//				else 
//				{
//					share.shareImage = nil;
//					share.checkBoxSelected = NO;
//				}
//                
//				//NSArray *supplyInfo = [self.supplyArray objectAtIndex:0];
//				share.defaultContent = [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS];
//				[self.navigationController pushViewController:share animated:YES];
//				[share release];
//			}
//			else 
//			{
//				SinaViewController *sc = [[SinaViewController alloc] init];
//				sc.delegate = self;
//				[self.navigationController pushViewController:sc animated:YES];
//				[sc release];
//			}
//			break;
//		}
//		case 3:
//		{
//			//这里做腾讯微博分享
//			NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" 
//										theColumnValue:TENCENT withAll:NO];
//			if (weiboArray != nil && [weiboArray count] > 0) 
//			{
//				ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
//				share.weiBoType = 1;
//				
//				if ([self.supplyPicArray count] > 0) 
//				{
//					NSArray *supplyPic = [self.supplyPicArray objectAtIndex:0];
//					
//					NSString *photoUrl = [supplyPic objectAtIndex:supply_pic_pic];
//					
//					NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
//					
//					if (photoUrl.length > 1) 
//					{
//						UIImage *photo = [FileManager getPhoto:picName];
//						share.shareImage = photo;
//						share.checkBoxSelected = YES;
//					}
//					else 
//					{
//						share.shareImage = nil;
//						share.checkBoxSelected = NO;
//					}
//				}
//				else 
//				{
//					share.shareImage = nil;
//					share.checkBoxSelected = NO;
//				}
//				
//				//NSArray *supplyInfo = [self.supplyArray objectAtIndex:0];
//				share.defaultContent = [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS];
//				[self.navigationController pushViewController:share animated:YES];
//				[share release];
//			}
//			else
//			{
//				TencentViewController *tc = [[TencentViewController alloc] init];
//				tc.delegate = self;
//				[self.navigationController pushViewController:tc animated:YES];
//				[tc release];
//			}
//			break;
//			
//		}
//		default:
//			break;
//	}
//}

#pragma mark -
#pragma mark 登录接口回调
- (void)loginWithResult:(BOOL)isLoginSuccess{
    
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
        
		if (operateType == 1) 
        {
            //评论操作，调用评论接口
			[self.textView becomeFirstResponder];
		}
        else if (operateType == 2) 
        {
            //收藏操作
			[self favorite];
		}
	}
    //    else
    //    {
    //		[alertView showAlert:@"登录失败，请重试！"];
    //	}
    
}

// dufu mod 2013.04.25
//#pragma mark -
//#pragma mark OauthSinaSeccessDelagate
//- (void) oauthSinaSuccess{
//	[self getChoosedIndex:0 chooseIndex:2];
//}
//
//#pragma mark OauthTencentSeccessDelagate
//- (void) oauthTencentSuccess{
//	[self getChoosedIndex:0 chooseIndex:3];
//}

#pragma mark -
#pragma mark 程序注销

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.supplyID = nil;
	self.supplyArray = nil;
	self.supplyPicArray = nil;
	self.scrollView.delegate = nil;
	self.scrollView = nil;
	self.showPicScrollView.delegate = nil;
	self.showPicScrollView = nil;
	self.pageControll = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.containerView = nil;
	self.textView.delegate = nil;
	self.textView = nil;
	self.tempTextContent = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
//	self.actionSheet.manageDeleage = nil;
//	self.actionSheet = nil;
	self.userId = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.supplyID = nil;
	self.supplyArray = nil;
	self.supplyPicArray = nil;
	self.scrollView.delegate = nil;
	self.scrollView = nil;
	self.showPicScrollView.delegate = nil;
	self.showPicScrollView = nil;
	self.pageControll = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
	self.containerView = nil;
	self.textView.delegate = nil;
	self.textView = nil;
	self.tempTextContent = nil;
	self.progressHUD.delegate = nil;
	self.progressHUD = nil;
//	self.actionSheet.manageDeleage = nil;
//	self.actionSheet = nil;
	self.userId = nil;
    [barbutton release];
    [ShareSheet release];
    
    [super dealloc];
}

- (void)commentListAction
{
    CommentViewController *comment = [[CommentViewController alloc] init];
    comment._type = [NSString stringWithFormat:@"%d",1];
    comment._infoId = [NSString stringWithFormat:@"%d",[[[self.supplyArray objectAtIndex:0] objectAtIndex:supply_id] intValue]];
    comment.infoTitle = [[self.supplyArray objectAtIndex:0] objectAtIndex:supply_title];
    comment.button = barbutton;
    comment.isFromSuper = isFrom;
    [self.navigationController pushViewController:comment animated:YES];
}
@end
