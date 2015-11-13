//
//  MenberCenterMainViewController.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MenberCenterMainViewController.h"
#import "ProductViewController.h"
#import "BuyViewController.h"
#import "ShopsViewController.h"
#import "InformationViewController.h"
#import "LoginViewController.h"
#import "DataManager.h"
#import "Encry.h"
#import "Common.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "LoginViewController.h"
#import "ProfessionAppDelegate.h"
#import "imageDownLoadInWaitingObject.h"
#import "UIImageScale.h"
#import "MessageViewController.h"
#import "MemberEditViewController.h"
#import "ZbarViewController.h"
#import "MyContactsBookViewController.h"
#import "CustomTabBar.h"
#import "MyActivityViewController.h"
#import "PasswordViewController.h"

@implementation MenberCenterMainViewController
@synthesize mainScrollView = _mainScrollView;
@synthesize memberHeaderView;
@synthesize memberName;
@synthesize memberLevel;

@synthesize productViewController;
@synthesize buyViewController;
@synthesize shopsViewController;
@synthesize infoViewController;
@synthesize iconDownLoad;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize delegate;
@synthesize loginViewController = _loginViewController;
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
    
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    CGFloat fixHeight = [UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f;
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, fixHeight)];
	_mainScrollView.pagingEnabled = NO;
	_mainScrollView.delegate = self;
	_mainScrollView.showsHorizontalScrollIndicator = NO;
	_mainScrollView.showsVerticalScrollIndicator = YES;
	_mainScrollView.backgroundColor = [UIColor whiteColor];
	_mainScrollView.contentSize = CGSizeMake(320, 620);
	[self.view addSubview:_mainScrollView];
    
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    tapView.backgroundColor = [UIColor clearColor];
    tapView.userInteractionEnabled = YES;
    [self.mainScrollView addSubview:tapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    [tapView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    [tapGesture release];
	
	UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
    headerImageView.layer.masksToBounds = YES;
    headerImageView.layer.cornerRadius = 5;
	self.memberHeaderView = headerImageView;
    [self.mainScrollView addSubview:headerImageView];
	[headerImageView release];
	memberHeaderView.userInteractionEnabled = YES;
	
	UIImage *newsimage = [[UIImage alloc]initWithContentsOfFile:
						  [[NSBundle mainBundle] pathForResource:@"会员中心默认头像" ofType:@"png"]];
	memberHeaderView.image = newsimage;
	[newsimage release];
	
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame) + 15, 15, 60, 20)];
    //UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	nameLabel.text = @"";
	nameLabel.font = [UIFont systemFontOfSize:16.0f];
	nameLabel.tag = 100;
	nameLabel.textAlignment = UITextAlignmentLeft;
	nameLabel.backgroundColor = [UIColor clearColor];
	[self.mainScrollView addSubview:nameLabel];
	[nameLabel release];
	
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 15, 15, 100, 20)];
	levelLabel.text = @"";
	levelLabel.font = [UIFont systemFontOfSize:14.0f];
	levelLabel.tag = 200;
	levelLabel.textAlignment = UITextAlignmentLeft;
	levelLabel.backgroundColor = [UIColor clearColor];
	[self.mainScrollView addSubview:levelLabel];
	[levelLabel release];
    
	UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame) + 15, 35, 200, 40)];
	companyLabel.text = @"";
	companyLabel.font = [UIFont systemFontOfSize:14.0f];
	companyLabel.tag = 300;
    //companyLabel.lineBreakMode = UILineBreakModeWordWrap;
	companyLabel.numberOfLines = 2;
	companyLabel.textAlignment = UITextAlignmentLeft;
	companyLabel.backgroundColor = [UIColor clearColor];
	[self.mainScrollView addSubview:companyLabel];
	[companyLabel release];
	
    UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    [arrowImageView setFrame:CGRectMake(320 - 15 - arrowImage.size.width, 15 + (headerImageView.frame.size.height - arrowImage.size.height) * 0.5f, arrowImage.size.width, arrowImage.size.height)];
    [arrowImageView setImage:arrowImage];
    [self.mainScrollView addSubview:arrowImageView];
    [arrowImageView release];
    [arrowImage release];
    
    NSString *favorite_supply_name = FAVORITE_SUPPLY_NAME;
    NSString *favorite_shop_name = FAVORITE_SHOP_NAME;
    NSString *favorite_news_name = FAVORITE_NEWS_NAME;
    
	NSArray *titleArray = [[NSArray alloc] initWithObjects:@"我的活动",@"消息中心",@"我的二维码",@"名片夹",favorite_shop_name,favorite_news_name,favorite_supply_name,@"修改密码", nil];
    NSArray *cellImageArray = [[NSArray alloc] initWithObjects:@"icon_member_我的活动",@"icon_member_消息中心",@"icon_member_我的二维码",@"icon_member_名片夹",@"icon_member_收藏",@"icon_member_收藏",@"icon_member_收藏",@"icon_member_password", nil];
	for (int i = 0; i < [titleArray count]; i++) {
		UIImage *cellImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[cellImageArray objectAtIndex:i] ofType:@"png"]];
		
		UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cellButton.tag = i + 10;
		
        if (i == 4) {
            cellButton.frame = CGRectMake(10, CGRectGetMaxY(headerImageView.frame) + 15 +i*44.f + 4*10, 300.f, 44.f);
            [cellButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"圆角矩形上" ofType:@"png"]] forState:UIControlStateNormal];
        } else if (i == 5) {
            cellButton.frame = CGRectMake(10, CGRectGetMaxY(headerImageView.frame) + 15 +i*44.f + 4*10 - 1.f, 300.f, 44.f);
            [cellButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_member_list_middle" ofType:@"png"]] forState:UIControlStateNormal];
        } else if (i == 6) {
            cellButton.frame = CGRectMake(10, CGRectGetMaxY(headerImageView.frame) + 15 +i*44.f + 4*10 - 2.f, 300.f, 44.f);
            [cellButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_membe_list_last" ofType:@"png"]] forState:UIControlStateNormal];
        } else {
            if (i > 6) {
                cellButton.frame = CGRectMake(10, CGRectGetMaxY(headerImageView.frame) + 15 +i*44.f + (i-2) *10, 300.f, 44.f);
            } else {
                cellButton.frame = CGRectMake(10, CGRectGetMaxY(headerImageView.frame) + 15 +i*44.f + i *10, 300.f, 44.f);
            }
            [cellButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_个人中心_list" ofType:@"png"]] forState:UIControlStateNormal];
        }
		
		[cellButton addTarget:self action:@selector(didSelectAction:) forControlEvents:UIControlEventTouchUpInside];
		[self.mainScrollView addSubview:cellButton];
		
		UILabel *str = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 150, 34)];
		str.text = [titleArray objectAtIndex:i];
		str.font = [UIFont systemFontOfSize:16.0f];
		str.textAlignment = UITextAlignmentLeft;
		str.backgroundColor = [UIColor clearColor];
		[cellButton addSubview:str];
		[str release];

        UIImageView *imagebtn = [[UIImageView alloc]initWithFrame:CGRectMake(10.f, 7.f, cellImage.size.width, cellImage.size.height)];
        imagebtn.image = cellImage;
        [cellButton addSubview:imagebtn];
        [cellImage release];
        [imagebtn release];
        
        UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
        UIImageView *btnlast = [[UIImageView alloc]initWithFrame:CGRectMake(300.f - arrowImage.size.height-10.f, 44.f/2 - arrowImage.size.height/2, arrowImage.size.width, arrowImage.size.height)];
        btnlast.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
        [cellButton addSubview:btnlast];
        [btnlast release];
        
        if (i == 1) {
            UIImage *msgImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"消息提示" ofType:@"png"]];
            msgView = [[UIImageView alloc] initWithImage:msgImage];
            msgView.frame = CGRectMake(cellButton.frame.size.width - msgImage.size.width - 30, (cellButton.frame.size.height - msgImage.size.height) * 0.5, msgImage.size.width, msgImage.size.height);
            msgView.tag = 400;
            [cellButton addSubview:msgView];
            msgView.hidden = YES;
            
            msgLabel = [[UILabel alloc] initWithFrame:msgView.frame];
            msgLabel.text = @"";
            msgLabel.textColor = [UIColor whiteColor];
            msgLabel.font = [UIFont systemFontOfSize:14.0f];
            msgLabel.tag = 500;
            msgLabel.textAlignment = UITextAlignmentCenter;
            msgLabel.backgroundColor = [UIColor clearColor];
            [cellButton addSubview:msgLabel];
        }
	}
	
	
    UIImage *btnImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"注销账号按钮" ofType:@"png"]];
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake((320 - btnImage.size.width) * 0.5, CGRectGetMaxY(headerImageView.frame) + 15 +titleArray.count*44.f + (titleArray.count-2) *10, btnImage.size.width, btnImage.size.height);
	[cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setImage:btnImage forState:UIControlStateNormal];
	[self.mainScrollView addSubview:cancelButton];
	[btnImage release];
    
    [titleArray release];
	[cellImageArray release];
}


- (void)viewAppearAction{
	NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
	if ([dbArray count] != 0) {
		NSArray *ay = [dbArray objectAtIndex:0];
		
		UILabel *name = (UILabel *)[self.view viewWithTag:100];
		NSString *nameStr = [ay objectAtIndex:member_info_memberFirstName];
        name.text = nameStr;
        
        //名字间距
        NSString *nameString = nameStr;
        CGSize nameConstraint = CGSizeMake(20000.0f, 20.0f);
        CGSize nameSize = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:nameConstraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat fixWidth = nameSize.width + 10.0f;
        
		NSString *levelStr = [ay objectAtIndex:member_info_post];
		UILabel *level = (UILabel *)[self.view viewWithTag:200];
        [level setFrame:CGRectMake(90 + fixWidth, 15, 100, 20)];
        level.text = levelStr;
        
		NSString *companyStr = [ay objectAtIndex:member_info_companyName];
		UILabel *company = (UILabel *)[self.view viewWithTag:300];
        company.text = companyStr;
        
        int msgNum = [[ay objectAtIndex:member_info_newMessageNum] intValue];
        if (msgNum != 0) {
            msgView.hidden = NO;
            msgLabel.text = [NSString stringWithFormat:@"%d",msgNum];
        }
        
		if (_isChangedImage == NO) {
			NSString *piclink = [ay objectAtIndex:member_info_image];
			//NSLog(@"piclink===%@",piclink);

            NSString *photoname = [Common encodeBase64:(NSMutableData *)[piclink dataUsingEncoding: NSUTF8StringEncoding]];
			UIImage *img = [FileManager getPhoto:photoname];
			if (img != nil) {
				memberHeaderView.image = img;
                
                ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
                deleagte.headerImage = img;
			}else {
				if (piclink.length > 0) {
					[self startIconDownload:piclink forIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
				}
			}
			
		}else {
			ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
			memberHeaderView.image = deleagte.headerImage;
		}
        
        //        NSString *phoneStr = [ay objectAtIndex:member_info_mobile];
        //		UILabel *phone = (UILabel *)[self.view viewWithTag:400];
        //        phone.text = phoneStr;
        //        
        //        NSString *telStr = [ay objectAtIndex:member_info_tel];
        //		UILabel *tel = (UILabel *)[self.view viewWithTag:500];
        //        tel.text = telStr;
        //        
        //        NSString *faxStr = [ay objectAtIndex:member_info_email];
        //		UILabel *fax = (UILabel *)[self.view viewWithTag:600];
        //        fax.text = faxStr;
        //        
        //        NSString *addrStr = [ay objectAtIndex:member_info_city];
        //		UILabel *addr = (UILabel *)[self.view viewWithTag:700];
        //        addr.text = addrStr;
        //        
        //        NSString *addressStr = [ay objectAtIndex:member_info_addr];
        //		UILabel *address = (UILabel *)[self.view viewWithTag:800];
        //        address.text = addressStr;
        
        if (is_push_with_msg)
        {
            is_push_with_msg = NO;
            MessageViewController *message = [[MessageViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:message animated:YES];
            [message release];
            
            [self removeMsgView];
        }
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
    memberHeaderView = nil;
	memberName = nil;
	memberLevel = nil;
	productViewController = nil;
	buyViewController = nil;
	shopsViewController = nil;
	infoViewController = nil;
	_loginViewController = nil;
	delegate = nil;
	imageDownloadsInWaiting = nil;
	imageDownloadsInProgress = nil;
}


- (void)dealloc {
	[memberHeaderView release];
	[memberName release];
	[memberLevel release];
	[productViewController release];
	[buyViewController release];
	[shopsViewController release];
	[infoViewController release];
	[_loginViewController release];
	
	[imageDownloadsInWaiting release];
	[imageDownloadsInProgress release];
	
	memberHeaderView = nil;
	memberName = nil;
	memberLevel = nil;
	productViewController = nil;
	buyViewController = nil;
	shopsViewController = nil;
	infoViewController = nil;
	_loginViewController = nil;
	delegate = nil;
	imageDownloadsInWaiting = nil;
	imageDownloadsInProgress = nil;
    [msgView release];
    [msgLabel release];
    [super dealloc];
}

#pragma mark ----UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [delegate actionButtonIndex:buttonIndex imageView:self.memberHeaderView];
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
			//UIImage *photo = iconDownloader.cardIcon;
			UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(60, 60)];

            NSString *url = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_image];
            NSString *photoname = [Common encodeBase64:(NSMutableData *)[url dataUsingEncoding: NSUTF8StringEncoding]];
            
			[FileManager savePhoto:photoname withImage:photo];
			memberHeaderView.image = photo;
            
            ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
			deleagte.headerImage = photo;
		}
		
		[imageDownloadsInProgress removeObjectForKey:indexPath];
		if ([imageDownloadsInWaiting count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaiting removeObjectAtIndex:0];
		}	
		
    }	
}


#pragma mark -----private methods
- (void)cancelAction
{
    [self accessService];
    
	[DBOperate deleteData:T_MEMBER_INFO];
    [DBOperate deleteData:T_SYSTEM_CONFIG tableColumn:@"tag" columnValue:@"activityId"];
	
	self.view.hidden = YES;
    self.loginViewController.img = nil;
	_isLogin = NO;
	self.loginViewController.tabBarController.title = @"登录";
    
	ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
	deleagte.headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员中心默认头像" ofType:@"png"]];
	self.memberHeaderView.image = deleagte.headerImage;
    
    [self.loginViewController viewWillAppear:YES];
    
    [self removeMsgView];
    
}

- (void)didSelectAction:(UIButton *)btn
{
	//NSLog(@"btn.tag=====%d",btn.tag);
	switch (btn.tag) {
		case 10:
		{
			MyActivityViewController *activity = [[MyActivityViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:activity animated:YES];
            [activity release];
		}
			break;
		case 11:
		{
            MessageViewController *message = [[MessageViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:message animated:YES];
            [message release];
            
            [self removeMsgView];
			
		}
			break;
		case 12:
		{
            ZbarViewController *zbView = [[ZbarViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:zbView animated:YES];
            [zbView release];
		}
			break;
        case 13:
		{
            MyContactsBookViewController *contactsBook = [[MyContactsBookViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:contactsBook animated:YES];
            [contactsBook release];
		}
			break;
		case 14:
		{
            ShopsViewController *shops = [[ShopsViewController alloc] init];
            [self.loginViewController.navigationController pushViewController:shops animated:YES];
            [shops release];
		}
			break;
        case 15:
		{
			InformationViewController *info = [[InformationViewController alloc] init];
			[self.loginViewController.navigationController pushViewController:info animated:YES];
			[info release];
		}
            break;
        case 16:
		{
			ProductViewController *product = [[ProductViewController alloc] init];
			[self.loginViewController.navigationController pushViewController:product animated:YES];
			[product release];
		}
             break;
        case 17:
		{
			PasswordViewController *passwordView = [[PasswordViewController alloc] init];
			[self.loginViewController.navigationController pushViewController:passwordView animated:YES];
			[passwordView release];
		}
            break;
		default:
			break;
	}
	
}

- (void)changeImage
{
    //	UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中上传", nil];
    //    [action showInView:((ProfessionAppDelegate *)[UIApplication sharedApplication].delegate).window];
    //	[action release];
    MemberEditViewController *edit = [[MemberEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.loginViewController.navigationController pushViewController:edit animated:YES];
    
}

- (void)removeMsgView
{
    NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
    if ([dbArray count] != 0) {
        NSArray *ay = [dbArray objectAtIndex:0];
        NSString *userId = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:member_info_memberId] intValue]];
        [DBOperate updateData:T_MEMBER_INFO tableColumn:@"newMessageNum" columnValue:@"0" conditionColumn:@"memberId" conditionColumnValue:userId];
        
        if ([[ay objectAtIndex:member_info_feedbackNum] intValue] > 0) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }else {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    }
    msgView.hidden = YES;
    msgLabel.text = @"";   
    
    NSArray *arrayViewControllers = self.loginViewController.navigationController.viewControllers;
    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
    {
        CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
        UIImageView *view = (UIImageView *)[tabViewController.view viewWithTag:22222];
        if (view != nil) {
            if (view) {
                [view removeFromSuperview];
            }
        }
    }
    
}

- (void)accessService
{
    int userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 [NSNumber numberWithInt: userId],@"user_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_CANCEL_COMMAND_ID
								  accessAdress:@"member/logout.do?param=%@" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case MEMBER_CANCEL_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(logoutResult) withObject:nil waitUntilDone:NO];
		}break;
        default:
			break;
	}
	
//	if (progressHUD != nil) {
//		[progressHUD removeFromSuperViewOnHide];
//	}
}

- (void)logoutResult
{
    
}
@end
