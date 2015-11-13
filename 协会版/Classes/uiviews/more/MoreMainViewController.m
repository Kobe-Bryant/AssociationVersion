//
//  MoreMainViewController.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreMainViewController.h"
#import "aboutUsViewController.h"
#import "weiboSetViewController.h"
#import "feedbackViewController.h"
#import "recommendAppViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "Encry.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "UIImageScale.h"
#import "MoreButtonViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Login_feedbackViewController.h"
#import "alertView.h"
#import "ShareAction.h"

@implementation MoreMainViewController
@synthesize mainScrollView;
@synthesize introductionView;
@synthesize moreView;
@synthesize spinner;
@synthesize listArray = __listArray;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize iconDownLoad;
@synthesize ShareSheet;

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
	self.view.backgroundColor = [UIColor clearColor];
    
    iconWidth = 55.0f;
    iconHeight = 55.0f;

    __listArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
    
    UIScrollView *tempMainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height)];
	tempMainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	tempMainScrollView.pagingEnabled = NO;
	tempMainScrollView.showsHorizontalScrollIndicator = NO;
	tempMainScrollView.showsVerticalScrollIndicator = NO;
	tempMainScrollView.bounces = YES;
    self.mainScrollView = tempMainScrollView;
    [self.view addSubview:self.mainScrollView];
    [tempMainScrollView release];
    
    //介绍视图
    UIView *tempIntroductionView = [[UIView alloc] initWithFrame:CGRectZero];
    tempIntroductionView.backgroundColor = [UIColor clearColor];
    self.introductionView = tempIntroductionView;
    [self.mainScrollView addSubview:tempIntroductionView];
    [tempIntroductionView release];
    
    //更多功能视图
    UIView *tempMoreView = [[UIView alloc] initWithFrame:CGRectZero];
    tempMoreView.backgroundColor = [UIColor clearColor];
    self.moreView = tempMoreView;
    [self.mainScrollView addSubview:tempMoreView];
    [tempMoreView release];
    
    //添加loading图标
	UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	[tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, ([UIScreen mainScreen].bounds.size.height - 44.0f - 49.0f) / 2.0)];
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
    
    [self accessService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isLogin == YES) {
        NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
        int feedbackNum = [[[memberArray objectAtIndex:0] objectAtIndex:member_info_feedbackNum] intValue];
        if (feedbackNum == 0 && numView != nil) {
            [numView removeFromSuperview];
        }
    }
}

//创建介绍视图
-(void)createIntroductionView
{
    //顶部分割线
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f , 10.0f, 300.0f, 12.0f)];
    UIImage *lineImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多介绍" ofType:@"png"]];
    lineImageView.image = lineImage;
	[lineImage release];
	[self.introductionView addSubview:lineImageView];
	[lineImageView release];
    
    //添加第一个 '关于我们' 按钮
    UIImage *aboutImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"关于我们" ofType:@"png"]];
    
	aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
	aboutButton.frame = CGRectMake(10 , 37, iconWidth, iconHeight);
    aboutButton.layer.masksToBounds = YES;
    aboutButton.layer.cornerRadius = 8;
	[aboutButton addTarget:self action:@selector(aboutUs) forControlEvents:UIControlEventTouchUpInside];
	[aboutButton setBackgroundImage:aboutImage forState:UIControlStateNormal];
	[self.introductionView addSubview:aboutButton];
	[aboutImage release];
    
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(aboutButton.frame.origin.x, CGRectGetMaxY(aboutButton.frame) + 5 , aboutImage.size.width, 20)];
	aboutLabel.text = @"关于我们";	
	aboutLabel.textColor = [UIColor blackColor];
	aboutLabel.font = [UIFont systemFontOfSize:12.0f];
	aboutLabel.textAlignment = UITextAlignmentCenter;
	aboutLabel.backgroundColor = [UIColor clearColor];
	[self.introductionView addSubview:aboutLabel];
	[aboutLabel release];
    
    //中间icon间隔
    CGFloat midIconWidth = ((self.view.frame.size.width - (4*iconWidth) - 20.0f) / 3);
    
    int listCount = [self.listArray count];
    int residueNum = 0;   //余数
    int divisibleNum = 0;     //整除数
    if (listCount > 0)
    {
        for (int i = 0; i < listCount; i ++) 
        {
            NSArray *ay = [self.listArray objectAtIndex:i];
            residueNum = (i + 1) % 4;
            divisibleNum = (i + 1) / 4;
            CGFloat fixMarginWidth = (residueNum * midIconWidth) + (iconWidth * residueNum) + 10.0f;
            CGFloat fixMarginheight = divisibleNum * 90.0f + 37.0f;
            
            //int catId = [[ay objectAtIndex:morecat_catId] intValue];
            UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tempButton.frame = CGRectMake(fixMarginWidth , fixMarginheight , iconWidth , iconHeight);
            [tempButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            tempButton.tag = 10000 + i;
            tempButton.layer.masksToBounds = YES;
            tempButton.layer.cornerRadius = 8;
            [self.introductionView addSubview:tempButton];
            
            //NSString *imageUrl = @"http://demo1.3g.yunlai.cn/userfiles/000/000/101/recent_img/112610324.jpg";
            NSString *imageUrl = [ay objectAtIndex:morecat_catImageurl];
			NSString *photoname = [ay objectAtIndex:morecat_catImagename];
			UIImage *tempImage = [FileManager getPhoto:photoname];
			if (tempImage != nil) 
            {
				UIButton *currentButton = (UIButton *)[self.introductionView viewWithTag:10000 + i];
                [currentButton setBackgroundImage:tempImage forState:UIControlStateNormal];
			}
            else
            {
				if (imageUrl.length > 0) 
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:10000 + i inSection:0];
                    UIImage *imageIcon = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多默认icon" ofType:@"png"]];
                    UIButton *currentButton = (UIButton *)[self.introductionView viewWithTag:10000 + i];
                    [currentButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
                    
					[self startIconDownload:imageUrl forIndex:indexPath];
				}
			}
            
            UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(fixMarginWidth, CGRectGetMaxY(tempButton.frame) + 5 , tempButton.frame.size.width , 20)];
            tempLabel.text = [NSString stringWithFormat:@"%@",[ay objectAtIndex:morecat_catName]];	
            tempLabel.textColor = [UIColor blackColor];
            tempLabel.font = [UIFont systemFontOfSize:12.0f];
            tempLabel.textAlignment = UITextAlignmentCenter;
            tempLabel.backgroundColor = [UIColor clearColor];
            [self.introductionView addSubview:tempLabel];
            [tempLabel release];
        }
    }
    
    CGFloat floatListCount = [self.listArray count];
    CGFloat floatNum = ceil((floatListCount + 1.0) / 4.0);
    CGFloat introductionHeigh = floatNum * 90.0f + 37.0f;
    
    [self.introductionView setFrame:CGRectMake(0.0f , 0.0f, 320.0f, introductionHeigh)];
}

//创建更多功能视图
-(void)createMoreView
{
    //顶部分割线
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f , 0.0f , 300.0f, 12.0f)];
    UIImage *lineImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更多功能" ofType:@"png"]];
    lineImageView.image = lineImage;
	[lineImage release];
	[self.moreView addSubview:lineImageView];
	[lineImageView release];
    
    //中间icon间隔
    CGFloat midIconWidth = ((self.view.frame.size.width - (4*iconWidth) - 20.0f) / 3);
    
    //微博
    UIImage *weiboImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"微博设置" ofType:@"png"]];
    UIImageView *weiboView = [[UIImageView alloc] initWithImage:weiboImage];
    weiboView.frame = CGRectMake(lineImageView.frame.origin.x , CGRectGetMaxY(lineImageView.frame) + 10, iconWidth, iconHeight);
    [self.moreView addSubview:weiboView];
    
	UIButton *weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
	weiboButton.frame = CGRectMake(lineImageView.frame.origin.x , CGRectGetMaxY(lineImageView.frame) + 10, iconWidth, iconHeight);
	[weiboButton addTarget:self action:@selector(weiboSet) forControlEvents:UIControlEventTouchUpInside];
    [weiboButton setBackgroundImage:weiboImage forState:UIControlStateNormal];
	[self.moreView addSubview:weiboButton];
	[weiboImage release];
    
    UILabel *weiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(weiboButton.frame.origin.x, CGRectGetMaxY(weiboButton.frame) + 5 , weiboImage.size.width, 20)];
	weiboLabel.text = @"微博设置";	
	weiboLabel.textColor = [UIColor blackColor];
	weiboLabel.font = [UIFont systemFontOfSize:12.0f];
	weiboLabel.textAlignment = UITextAlignmentCenter;
	weiboLabel.backgroundColor = [UIColor clearColor];
	[self.moreView addSubview:weiboLabel];
	[weiboLabel release];
    [weiboView release];
    
    //反馈
    UIImage *feedbackImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"留言反馈" ofType:@"png"]];
    UIImageView *feedbackView = [[UIImageView alloc] initWithImage:feedbackImage];
    feedbackView.frame = CGRectMake(CGRectGetMaxX(weiboButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, feedbackImage.size.width, feedbackImage.size.height);
    [self.moreView addSubview:feedbackView];
    
	UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	feedbackButton.frame = CGRectMake(CGRectGetMaxX(weiboButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, feedbackImage.size.width, feedbackImage.size.height);
	[feedbackButton addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
	[feedbackButton setBackgroundImage:feedbackImage forState:UIControlStateNormal];
	[self.moreView addSubview:feedbackButton];
	[feedbackImage release];
    
    UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(feedbackButton.frame.origin.x, CGRectGetMaxY(feedbackButton.frame) + 5 , feedbackImage.size.width, 20)];
	feedbackLabel.text = @"留言反馈";	
	feedbackLabel.textColor = [UIColor blackColor];
	feedbackLabel.font = [UIFont systemFontOfSize:12.0f];
	feedbackLabel.textAlignment = UITextAlignmentCenter;
	feedbackLabel.backgroundColor = [UIColor clearColor];
	[self.moreView addSubview:feedbackLabel];
	[feedbackLabel release];
    
    if (_isLogin == YES) {
        NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
        int feedbackNum = [[[memberArray objectAtIndex:0] objectAtIndex:member_info_feedbackNum] intValue];
       
        if (feedbackNum > 0) {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"]];
            numView = [[UIImageView alloc] initWithImage:image];
            numView.frame = CGRectMake(CGRectGetMaxX(feedbackView.frame) - image.size.width + 5 ,feedbackView.frame.origin.y - 5, image.size.width, image.size.height);
            [self.moreView addSubview:numView];
        }
    }
    [feedbackView release];
    
    //推荐应用
    UIImage *recommendAppImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐应用" ofType:@"png"]];
    UIImageView *recommendAppView = [[UIImageView alloc] initWithImage:recommendAppImage];
    recommendAppView.frame = CGRectMake(CGRectGetMaxX(feedbackButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, recommendAppImage.size.width, recommendAppImage.size.height);
    [self.moreView addSubview:recommendAppView];
    
	UIButton *recommendAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
	recommendAppButton.frame = CGRectMake(CGRectGetMaxX(feedbackButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, recommendAppImage.size.width, recommendAppImage.size.height);
	[recommendAppButton addTarget:self action:@selector(recommendApp) forControlEvents:UIControlEventTouchUpInside];
	[recommendAppButton setBackgroundImage:recommendAppImage forState:UIControlStateNormal];
	[self.moreView addSubview:recommendAppButton];
	[recommendAppImage release];
    
    UILabel *recommendAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(recommendAppButton.frame.origin.x, CGRectGetMaxY(recommendAppButton.frame) + 5 , recommendAppImage.size.width, 20)];
	recommendAppLabel.text = @"推荐应用";	
	recommendAppLabel.textColor = [UIColor blackColor];
	recommendAppLabel.font = [UIFont systemFontOfSize:12.0f];
	recommendAppLabel.textAlignment = UITextAlignmentCenter;
	recommendAppLabel.backgroundColor = [UIColor clearColor];
	[self.moreView addSubview:recommendAppLabel];
	[recommendAppLabel release];
    [recommendAppView release];
    
    //检测新版本
    UIImage *freshImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"更新" ofType:@"png"]];
    UIImageView *freshView = [[UIImageView alloc] initWithImage:freshImage];
    freshView.frame = CGRectMake(CGRectGetMaxX(recommendAppButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, freshImage.size.width, freshImage.size.height);
    [self.moreView addSubview:freshView];
    
	UIButton *freshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	freshButton.frame = CGRectMake(CGRectGetMaxX(recommendAppButton.frame) + midIconWidth , CGRectGetMaxY(lineImageView.frame) + 10, freshImage.size.width, freshImage.size.height);
	[freshButton addTarget:self action:@selector(fresh) forControlEvents:UIControlEventTouchUpInside];
	[freshButton setBackgroundImage:freshImage forState:UIControlStateNormal];
	[self.moreView addSubview:freshButton];
	[freshImage release];
    
    UILabel *freshLabel = [[UILabel alloc] initWithFrame:CGRectMake(freshButton.frame.origin.x, CGRectGetMaxY(freshButton.frame) + 5 , freshImage.size.width, 20)];
	freshLabel.text = @"检查更新";
	freshLabel.textColor = [UIColor blackColor];
	freshLabel.font = [UIFont systemFontOfSize:12.0f];
	freshLabel.textAlignment = UITextAlignmentCenter;
	freshLabel.backgroundColor = [UIColor clearColor];
	[self.moreView addSubview:freshLabel];
	[freshLabel release];
    [freshView release];
    
    
    //分享好友
    UIImage *shareImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"分享" ofType:@"png"]];
    UIImageView *shareView = [[UIImageView alloc] initWithImage:shareImage];
    shareView.frame = CGRectMake(lineImageView.frame.origin.x, CGRectGetMaxY(weiboLabel.frame) + 10, shareImage.size.width, shareImage.size.height);
    [self.moreView addSubview:shareView];
    
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = shareView.frame;
	[shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
	[shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
	[self.moreView addSubview:shareButton];
	[shareImage release];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(shareButton.frame.origin.x, CGRectGetMaxY(shareButton.frame) + 5 , shareImage.size.width, 20)];
	shareLabel.text = @"分享好友";
	shareLabel.textColor = [UIColor blackColor];
	shareLabel.font = [UIFont systemFontOfSize:12.0f];
	shareLabel.textAlignment = UITextAlignmentCenter;
	shareLabel.backgroundColor = [UIColor clearColor];
	[self.moreView addSubview:shareLabel];
	[shareLabel release];
    [shareView release];
    
    CGFloat floatNum = ceil(5.0 / 4.0);
    
    //评分
    NSMutableArray *gradeArray = (NSMutableArray *)[DBOperate queryData:T_APP_INFO
                                                              theColumn:@"type" theColumnValue:@"1" withAll:NO];
    if (gradeArray != nil && [gradeArray count] > 0) {
        NSString *updateGradeUrl = [[gradeArray objectAtIndex:0] objectAtIndex:app_info_url];
        if (updateGradeUrl != nil && [updateGradeUrl length] > 0) {
            UIImage *commentImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"评分" ofType:@"png"]];
            UIImageView *commentView = [[UIImageView alloc] initWithImage:commentImage];
            commentView.frame = CGRectMake(CGRectGetMaxX(weiboButton.frame) + midIconWidth , CGRectGetMaxY(weiboLabel.frame) + 10, commentImage.size.width, commentImage.size.height);
            [self.moreView addSubview:commentView];
            
            UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            commentButton.frame = commentView.frame;
            [commentButton addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
            [commentButton setBackgroundImage:commentImage forState:UIControlStateNormal];
            [self.moreView addSubview:commentButton];
            [commentImage release];
            
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentButton.frame.origin.x, CGRectGetMaxY(commentButton.frame) + 5 , commentImage.size.width, 20)];
            commentLabel.text = @"为我打分";
            commentLabel.textColor = [UIColor blackColor];
            commentLabel.font = [UIFont systemFontOfSize:12.0f];
            commentLabel.textAlignment = UITextAlignmentCenter;
            commentLabel.backgroundColor = [UIColor clearColor];
            [self.moreView addSubview:commentLabel];
            [commentLabel release];
            [commentView release];
            
            floatNum = ceil(6.0 / 4.0);
        }
    }
    
    CGFloat moreHeigh = floatNum * 90.0f + 27.0f;
    
    [self.moreView setFrame:CGRectMake(0.0f , CGRectGetMaxY(self.introductionView.frame), 320.0f, moreHeigh)];
}




//关于我们
-(void)aboutUs
{
	aboutUsViewController *aboutUsDetail = [[aboutUsViewController alloc] init];			
	[self.navigationController pushViewController:aboutUsDetail animated:YES];
	[aboutUsDetail release];
}

//微博设置
-(void)weiboSet
{
	weiboSetViewController *weiboSetDetail = [[weiboSetViewController alloc] init];			
	[self.navigationController pushViewController:weiboSetDetail animated:YES];
	[weiboSetDetail release];
}

//在线反馈
-(void)feedback
{
    if (_isLogin == YES) {
        Login_feedbackViewController *login_feedback = [[Login_feedbackViewController alloc] init];
        [self.navigationController pushViewController:login_feedback animated:YES];
        [login_feedback release];
        
        if (numView != nil) {
            [numView removeFromSuperview];
        }
        NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
        int userId = [[[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
        [DBOperate updateData:T_MEMBER_INFO tableColumn:@"feedbackNum" columnValue:@"0" conditionColumn:@"memberId" conditionColumnValue:[NSString stringWithFormat:@"%d",userId]];
    }else {
        feedbackViewController *feedbackDetail = [[feedbackViewController alloc] init];
        [self.navigationController pushViewController:feedbackDetail animated:YES];
        [feedbackDetail release];
    }
}

//推荐应用
-(void)recommendApp
{
    recommendAppViewController *recommendApp = [[recommendAppViewController alloc] init];			
	[self.navigationController pushViewController:recommendApp animated:YES];
	[recommendApp release];
}

- (void)fresh
{
    MBProgressHUD *progress = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0 ,320 , 380 )];
    progress.delegate = self;
    progress.labelText = @"新版本检测中...";
    [self.view addSubview:progress];
    [self.view bringSubviewToFront:progress];
    [progress show:YES];
    [progress hide:YES afterDelay:3.0f];
    [progress release];
}

- (void)comment
{
    NSMutableArray *gradeArray = (NSMutableArray *)[DBOperate queryData:T_APP_INFO
                                                              theColumn:@"type" theColumnValue:@"1" withAll:NO];
    if (gradeArray != nil && [gradeArray count] > 0) {
        NSArray *array = [gradeArray objectAtIndex:0];
        NSString *appGradeUrl = [array objectAtIndex:app_info_url];
        NSURL *url = [NSURL URLWithString:appGradeUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
}
-(void)share{
    // 分享创建实例
    if (ShareSheet == nil) {
        ShareSheet = [[ShareAction alloc]init];
    }
    
    ShareSheet.shareDelegate = self;
    
    // 分享显示弹窗
    [ShareSheet shareActionShow:self.parentViewController.view navController:self.navigationController];
    
}

// 分享委托
#pragma mark - Share Delegate
- (NSDictionary *)shareSheetRetureValue  
{
    NSString *str = @"app/jump";
	NSString *link = [NSString stringWithFormat:@"%@%@",DETAIL_SHARE_LINK,str];
	NSString *content = [NSString stringWithFormat:@"[%@]",kAPPName];
    NSString *allContent = [NSString stringWithFormat:@"我正在使用一款非常不错的应用[%@],赶快来体验吧~ %@",kAPPName,link];
    UIImage *shareImage = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]] autorelease];
    
    // 分享的内容信息字典
    NSDictionary *dict;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            shareImage,ShareImage,
            allContent,ShareAllContent,
            content,ShareContent,
            link,ShareUrl,  nil];
    
    return dict;
}

#pragma mark MBProgressHUD
- (void)hudWasHidden:(MBProgressHUD *)hud{
	[hud removeFromSuperview];
	
	NSMutableArray *updateArray = (NSMutableArray *)[DBOperate queryData:T_APP_INFO
                                                               theColumn:@"type" theColumnValue:@"0" withAll:NO];
	if (updateArray != nil && [updateArray count] > 0) {
		NSArray *array = [updateArray objectAtIndex:0];
		int newVersion = [[array objectAtIndex:app_info_ver] intValue];
		if (newVersion <= CURRENT_APP_VERSION) {
			[alertView showAlert:@"当前已经是最新版本了"];
		}else {
			//NSURL *url = [NSURL URLWithString:updateUrl];
			//[[UIApplication sharedApplication] openURL:url];
            //			UpdateAppAlert *alert = [[UpdateAppAlert alloc]
            //									 initWithContent:@"检测到新版本" content:@"资讯版有新版本了！是否马上更新升级到新版本？"
            //									 leftbtn:@"稍后再说 " rightbtn:@"立即更新" url:updateUrl onViewController:self.navigationController];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:TIPS_NEWVERSION message:[array objectAtIndex:app_info_remark] delegate:self cancelButtonTitle:@"稍后提示我" otherButtonTitles:@"立即更新", nil];
            alertView.tag = 1;
            [alertView show];
            [alertView release];
		}
		
	}else{
		[alertView showAlert:@"当前已经是最新版本了"];
	}
}

#pragma mark - UIAlertViewDelegate
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (IOS_VERSION < 7)
    {
        UIView * view = [alertView.subviews objectAtIndex:2];
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*) view;
            label.textAlignment = UITextAlignmentLeft;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSArray *updateArray = [DBOperate queryData:T_APP_INFO theColumn:@"type" theColumnValue:@"0" withAll:NO];
        if(updateArray != nil && [updateArray count] > 0){
            NSArray *array = [updateArray objectAtIndex:0];
            NSString *url = [array objectAtIndex:app_info_url];
            [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
                  conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:0]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    } else if (buttonIndex == 2) {
        [DBOperate updateData:T_APP_INFO tableColumn:@"remide" columnValue:@"1"
              conditionColumn:@"type" conditionColumnValue:[NSNumber numberWithInt:0]];
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
    
    self.mainScrollView = nil;
    self.introductionView = nil;
    self.moreView = nil;
    self.spinner = nil;
    aboutButton = nil;
    __listArray = nil;
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
    imageDownloadsInProgressDic = nil;
    imageDownloadsInWaitingArray = nil;
    iconDownLoad = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
 
    self.mainScrollView = nil;
    self.introductionView = nil;
    self.moreView = nil;
    self.spinner = nil;
    aboutButton = nil;
    __listArray = nil;
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
    imageDownloadsInProgressDic = nil;
    imageDownloadsInWaitingArray = nil;
    iconDownLoad = nil;
    
    [super dealloc];
}

#pragma mark ------private methods
- (void)accessService
{
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
                                 [Common getVersion:MORE_CAT_COMMAND_ID],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MORE_CAT_COMMAND_ID 
								  accessAdress:@"more/acats.do?param=%@" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
	switch (commandid) 
    {
		case MORE_CAT_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
		}
        break;
        default:
			break;
	}
}

- (void)update
{
    self.listArray = (NSMutableArray *)[DBOperate queryData:T_MORE_CAT theColumn:nil theColumnValue:nil withAll:YES];
    
    //创建介绍视图
    [self createIntroductionView];
    
    //更多功能按钮
    [self createMoreView];
    
    //设置总体高度
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.introductionView.frame.size.height + self.moreView.frame.size.height + 44.0f + 49.0f);
    
    //移出loading图标
    [self.spinner removeFromSuperview];
    
}

#pragma mark ---- loadImage Method
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
    //NSLog(@"%@",index);
	IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:index];
    if (iconDownloader == nil && imageURL != nil && imageURL.length > 1) 
    {
		if (imageURL != nil && imageURL.length > 1) 
		{
			if ([imageDownloadsInProgressDic count] >= DOWNLOAD_IMAGE_MAX_COUNT) {
				imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL withIndexPath:index withImageType:CUSTOMER_PHOTO];
				[imageDownloadsInWaitingArray addObject:one];
				[one release];
				return;
			}
			
			IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
			iconDownloader.downloadURL = imageURL;
			iconDownloader.indexPathInTableView = index;
			iconDownloader.imageType = CUSTOMER_PHOTO;
			iconDownloader.delegate = self;
			[imageDownloadsInProgressDic setObject:iconDownloader forKey:index];
			[iconDownloader startDownload];
			[iconDownloader release];   
		}
	}    
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [imageDownloadsInProgressDic objectForKey:indexPath];

    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0){ 			
			UIImage *photo = iconDownloader.cardIcon;
			NSString *photoname = [callSystemApp getCurrentTime];
			if ([FileManager savePhoto:photoname withImage:photo])
            {
				NSArray *one = [self.listArray objectAtIndex:iconDownloader.indexPathInTableView.row - 10000]; 
				NSNumber *value = [one objectAtIndex:morecat_catId];
			    [DBOperate updateData:T_MORE_CAT tableColumn:@"imagename" 
						  columnValue:photoname conditionColumn:@"catId" conditionColumnValue:value];
                self.listArray = (NSMutableArray *)[DBOperate queryData:T_MORE_CAT 
																  theColumn:nil theColumnValue:nil withAll:YES];
			}
            
            UIButton *currentButton = (UIButton *)[self.introductionView viewWithTag:[indexPath row]];
            [currentButton setBackgroundImage:[photo fillSize:CGSizeMake(iconWidth, iconHeight)] forState:UIControlStateNormal];
		}
		[imageDownloadsInProgressDic removeObjectForKey:indexPath];
		if ([imageDownloadsInWaitingArray count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaitingArray objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaitingArray removeObjectAtIndex:0];
		}		
    }
}

- (void)buttonAction:(UIButton *)sender
{
    int index = sender.tag;
    NSArray *ay = [self.listArray objectAtIndex:index - 10000];
    
    MoreButtonViewController *btnViewController = [[MoreButtonViewController alloc] init];
    btnViewController.catStr = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:morecat_catId] intValue]];
    btnViewController.titleStr = [NSString stringWithFormat:@"%@",[ay objectAtIndex:morecat_catName]];
    [self.navigationController pushViewController:btnViewController animated:YES];
    //[btnViewController release];
}

@end
