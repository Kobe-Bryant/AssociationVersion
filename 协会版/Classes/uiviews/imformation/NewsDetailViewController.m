//
//  NewsDetailViewController.m
//  Profession
//
//  Created by MC374 on 12-8-21.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "HPGrowingTextView.h"
#import "MBProgressHUD.h"
#import "alertView.h"
//#import "manageActionSheet.h"
#import "IconDownLoader.h"
#import "FileManager.h"
#import "callSystemApp.h"
#import "downloadParam.h"
#import "DBOperate.h"
#import "Common.h"
#import "DataManager.h"
//#import "ShareToBlogViewController.h"  // dufu mod 2013.04.25
#import "weiboSetViewController.h"
#import "LoginViewController.h"
#import "CommentViewController.h"
#import "UIImageScale.h"

@implementation NewsDetailViewController
@synthesize isFavorite;
//@synthesize actionSheet;  // dufu mod 2013.04.25
@synthesize iconDownLoad;
@synthesize detailArray;
@synthesize totalheight;
@synthesize userId;
@synthesize operateType;
@synthesize textView;
@synthesize tempTextContent;
@synthesize commentTotal;
@synthesize isFrom;
@synthesize barbutton;

@synthesize ShareSheet; // dufu add 2013.04.25

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"详细新闻";
    
    self.tempTextContent = @"";
	
	//self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    CGFloat fixHeight = [UIScreen mainScreen].bounds.size.height - 40.0f - 44.0f - 20.0f;
	
	contentScrollView = [[UIScrollView alloc] initWithFrame:
						 CGRectMake(0, 0, 320, fixHeight)];
	contentScrollView.pagingEnabled = NO;
	contentScrollView.delegate = self;
	contentScrollView.showsHorizontalScrollIndicator = NO;
	contentScrollView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:contentScrollView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	[titleLabel setLineBreakMode:UILineBreakModeWordWrap];
	titleLabel.font = [UIFont systemFontOfSize:20];
	[titleLabel setNumberOfLines:0];
	titleLabel.textAlignment = UITextAlignmentCenter;
	NSString *titletext = [detailArray objectAtIndex:recommend_news_title];
	CGSize titleconstraint = CGSizeMake(300, 20000.0f);
	CGSize titlesize = [titletext sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:titleconstraint lineBreakMode:UILineBreakModeWordWrap];
	[titleLabel setText:titletext];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.frame = CGRectMake(10, 10, 300, MAX(titlesize.height, 40.0f));
	[contentScrollView addSubview:titleLabel];
	[titleLabel release];
	
	totalheight = titleLabel.frame.size.height;
	
	UILabel *timelabel = [[UILabel alloc] 
						  initWithFrame:CGRectMake(70, totalheight + 14, 100, 20)];
	timelabel.textColor = [UIColor grayColor];
	timelabel.backgroundColor = [UIColor clearColor];
    
    int createTime = [[detailArray objectAtIndex:recommend_news_created] intValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    //[outputFormat setTimeZone:[NSTimeZone timeZoneWithName:@"H"]]; 
    [outputFormat setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [outputFormat stringFromDate:date];
    timelabel.text = dateString;
    [outputFormat release];
    
	timelabel.font = [UIFont systemFontOfSize:14];
	[contentScrollView addSubview:timelabel];
	[timelabel release];
	
	UILabel *fromlabel = [[UILabel alloc] 
						  initWithFrame:CGRectMake(150, totalheight + 14, 160, 20)];
	fromlabel.textColor = [UIColor grayColor];
	fromlabel.backgroundColor = [UIColor clearColor];
	fromlabel.text = [NSString stringWithFormat:@"%@%@",@"来源:",[detailArray objectAtIndex:recommend_news_companyname]];//@"来源：新车评网";
	fromlabel.font = [UIFont systemFontOfSize:14];
	[contentScrollView addSubview:fromlabel];
	[fromlabel release];
	
	totalheight += 14+20;
	
	UIImageView *seplineview = [[UIImageView alloc] 
								initWithFrame:CGRectMake(0,totalheight+13, 320, 2)];
	UIImage *sepimg = [[UIImage alloc]initWithContentsOfFile:
					   [[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
	seplineview.image = sepimg;
	[sepimg release];
	[contentScrollView addSubview:seplineview];
	[seplineview release];
	
	totalheight += 15;
	
	newsImageView = [[UIImageView alloc] 
                     initWithFrame:CGRectMake(20,totalheight+15, 280,205)];
	UIImage *newsimage = [[UIImage alloc]initWithContentsOfFile:
						  [[NSBundle mainBundle] pathForResource:@"资讯详情默认" ofType:@"png"]];
	[newsImageView setImage:newsimage];
	[newsimage release];
	[contentScrollView addSubview:newsImageView];
    
    //	NSString *piclink = @"http://demo1.3g.yunlai.cn/userfiles/000/000/101/ad_img/1121066111.jpg";
    //	NSString *piclink = @"http://demo1.cn.yunlai.cn/userfiles/000/000/101/product/20120625/t_1716495314.jpg";
    //	NSString *piclink = @"http://demo1.cn.yunlai.cn/userfiles/000/000/101/product/20120625/1717489054.jpg";
	NSString *photoname = [detailArray objectAtIndex:newslist_opic_name];
	NSString *piclink = [detailArray objectAtIndex:newslist_opic];
	UIImage *img = [FileManager getPhoto:photoname];
    
	if (img != nil) 
    {
		newsImageView.image = [img fillSize:CGSizeMake(280,205)];
	}
    else 
    {
		if (piclink.length > 0)
        {
			[self startIconDownload:piclink forIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
		}
	}
	
	totalheight += 220; // 15 + 205
	
	descLable = [[UILabel alloc] initWithFrame:CGRectZero];
	descLable.backgroundColor = [UIColor clearColor];
	[descLable setLineBreakMode:UILineBreakModeWordWrap];
	[descLable setNumberOfLines:0];
	descLable.font = [UIFont systemFontOfSize:14];
	NSString *descText = [NSString stringWithFormat:@"%@%@",@"    ",[detailArray objectAtIndex:recommend_news_desc]];
	CGSize constraint = CGSizeMake(280, 20000.0f);
	CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	[descLable setText:descText];
	descLable.textColor = [UIColor blackColor];
	[descLable setFrame:CGRectMake(20, totalheight + 15, 280, MAX(size.height, 44.0f))];	
	[contentScrollView addSubview:descLable];
	
	totalheight += 15 + descLable.frame.size.height;
    
	contentScrollView.contentSize = CGSizeMake(320,totalheight);
	
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
	NSLog(@"newslist_nid:%d",[[detailArray objectAtIndex:newslist_nid] intValue]);
	NSMutableArray *favorite = (NSMutableArray *)[DBOperate 
												  queryData:T_FAVORITE_NEWS theColumn:@"nid" 
												  equalValue:[NSString stringWithFormat:@"%d",[[detailArray objectAtIndex:newslist_nid] intValue]] 
												  theColumn:@"user_id" equalValue:userId];
	
	if (favorite == nil || ![favorite count] > 0) 
	{
		//没有收藏
		isFavorite = NO;
	}
	else 
	{
		//已收藏
		isFavorite = YES;
	}
	
	//添加底部工具栏
	[self addButtomBar];
    
    NSString *str = [NSString stringWithFormat:@"%@评论",commentTotal];
    barbutton = [[UIBarButtonItem alloc] 
                 initWithTitle:str 
                 style:UIBarButtonItemStyleBordered 
                 target:self action:@selector(commentListAction)]; 
    self.navigationItem.rightBarButtonItem = barbutton;  
    
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
	NSLog(@"newslist_nid:%d",[[detailArray objectAtIndex:newslist_nid] intValue]);
	NSMutableArray *favorite = (NSMutableArray *)[DBOperate 
												  queryData:T_FAVORITE_NEWS theColumn:@"nid" 
												  equalValue:[NSString stringWithFormat:@"%d",[[detailArray objectAtIndex:newslist_nid] intValue]] 
												  theColumn:@"user_id" equalValue:userId];
	
	if (favorite == nil || ![favorite count] > 0) 
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
	contentScrollView = nil;
	containerView = nil;
	textView = nil;
	//self.actionSheet = nil;
	self.iconDownLoad = nil;
	newsImageView = nil;
	self.detailArray = nil;
	self.userId = nil;
    self.textView = nil;
    self.tempTextContent = nil;
//    self.ShareSheet = nil;  // dufu add 2013.04.25
//    self.ShareSheet.shareDelegate = nil;  // dufu add 2013.04.25
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[contentScrollView release];
	contentScrollView = nil;
	[containerView release];
	containerView = nil;
	[textView release];
	textView = nil;
	//[actionSheet release];
	//actionSheet = nil;
	[iconDownLoad release];
	iconDownLoad = nil;
	[newsImageView release];
	newsImageView = nil;
	[detailArray release],detailArray = nil;
	[userId release],userId = nil;
    self.textView = nil;
    self.tempTextContent = nil;
    [barbutton release];

    [ShareSheet release];  // dufu add 2013.04.25
    [super dealloc];
}

- (void) addButtomBar{
	containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentScrollView.frame), 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 235, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	textView.returnKeyType = UIReturnKeyDefault; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor grayColor]; 
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = @"说两句";
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
	
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[[UIImageView alloc] initWithImage:entryBackground] autorelease];
    entryImageView.frame = CGRectMake(5, 0, 240, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    entryImageView.tag = 2000;
	
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:background] autorelease];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
	
    //收藏按钮
	UIImageView *favoriteButton = [[UIImageView alloc]initWithFrame:CGRectMake(275.0f, 0.0f, 40.0f, 40.0f)];
	
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
	
	[containerView addSubview:favoriteButton];
	[favoriteButton release];
	
	//分享按钮
	UIImageView *shareButton = [[UIImageView alloc]initWithFrame:CGRectMake(240.0f, 0.0f, 40.0f, 40.0f)];
	shareButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"分享按钮" ofType:@"png"]];
	shareButton.tag = 2001;
	
	//绑定点击事件
	shareButton.userInteractionEnabled = YES;
	UITapGestureRecognizer *shareSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share)];
	[shareButton addGestureRecognizer:shareSingleTap];
	[shareSingleTap release];
	
	[containerView addSubview:shareButton];
	[shareButton release];
	
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
	[containerView addSubview:remainCountLabel];
	[remainCountLabel release];
	
	//添加发送按钮
	UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
	UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
	
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(containerView.frame.size.width - 55, 8, 50, 27);
	sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendBtn setTitle:@"发送" forState:UIControlStateNormal];
	[sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
	sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
	sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	sendBtn.tag = 2003;
	sendBtn.hidden = YES;
	[sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendBtn addTarget:self action:@selector(publishComment) forControlEvents:UIControlEventTouchUpInside];
	[sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
	[sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:sendBtn];
	
	[self.view addSubview:containerView];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    if (commandid == ACCESS_COMMENT_NEWS_COMMAND_ID) {
        [self performSelectorOnMainThread:@selector(commentResult:) withObject:resultArray waitUntilDone:NO];
    }else if(commandid == ACCESS_FAVORITE_NEWS_COMMAND_ID){
        [self performSelectorOnMainThread:@selector(favoriteResult:) withObject:resultArray waitUntilDone:NO];
    }
}

- (void)commentResult:(NSMutableArray *)resultArray
{
    int isSuccess = [[resultArray objectAtIndex:0] intValue];
    if (isSuccess == 1 ) {
        if (progressHUDTmp) {
            progressHUDTmp.labelText = @"评论成功";
            progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
            progressHUDTmp.mode = MBProgressHUDModeCustomView;
            [progressHUDTmp hide:YES afterDelay:1.0];
        }
        
        //输入内容 存起来
        self.tempTextContent = @"";
        self.textView.text = @"说两句";
        self.textView.textColor = [UIColor grayColor]; 
        
        if (isFrom == YES) {
            NSString *num = [resultArray objectAtIndex:1];
            commentTotal = num;
            NSString *str = [NSString stringWithFormat:@"%@评论",commentTotal];
            [barbutton setTitle:str];
        }
        
    }else if(isSuccess == 0 ){
        if (progressHUDTmp) {
            progressHUDTmp.labelText = @"发送失败";
            progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
            progressHUDTmp.mode = MBProgressHUDModeCustomView;
            [progressHUDTmp hide:YES afterDelay:1.0];
        }
    }
    
}

- (void)favoriteResult:(NSMutableArray *)resultArray
{
    int isSuccess = [[resultArray objectAtIndex:0] intValue];
    if (isSuccess == 1 ) {
        NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
        if ([memberArray count] > 0) 
        {
            self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
        }
        else 
        {
            self.userId = @"0";
        }
        
        progressHUDTmp.labelText = @"收藏成功";
        progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
        progressHUDTmp.mode = MBProgressHUDModeCustomView;
        [progressHUDTmp hide:YES afterDelay:1.0];
        
        //将收藏新闻写入新闻收藏表
        NSMutableArray *infoList = [[NSMutableArray alloc] init];	
        [infoList addObject:@""];
        [infoList addObject:[detailArray objectAtIndex:newslist_nid]];
        [infoList addObject:userId];		
        [infoList addObject:[detailArray objectAtIndex:newslist_catid]];
        [infoList addObject:[detailArray objectAtIndex:newslist_title]];
        [infoList addObject:[detailArray objectAtIndex:newslist_desc]];
        [infoList addObject:[detailArray objectAtIndex:newslist_companyname]];
        [infoList addObject:[detailArray objectAtIndex:newslist_opic]];
        [infoList addObject:[detailArray objectAtIndex:newslist_spic]];
        [infoList addObject:@""];
        [infoList addObject:[detailArray objectAtIndex:newslist_created]];
        [infoList addObject:[detailArray objectAtIndex:newslist_updatetime]];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [DBOperate insertData:infoList tableName:T_FAVORITE_NEWS];
        [infoList release];
        
        isFavorite = YES;
        UIImageView *favoriteButton = (UIImageView *)[containerView viewWithTag:2002];
        favoriteButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"已收藏按钮" ofType:@"png"]];
    }else {
        progressHUDTmp.labelText = @"收藏失败";
        progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
        progressHUDTmp.mode = MBProgressHUDModeCustomView;
        [progressHUDTmp hide:YES afterDelay:1.0];
    }
    
}

#pragma mark 收藏操作
-(void)favorite
{
	NSLog(@"ffff");
	if (!isFavorite) 
	{
		//判断用户是否登陆
		if (_isLogin) 
		{
			if (progressHUDTmp == nil) {
				progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
				progressHUDTmp.delegate = self;
				progressHUDTmp.labelText = @"发送中... ";
				[self.view addSubview:progressHUDTmp];
				[self.view bringSubviewToFront:progressHUDTmp];
			}
			[progressHUDTmp show:YES];
			
			
			NSString *reqUrl = @"member/favorites.do?param=%@";
			
			NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
										 [Common getSecureString],@"keyvalue",
										 [NSNumber numberWithInt: SITE_ID],@"site_id",
										 userId,@"user_id",
										 [detailArray objectAtIndex:newslist_nid],@"info_id",
										 [NSNumber numberWithInt: 3],@"info_type",
										 [detailArray objectAtIndex:newslist_title],@"title",
										 nil];
			
			[[DataManager sharedManager] accessService:jsontestDic 
											   command:ACCESS_FAVORITE_NEWS_COMMAND_ID
										  accessAdress:reqUrl 
											  delegate:self 
											 withParam:nil];			
		}
		else 
		{
			LoginViewController *login = [[LoginViewController alloc] init];
			login.delegate = self;
			self.operateType = 2;
			[self.navigationController pushViewController:login animated:YES];
			[login release];
		}
		
	}	
}

#pragma mark 改变键盘按钮
-(void)buttonChange:(BOOL)isKeyboardShow
{
	//判断软键盘显示
	if (isKeyboardShow) 
	{
        UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
        
        //增长输入框
        if (sendBtn.hidden) 
        {
            UIImageView *entryImageView = (UIImageView *)[containerView viewWithTag:2000];
            CGRect entryFrame = entryImageView.frame;
            entryFrame.size.width += 20.0f;
            
            CGRect textFrame = self.textView.frame;
            textFrame.size.width += 20.0f;
            
            entryImageView.frame = entryFrame;
            self.textView.frame = textFrame;
        }
        
		//隐藏分享 收藏按钮 
		UIImageView *shareButton = (UIImageView *)[containerView viewWithTag:2001];
		UIImageView *favoriteButton = (UIImageView *)[containerView viewWithTag:2002];
		shareButton.hidden = YES;
		favoriteButton.hidden = YES;
		
		//显示字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = NO;
		
		//显示发送按钮
		sendBtn.hidden = NO;
        
	}
	else
	{
		//显示分享 收藏按钮 
		UIImageView *shareButton = (UIImageView *)[containerView viewWithTag:2001];
		UIImageView *favoriteButton = (UIImageView *)[containerView viewWithTag:2002];
		shareButton.hidden = NO;
		favoriteButton.hidden = NO;
		
		//隐藏字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = YES;
		
		//隐藏发送按钮
		UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
		sendBtn.hidden = YES;
		
		//缩小输入框
		UIImageView *entryImageView = (UIImageView *)[containerView viewWithTag:2000];
		CGRect entryFrame = entryImageView.frame;
		entryFrame.size.width -= 20.0f;
		
		CGRect textFrame = self.textView.frame;
		textFrame.size.width -= 20.0f;
		
		entryImageView.frame = entryFrame;
		self.textView.frame = textFrame; 
        
	}
    
}

#pragma mark 发表评论
-(void)publishComment
{
    NSString *content = textView.text;
    
    //把回车 转化成 空格
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    if ([content length] > 0) 
    {
        if ([content length] > 140)
        {
            [alertView showAlert:@"回复内容不能超过140个字符"];
        }
        else
        {
            progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
            progressHUDTmp.delegate = self;
            progressHUDTmp.labelText = @"发送中... ";
            [self.view addSubview:progressHUDTmp];
            [self.view bringSubviewToFront:progressHUDTmp];
            [progressHUDTmp show:YES];
            
            NSString *reqUrl = @"comment/pro.do?param=%@";					
            NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [Common getSecureString],@"keyvalue",
                                         [NSNumber numberWithInt: SITE_ID],@"site_id",
                                         userId,@"user_id",
                                         [NSNumber numberWithInt: 2],@"type",
                                         [detailArray objectAtIndex:newslist_nid],@"info_id",
                                         [detailArray objectAtIndex:newslist_title],@"title",
                                         content,@"content",
                                         nil];
            
            [[DataManager sharedManager] accessService:jsontestDic 
                                               command:ACCESS_COMMENT_NEWS_COMMAND_ID 
                                          accessAdress:reqUrl 
                                              delegate:self 
                                             withParam:nil];
            
            [textView resignFirstResponder];			
        }
    }
    else 
    {
        //[alertView showAlert:@"请输入留言内容"];
        [textView resignFirstResponder];
    }
	
}

//分享
-(void)share
{    
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
    NSString *str = @"news/view/";
	NSString *link = [NSString stringWithFormat:@"%@%@%d",DETAIL_SHARE_LINK,str,[[detailArray objectAtIndex:recommend_news_nid] intValue]];
	NSString *content = [detailArray objectAtIndex:recommend_news_title];
	NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
    // 分享信息字典
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          newsImageView.image,ShareImage,
                          [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                          content,ShareContent,
                          link,ShareUrl, nil];
    
    return dict;
}

//编辑中
-(void)doEditing
{
	UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
	int textCount = [textView.text length];
	if (textCount > 140) 
	{
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
	}
	else 
	{
		remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	}
	
	remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - [textView.text length]];
}

-(void)resignTextView
{
	[textView resignFirstResponder];
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

//关闭键盘
-(void)hiddenKeyboard
{
    //输入内容 存起来
	self.tempTextContent = self.textView.text;
    self.textView.text = @"说两句";
	self.textView.textColor = [UIColor grayColor];
	[textView resignFirstResponder];
}

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
			[textView becomeFirstResponder];
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

- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	
    if (iconDownLoad == nil && imageURL != nil && imageURL.length > 1) 
    {
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = imageURL;
        iconDownloader.indexPathInTableView = index;
		iconDownloader.imageType = CUSTOMER_PHOTO;
		self.iconDownLoad = iconDownloader;
		iconDownLoad.delegate = self;
        [iconDownLoad startDownload];
        [iconDownloader release];   
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
	NSString *photoname = [callSystemApp getCurrentTime];
	UIImage *photo = iconDownLoad.cardIcon;
	if ([FileManager savePhoto:photoname withImage:photo]) {
		[DBOperate updateData:T_NEWS_LIST tableColumn:@"opicname" columnValue:photoname conditionColumn:@"nid" conditionColumnValue:[NSString stringWithFormat:@"%d",[[detailArray objectAtIndex:newslist_nid] intValue]]];
	}
	newsImageView.frame = CGRectMake(20, newsImageView.frame.origin.y, 280, 205);
	descLable.frame = CGRectMake(20,CGRectGetMaxY(newsImageView.frame) + 10, 280, descLable.frame.size.height);
    UIImage *img = iconDownLoad.cardIcon;
	newsImageView.image = [img fillSize:CGSizeMake(280,205)];
}

- (void)commentListAction
{
    CommentViewController *comment = [[CommentViewController alloc] init];
    comment._type = [NSString stringWithFormat:@"%d",2];
    comment._infoId = [NSString stringWithFormat:@"%d",[[detailArray objectAtIndex:newslist_nid] intValue]];
    comment.infoTitle = [detailArray objectAtIndex:newslist_title];
    comment.button = barbutton;
    comment.isFromSuper = isFrom;
    [self.navigationController pushViewController:comment animated:YES];
}
@end
