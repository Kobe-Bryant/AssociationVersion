//
//  cardDetailViewController.m
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cardDetailViewController.h"
#import "Common.h"
#import "UIImageScale.h"
#import "callSystemApp.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"
#import "mapViewController.h"
#import "alertView.h"

@interface cardDetailViewController ()

@end

@implementation cardDetailViewController

@synthesize delegate;
@synthesize cardInfo;
@synthesize cUserId;
@synthesize myTableView;
@synthesize userId;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize spinner;
@synthesize progressHUD;
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setFrame:CGRectMake( 0.0f , 0.0f , 300.0f , 300.0f)];
    
    isFavorite = NO;
    
    photoWith = 50;
    photoHigh = 50;
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    //获取当前登陆用户的user_id
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
    NSMutableArray *favorite = (NSMutableArray *)[DBOperate queryData:T_CONTACTSBOOK_FAVORITE theColumn:@"user_id" equalValue:self.cUserId theColumn:@"memberId" equalValue:self.userId];
    
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
        
    //判断是否有数据 没有数据从网络获取
    if (self.cardInfo == nil || [self.cardInfo count] == 0) 
    {
        if ([self.cUserId intValue] != 0 && self.cUserId != nil) 
        {
            //添加loading图标
            UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, 150)];
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
            
            //本地没有数据 则从网络请求        
            [self accessItemService];
            
        }
        else 
        {
            UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 300, 20)];
            [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
            noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
            noneLabel.text = @"没找到相应的信息！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [self.view addSubview:noneLabel];
            [noneLabel release];
        }
        
    }
    else 
    {
        [self createView];
    }
    
}

//创建视图
-(void)createView
{
    //头像
    UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(20.0f, 30.0f, photoWith, photoHigh)];
	picView.tag = 1000;
    picView.layer.masksToBounds = YES;
    picView.layer.cornerRadius = 5;
	[self.view addSubview:picView];
	[picView release];
	
	//loading头像
	NSString *photoUrl = [self.cardInfo objectAtIndex:card_info_img];
	if (photoUrl.length > 1) 
	{
		NSIndexPath *photoIndexPath = [NSIndexPath indexPathForRow:10000 inSection:0];
		
		//获取本地图片缓存
		NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
        UIImage *cardIcon = [[FileManager getPhoto:picName] fillSize:CGSizeMake(photoWith, photoHigh)];
        
		if (cardIcon == nil)
		{
			UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员默认头像" ofType:@"png"]];
			picView.image = [img fillSize:CGSizeMake(photoWith, photoHigh)];
			[img release];
			[self startIconDownload:photoUrl forIndexPath:photoIndexPath];
		}
		else
		{
			picView.image = cardIcon;
		}
		
	}
	else
	{
		UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员默认头像" ofType:@"png"]];
		picView.image = [img fillSize:CGSizeMake(photoWith, photoHigh)];
		[img release];
	}
    
    //名称 公司等信息
    UILabel *name = [[UILabel alloc] 
                     initWithFrame:CGRectMake(80, 30, 80, 20)];
    name.text = [self.cardInfo objectAtIndex:card_info_user_name];
    name.font = [UIFont systemFontOfSize:16];
    name.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
    name.backgroundColor = [UIColor clearColor];
    [self.view addSubview:name];
    [name release];
    
    //名字间距
    NSString *nameString = [self.cardInfo objectAtIndex:card_info_user_name];
    CGSize constraint = CGSizeMake(20000.0f, 20.0f);
    CGSize size = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat fixWidth = size.width + 10.0f;
    
    UILabel *postLabel = [[UILabel alloc] 
                          initWithFrame:CGRectMake(80 + fixWidth, 30, 100, 20)];
    postLabel.text = [self.cardInfo objectAtIndex:card_info_post];
    postLabel.textColor = [UIColor grayColor];
    postLabel.font = [UIFont systemFontOfSize:12];
    postLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:postLabel];
    [postLabel release];
    
    UILabel *companyLabel = [[UILabel alloc] 
                             initWithFrame:CGRectMake(80, 50, 160, 30)];
    companyLabel.text = [self.cardInfo objectAtIndex:card_info_company_name];
    companyLabel.textColor = [UIColor grayColor];
    companyLabel.numberOfLines = 2;
    companyLabel.font = [UIFont systemFontOfSize:12];
    companyLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:companyLabel];
    [companyLabel release];
    
    //收藏按钮
	
	if (isFavorite) 
	{
        UIImageView *favoriteButton = [[UIImageView alloc]initWithFrame:CGRectMake(250.0f, 30.0f, 30.0f, 30.0f)];
		favoriteButton.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员详情icon已收藏" ofType:@"png"]];
        [self.view addSubview:favoriteButton];
        [favoriteButton release];
	}
	else
	{
        UIImage *favoriteButtonImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员详情icon未收藏" ofType:@"png"]];
        UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favoriteButton.frame = CGRectMake(250.0f, 30.0f, 30.0f, 30.0f);
        favoriteButton.tag = 2000;
        [favoriteButton addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
        [favoriteButton setBackgroundImage:favoriteButtonImage forState:UIControlStateNormal];
        [self.view addSubview:favoriteButton];
        [favoriteButtonImage release];
	}
    
    //数据列表  
    UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f , 80.0f , 290.0f , 163.0f) style:UITableViewStyleGrouped];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
    tempTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tempTableView.scrollEnabled = NO;
    tempTableView.backgroundView = nil;
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:myTableView];
    
    if (IOS_VERSION >= 7.0) {
        tempTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.myTableView.bounds.size.width, 10.f)];
    }
    
    //留言按钮   // dufu mod 2013.04.28
    UIImage *feedbackButtonImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"button_green" ofType:@"png"]];   
	UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	feedbackButton.frame = CGRectMake(15.0f, 250.0f, 270.0f, 40.0f);
	[feedbackButton addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
	[feedbackButton setBackgroundImage:[feedbackButtonImage stretchableImageWithLeftCapWidth:5 topCapHeight:0]forState:UIControlStateNormal];
    [feedbackButton setTitle:NSLocalizedString(@"发个信息",nil) forState:UIControlStateNormal]; // dufu add 2013.04.28
	[self.view addSubview:feedbackButton];
    [feedbackButtonImage release];
}

//收藏
-(void)favorite
{
    if ([self.cUserId isEqualToString:self.userId]) 
    {
        [alertView showAlert:@"不能收藏自己!"];
    }
    else 
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
                    self.progressHUD.labelText = @"发送中... ";
                    [self.view addSubview:self.progressHUD];
                    [self.view bringSubviewToFront:self.progressHUD];
                    [self.progressHUD show:YES];
                    
                    NSString *reqUrl = @"member/favorites.do?param=%@";
                    
                    NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [Common getSecureString],@"keyvalue",
                                                 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                                 self.userId,@"user_id",
                                                 [self.cardInfo objectAtIndex:card_info_id],@"info_id",
                                                 [NSNumber numberWithInt: 5],@"info_type",
                                                 [self.cardInfo objectAtIndex:card_info_user_name],@"title",
                                                 nil];
                    
                    [[DataManager sharedManager] accessService:jsontestDic 
                                                       command:OPERAT_SEND_CONTACTSBOOK_FAVORITE
                                                  accessAdress:reqUrl 
                                                      delegate:self 
                                                     withParam:nil];
                }
                else
                {
                    if ([delegate respondsToSelector:@selector(favoriteButtonTouch)]) 
                    {
                        [delegate favoriteButtonTouch];
                    }
                }
            }
            else 
            {
                if ([delegate respondsToSelector:@selector(favoriteButtonTouch)]) 
                {
                    [delegate favoriteButtonTouch];
                }
            }
        }
    }
}

//留言
-(void)feedback
{
    if ([delegate respondsToSelector:@selector(feedbackButtonTouch)]) 
    {
        if ([self.cUserId isEqualToString:self.userId]) {
            [alertView showAlert:@"不能和自己留言!"];
        }else {
            [delegate feedbackButtonTouch];
        }
    }
}

//跳转连接
-(void)goUrl:(NSString *)url
{
    if ([delegate respondsToSelector:@selector(feedbackButtonTouch)]) 
    {
        [delegate urlButtonTouch:url];
    }
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
	if ([indexPath row] == 10000)
	{
		NSString *photoUrl = [self.cardInfo objectAtIndex:card_info_img];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
		
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
            
            if ([indexPath row] == 10000) 
            {
                UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
                UIImageView *picView = (UIImageView *)[self.view viewWithTag:1000];
                picView.image = photo;
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


//网络获取数据
-(void)accessItemService
{
	NSString *reqUrl = @"userinfo.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 self.cUserId,@"user_id",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_CARDDETAIL_REFRESH 
								  accessAdress:reqUrl 
									  delegate:self
									 withParam:nil];
}

//更新商铺的操作
-(void)update:(NSMutableArray *)resultArray
{
	//移除loading图标
	[self.spinner removeFromSuperview];
	
    //创建视图
    if (resultArray == nil || [resultArray count] == 0)
    {
        UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 300, 20)];
        [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
        noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
        noneLabel.text = @"没找到相应的信息！";			
        noneLabel.textAlignment = UITextAlignmentCenter;
        noneLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:noneLabel];
        [noneLabel release];
    }
    else
    {
        self.cardInfo = [resultArray objectAtIndex:0];
        [self createView];
    }
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
    switch (commandid) {
        case OPERAT_CARDDETAIL_REFRESH:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        case OPERAT_SEND_CONTACTSBOOK_FAVORITE:
        {
            [self performSelectorOnMainThread:@selector(favoriteResult:) withObject:resultArray waitUntilDone:NO];
        }
            break;
            
        default:
            break;
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
        
        progressHUD.labelText = @"收藏成功";
        progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
        progressHUD.mode = MBProgressHUDModeCustomView;
        [progressHUD hide:YES afterDelay:1.0];
        
        //将名片写入名片收藏表
        NSMutableArray *infoList = [[NSMutableArray alloc] init];	
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_id]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_user_id]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_user_name]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_gender]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_post]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_company_name]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_tel]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_mobile]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_fax]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_email]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_cat_name]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_cat_id]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_province]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_city]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_district]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_address]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_img]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_created]];
        [infoList addObject:[self.cardInfo objectAtIndex:card_info_url]];
        [infoList addObject:@""];
        [infoList addObject:self.userId];

        //[DBOperate insertData:infoList tableName:T_CONTACTSBOOK_FAVORITE];
        [DBOperate insertDataWithnotAutoID:infoList tableName:T_CONTACTSBOOK_FAVORITE];
        [infoList release];
        
        isFavorite = YES;
        
        UIButton *favoriteButton = (UIButton *)[self.view viewWithTag:2000];
        [favoriteButton setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员详情icon已收藏" ofType:@"png"]] forState:UIControlStateNormal];
    }else {
        progressHUD.labelText = @"收藏失败";
        progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
        progressHUD.mode = MBProgressHUDModeCustomView;
        [progressHUD hide:YES afterDelay:1.0];
    }
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 38.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"listCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
		//cell.backgroundView = 
		//cell.selectedBackgroundView =
        
        //ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        //拨打图标
        UIImageView *callImageView = [[UIImageView alloc]initWithFrame:CGRectMake(235, 4, 30, 30)];
        callImageView.tag = 100;
        callImageView.hidden = YES;
        [cell.contentView addSubview:callImageView];
        [callImageView release];
        
        //标题
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 60, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.tag = 101;
        title.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
        [cell.contentView addSubview:title];
        [title release];
        
        //内容
        UILabel *titleInfo = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 170, 20)];
        titleInfo.backgroundColor = [UIColor clearColor];
        titleInfo.tag = 102;
        //titleInfo.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        titleInfo.font = [UIFont systemFontOfSize:14];
        titleInfo.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
        [cell.contentView addSubview:titleInfo];
        [titleInfo release];
	}
    if (self.cardInfo != nil) {
        
        int row = [indexPath row];
        UIImageView *callImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *title = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *titleInfo = (UILabel *)[cell.contentView viewWithTag:102];
        switch(row)
        {
            //电话号码
            case 0:
                
                title.text = @"电话";
                NSString *tel = [self.cardInfo objectAtIndex:card_info_tel];

                if (_isLogin == YES && [self.userId intValue] != 0)
                {
                    UIImage *callImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
                    callImageView.image = callImage;
                    [callImage release];
                    callImageView.hidden = NO;
                    
                    if (tel.length != 0) {
                        if ([[tel substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
                            if (tel.length == 11) {
                                titleInfo.text = [NSString stringWithFormat:@"%@-%@-%@",[tel substringWithRange:NSMakeRange(0, 3)],[tel substringWithRange:NSMakeRange(3, 4)],[tel substringWithRange:NSMakeRange(7, 4)]];
                            } else {
                                titleInfo.text = tel;
                            }
                            
                        } else {
                            titleInfo.text = tel;
                        }
                    } else {
                        titleInfo.text = @"－";
                    }
                }
                else 
                {
                    //号码需要替换一些xxxxx
                    if ([tel length] > 0) 
                    {
                        if ([tel length] > 7) 
                        {
                            titleInfo.text = [NSString stringWithFormat:@"%@",[tel substringWithRange:NSMakeRange(0, 3)]];
                            // dufu mod 2013.04.28
                            if ([[tel substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"]) {
                                UILabel *replaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 80, 20)];
                                replaceLabel.backgroundColor = [UIColor clearColor];
                                replaceLabel.font = [UIFont systemFontOfSize:20];
                                replaceLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                                replaceLabel.text = [NSString stringWithFormat:@"%@",@"-****-****"];
                                [titleInfo addSubview:replaceLabel];
                                [replaceLabel release];
                            } else {
                                UILabel *replaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 80, 20)];
                                replaceLabel.backgroundColor = [UIColor clearColor];
                                replaceLabel.font = [UIFont systemFontOfSize:20];
                                replaceLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                                replaceLabel.text = @"********";
                                [titleInfo addSubview:replaceLabel];
                                [replaceLabel release];
                            }
                        }
                        else
                        {
                            if ([tel length] > 3) 
                            {
                                NSString *string = @"*************";
                                NSString *replaceString = [string substringWithRange:NSMakeRange(0, ([tel length]-3))];
                                titleInfo.text = [tel substringWithRange:NSMakeRange(0, 3)];
                                
                                UILabel *replaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, 40, 20)];
                                replaceLabel.backgroundColor = [UIColor clearColor];
                                replaceLabel.font = [UIFont systemFontOfSize:20];
                                replaceLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                                replaceLabel.text = replaceString;
                                [titleInfo addSubview:replaceLabel];
                                [replaceLabel release];
                            }
                            else 
                            {
                                titleInfo.text = @"－";
                            }
                        }
                    }
                    else
                    {
                        titleInfo.text = @"－";
                    }
                }
                
                break;
                
            //邮箱
            case 1:
                
                // dufu mod 2013.04.28
                title.text = @"邮箱";
                NSString *email_text = [self.cardInfo objectAtIndex:card_info_email];

                if (_isLogin == YES && [self.userId intValue] != 0)
                {
                    UIImage *callImage1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员详情发送邮件" ofType:@"png"]];
                    callImageView.image = callImage1;
                    [callImage1 release];
                    callImageView.hidden = NO;
                    
                    if (email_text.length == 0) {
                        titleInfo.text = @"－";
                    } else {
                        titleInfo.text = email_text;
                    }
                } else {
                    if (email_text.length == 0) {
                        titleInfo.text = @"－";
                    } else {
                        NSRange range = [email_text rangeOfString:@"@"];
                        if (range.location != 0) {
                            UILabel *replaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 80, 20)];
                            replaceLabel.backgroundColor = [UIColor clearColor];
                            replaceLabel.font = [UIFont systemFontOfSize:20];
                            replaceLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                            replaceLabel.text = @"******";
                            [titleInfo addSubview:replaceLabel];
                            [replaceLabel release];
                            titleInfo.text = [NSString stringWithFormat:@"           %@",[email_text substringFromIndex:range.location]];
                        } else {
                            titleInfo.text = @"－";
                        }
                    }
                }
                break;
                
            //网址
            case 2:
                // dufu mod 2013.04.28
                title.text = @"微博";
                NSString *urlstr = [self.cardInfo objectAtIndex:card_info_url];
                
                if (_isLogin == YES && [self.userId intValue] != 0)
                {
                    UIImage *callImage1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_向右箭头" ofType:@"png"]];
                    callImageView.image = callImage1;
                    [callImage1 release];
                    callImageView.hidden = NO;
                    
                    if (urlstr.length == 0)
                    {
                        titleInfo.text = @"－";
                    } else {
                        titleInfo.text = urlstr;
                    }
                }
                else
                {
                    if (urlstr.length == 0)
                    {
                        titleInfo.text = @"－";
                    }
                    else
                    {
                        titleInfo.text = [NSString stringWithFormat:@"http://"];
                        UILabel *replaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(37, 5, 80, 20)];
                        replaceLabel.backgroundColor = [UIColor clearColor];
                        replaceLabel.font = [UIFont systemFontOfSize:20];
                        replaceLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
                        replaceLabel.text = @"********";
                        [titleInfo addSubview:replaceLabel];
                        [replaceLabel release];
                    }
                }
                
                break;
                
            //地址
            case 3:
                title.text = @"地址";
                titleInfo.numberOfLines = 2;
                [titleInfo setFrame:CGRectMake(60, 5, 200, 28)];
                titleInfo.font = [UIFont systemFontOfSize:12];
                titleInfo.text = [NSString stringWithFormat:@"%@%@%@%@",[self.cardInfo objectAtIndex:card_info_province],[self.cardInfo objectAtIndex:card_info_city],[self.cardInfo objectAtIndex:card_info_district],[self.cardInfo objectAtIndex:card_info_address]];
                if (titleInfo.text.length == 0) {
                    titleInfo.text = @"－";
                }
                break;
                
            default:   ;
        }
    }
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
	if (self.cardInfo != nil)
	{
        int row = [indexPath row];
        NSString *tel = [self.cardInfo objectAtIndex:card_info_tel];
        NSString *email = [self.cardInfo objectAtIndex:card_info_email];
        NSString *url = [self.cardInfo objectAtIndex:card_info_url];

        switch(row)
        {
            //电话
            case 0:
                
                //没有登陆 弹出提示
                if (_isLogin == YES && [self.userId intValue] != 0)
                {
                    if ([tel length] > 0) 
                    {
                        [callSystemApp makeCall:tel];
                    }
                }
                else
                {
                    [alertView showAlert:@"你还没有登录,请登陆后操作!"];
                }
                
                break;
                
            //邮箱
            case 1:
                
                //没有登陆 弹出提示
                if (_isLogin == YES && [self.userId intValue] != 0) 
                {
                    if ([email length] > 0) 
                    {
                        [callSystemApp sendEmail:email cc:@"" subject:@"" body:@""];
                    }
                }
                else
                {
                    [alertView showAlert:@"你还没有登录,请登陆后操作!"];
                }
                break;
                
            //网址
            case 2:
                if (_isLogin == YES && [self.userId intValue] != 0) {
                    if ([url length] > 0)
                    {
                        [self goUrl:url];
                    }
                } else {
                    [alertView showAlert:@"你还没有登录,请登陆后操作!"];
                }
                break;
                
            //地址
            case 3:
                
                //没有登陆 弹出提示
                /*
                 if (_isLogin == YES && [self.userId intValue] != 0) 
                 {
                 if ([address length] > 0) 
                 {
                 //跳转到地图
                 }
                 }
                 else
                 {
                 [alertView showAlert:@"你还没有登录,请登陆后操作!"];
                 }
                 */
                
                break;
                
            default:   ;
        }
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.delegate = nil;
    self.cardInfo = nil;
    self.cUserId = nil;
    self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.userId = nil;
    for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    self.spinner = nil;
}

- (void)dealloc 
{
    self.delegate = nil;
	self.cardInfo = nil;
    self.cUserId = nil;
    self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.userId = nil;
    self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    self.spinner = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
