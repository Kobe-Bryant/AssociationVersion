//
//  MessageViewController.m
//  xieHui
//
//  Created by 来 云 on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "imageDownLoadInWaitingObject.h"
#import "MessageTableViewCell.h"
#import "MessageDetailViewController.h"
#import "Encry.h"
#import "Common.h"
#import "DataManager.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "UIImageScale.h"
#import "MessageDetailViewController.h"
#import "SystemMessageViewController.h"

@interface MessageViewController ()

@end

@implementation MessageViewController
@synthesize messageTableView = _messageTableView;
@synthesize listArray = __listArray;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize iconDownLoad;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"消息中心";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //添加loading图标
    UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f - 40.0f) / 2.0)];
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
	
	[self accessService];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messageTableView = nil;
    self.listArray = nil;
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	imageDownloadsInProgressDic = nil;
	imageDownloadsInWaitingArray = nil;
	iconDownLoad = nil;
}

- (void)dealloc {
	[_messageTableView release];
	[__listArray release];
	[indicatorView release];
    for (IconDownLoader *one in [imageDownloadsInProgressDic allValues]){
		one.delegate = nil;
	}
	[imageDownloadsInProgressDic release];
	[imageDownloadsInWaitingArray release];
	[iconDownLoad release];
	[spinner release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
		return [self.listArray count];
	}else {
		return 0;
	}
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) {
		return 60.0f;
	}else {
		return 0;
	}	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 30)];
		moreLabel.text = @"显示更多";
		moreLabel.tag = 200;
		moreLabel.textColor = [UIColor blackColor];
		moreLabel.textAlignment = UITextAlignmentCenter;
		moreLabel.backgroundColor = [UIColor clearColor];
		[vv addSubview:moreLabel];
		[moreLabel release];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.backgroundColor = [UIColor clearColor];
		btn.frame = CGRectMake(0, 0, 320, 50);
		[btn addTarget:self action:@selector(getMoreAction) forControlEvents:UIControlEventTouchUpInside];
		[vv addSubview:btn];
		
		//添加loading图标
		indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
		[indicatorView setCenter:CGPointMake(320 / 3, 50 / 2.0)];
		indicatorView.hidesWhenStopped = YES;
		[vv addSubview:indicatorView];
		
		UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 49, 320, 1)];
		lab.backgroundColor = [UIColor grayColor];
		
		[vv addSubview:lab];
		[lab release];
		return vv;
	}else {
		return nil;		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 1 && self.listArray.count >= 20) {
		return 50;
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	//NSInteger row = [indexPath row];
	
	MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		cell.cName.text = @"";
		cell.cTime.text = @"";
		cell.cContent.text = @"";
        
    }
	//cell.backgroundColor = [UIColor colorWithRed:0.935 green:0.935 blue:0.935 alpha:1.0f];
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *cellArray = [self.listArray objectAtIndex:indexPath.row];
        cell.cName.text = [cellArray objectAtIndex:2];
        //cell.cTime.text = [cellArray objectAtIndex:4];
        cell.cContent.text = [cellArray objectAtIndex:3];
        
        int createTime = [[cellArray objectAtIndex:4] intValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
        [outputFormat setDateFormat:@"YYYY-MM-dd  HH:mm"];
        NSString *dateString = [outputFormat stringFromDate:date];
        cell.cTime.text = dateString;
        [outputFormat release];
        
        if (indexPath.row == 0 && [[cellArray objectAtIndex:0] intValue] == 0) {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_小秘书" ofType:@"png"]];
            cell.cImageView.image = [img fillSize:CGSizeMake(50, 50)];
        }else {
            NSString *imageUrl = [cellArray objectAtIndex:1];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[imageUrl dataUsingEncoding: NSUTF8StringEncoding]];
            UIImage *image = nil;
            if (picName.length > 1) {
                image = [FileManager getPhoto:picName];
            }
            UIImage *cardIcon = [image fillSize:CGSizeMake(50, 50)];
            if (cardIcon == nil)
            {
                UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认头像" ofType:@"png"]];
                cell.cImageView.image = [img fillSize:CGSizeMake(50, 50)];
                [self startIconDownload:imageUrl forIndex:indexPath];
            }
            else
            {
                cell.cImageView.image = cardIcon;
            }
        }
        
        int num = [[cellArray objectAtIndex:5] intValue];
        if (num > 0) {
            CGFloat fixWidth;
            if (num >= 100)
            {
                fixWidth = 34;
                if (num > 999)
                {
                    num = 999;
                }
            }
            else
            {
                fixWidth = 24;
            }
            
            UIImage *msgImg = [[UIImage imageNamed:@"小红点.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:24];
            UIImageView *msgImageView = [[UIImageView alloc] initWithImage:msgImg];
            msgImageView.frame = CGRectMake(60 - fixWidth + 5, 3, fixWidth, 24);
            msgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [cell addSubview:msgImageView];
            
            UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fixWidth, 24)];
            msgLabel.text = [NSString stringWithFormat:@"%d",num];
            msgLabel.textColor = [UIColor whiteColor];
            msgLabel.font = [UIFont systemFontOfSize:14.0f];
            msgLabel.textAlignment = UITextAlignmentCenter;
            msgLabel.backgroundColor = [UIColor clearColor];
            [msgImageView addSubview:msgLabel];
            [msgLabel release];
            [msgImageView release];
        }
    }
   
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ay = [self.listArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0 && [[ay objectAtIndex:0] intValue] == 0) {
        SystemMessageViewController *system = [[SystemMessageViewController alloc] init];
        [self.navigationController pushViewController:system animated:YES];
        [system release];
    }else {
        MessageDetailViewController *messageDetail = [[MessageDetailViewController alloc] init];
        messageDetail.sourceStr = [NSString stringWithFormat:@"%d",[[ay objectAtIndex:0] intValue]];
        messageDetail.sourceName = [NSString stringWithFormat:@"%@",[ay objectAtIndex:2]];
        messageDetail.sourceImage = [NSString stringWithFormat:@"%@",[ay objectAtIndex:1]];
        [self.navigationController pushViewController:messageDetail animated:YES];
        [messageDetail release];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    rowValue = indexPath.row;
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    NSString *_listId = [[self.listArray objectAtIndex:indexPath.row] objectAtIndex:0];
    
    NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        [NSNumber numberWithInt:1],@"type",
                                        _listId,@"info_id",nil];
    
    [[DataManager sharedManager] accessService:jsontestDic command:MESSAGE_LIST_DELETE_COMMAND_ID accessAdress:@"member/delmessage.do?param=%@" delegate:self withParam:jsontestDic];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ay = [self.listArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0 && [[ay objectAtIndex:0] intValue] == 0) {
        return nil;
    }else {
        return UITableViewCellEditingStyleDelete;
    }
} 

#pragma mark ---- loadImage Method
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
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
	MessageTableViewCell *cell = (MessageTableViewCell *)[self.messageTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
	
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0){ 			
			UIImage *photo = iconDownloader.cardIcon;
            NSArray *one = [self.listArray objectAtIndex:iconDownloader.indexPathInTableView.row];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[[one objectAtIndex:1] dataUsingEncoding: NSUTF8StringEncoding]];
            //保存缓存图片
            [FileManager savePhoto:picName withImage:photo];

			cell.cImageView.image = [photo fillSize:CGSizeMake(50, 50)];	
		}
		[imageDownloadsInProgressDic removeObjectForKey:indexPath];
		if ([imageDownloadsInWaitingArray count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaitingArray objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaitingArray removeObjectAtIndex:0];
		}		
    }
}

#pragma mark ----private methods
- (void)accessService
{
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"destination",
                                        [NSNumber numberWithInt:1],@"type",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MESSAGE_LIST_COMMAND_ID accessAdress:@"member/mperson.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)accessMoreService{
    //	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:supply_favorite_favoriteId] intValue];
    //	//NSLog(@"lastId====%d",lastId);
    //	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    //	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
    //										[Common getSecureString],@"keyvalue",
    //										[NSNumber numberWithInt:-1],@"ver",
    //										[NSNumber numberWithInt: SITE_ID],@"site_id",
    //										[NSNumber numberWithInt:_userId],@"user_id",
    //										[NSNumber numberWithInt:2],@"type",
    //										[NSNumber numberWithInt:lastId],@"favorite_id",nil];
    //	
    //	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID accessAdress:@"member/favoritelist.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)getMoreAction
{
	UILabel *label = (UILabel*)[self.messageTableView viewWithTag:200];
	label.text = @"正在加载...";	
	
	[indicatorView startAnimating];
	
	//_isLoadMore = YES;
	[self accessMoreService];
	
}


- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	//NSLog(@"=====%@",resultArray);
	switch (commandid) {
		case MESSAGE_LIST_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
		}
			break;
		case MESSAGE_LIST_DELETE_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(deleteResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
//		case MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID:
//		{
//			[self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
//		}
//			break;
		default:
			break;
	}
}

- (void)update:(NSMutableArray *)resultArray
{
    //移出loading
    [self.spinner removeFromSuperview];
    
    [self.listArray removeAllObjects];
	self.listArray = resultArray;
    //NSLog(@"self.listArray========%@",self.listArray);
	if ([self.listArray count] == 0) {
		self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = @"还没有人给您留言哦!";;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:14.0f];
		[self.view addSubview:label];
		[label release];
	}else {
        [self.messageTableView removeFromSuperview];
        _messageTableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44) style:UITableViewStylePlain];
        _messageTableView.delegate = self;
        _messageTableView.dataSource = self;
        [_messageTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_messageTableView setBackgroundColor:[UIColor clearColor]];
        _messageTableView.backgroundView = nil;
        [self.view addSubview:_messageTableView];
    }
	
	[self.messageTableView reloadData];
	
}

- (void)deleteResult:(NSMutableArray *)resultArray
{
    int retInt = [[resultArray objectAtIndex:0] intValue];
    if (retInt == 1) {
        [self.listArray removeObjectAtIndex:rowValue];

        NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:rowValue inSection:0];
        [deleteIndexPaths addObject:newPath];
        [self.messageTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [deleteIndexPaths release];
    
        if ([self.listArray count] == 0) {
            self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            label.text = @"还没有人给您留言哦!";
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            label.textAlignment = UITextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:18.0f];
            [self.view addSubview:label];
            [label release];
        }
    }else {
        MBProgressHUD *mbprogressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        mbprogressHUD.delegate = self;
        mbprogressHUD.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
        mbprogressHUD.mode = MBProgressHUDModeCustomView; 
        mbprogressHUD.labelText = @"删除失败";
        [self.view addSubview:mbprogressHUD];
        [self.view bringSubviewToFront:mbprogressHUD];
        [mbprogressHUD show:YES];
        [mbprogressHUD hide:YES afterDelay:1];
        [mbprogressHUD release];
    }
}

- (void)getMoreResult:(NSMutableArray *)resultArray{
	UILabel *label = (UILabel*)[self.messageTableView viewWithTag:200];
	label.text = @"显示更多";	
	[indicatorView stopAnimating];
	
	for (int i = 0; i < [resultArray count];i++ ) 
	{
		NSMutableArray *item = [resultArray objectAtIndex:i];
		[item insertObject:@"" atIndex:0];
		[self.listArray addObject:item];
	}
	//NSLog(@"self.listArray========%@",self.listArray);
	//NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	[self.messageTableView reloadData];
	
}

@end
