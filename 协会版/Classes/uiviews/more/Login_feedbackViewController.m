//
//  Login_feedbackViewController.m
//  xieHui
//
//  Created by LuoHui on 13-4-24.
//
//

#import "Login_feedbackViewController.h"
#import "Common.h"
#import "DataManager.h"
#import "FileManager.h"
#import "Encry.h"
#import "Common.h"
#import "downloadParam.h"
#import "UIImageScale.h"
#import "imageDownLoadInWaitingObject.h"
#import "MessageInforViewController.h"
#import "FileManager.h"
#import <QuartzCore/QuartzCore.h>
#import "browserViewController.h"
@interface Login_feedbackViewController ()

@end

@implementation Login_feedbackViewController
@synthesize tableView = _tableView;
@synthesize listArray = __listArray;
@synthesize sourceStr;
@synthesize sourceName;
@synthesize sourceImage;
@synthesize imageDownloadsInProgressDic;
@synthesize imageDownloadsInWaitingArray;
@synthesize iconDownLoad;
@synthesize cardCard;
@synthesize tempTextContent;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"留言反馈";
    
//    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgressDic = idip;
	[idip release];
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaitingArray = wait;
	[wait release];
    
    [self accessService];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, VIEW_HEIGHT - 20.0f - 44.0f - 40.0f) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = YES;
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_tableView];
    
    [self addCommentView];
    
    //下拉刷新控件
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]
										   initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
    _isLoadMore = NO;
}

- (void)dealloc
{
    [__listArray release];
    [sourceStr release];
    [sourceName release];
    [sourceImage release];
    [progressHUD release];
    
    [imageDownloadsInProgressDic release];
	[imageDownloadsInWaitingArray release];
	[iconDownLoad release];
    [cardCard release];
    [tempTextContent release];
    [indicatorView release];
    [_refreshHeaderView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    __listArray = nil;
    sourceStr = nil;
    sourceName = nil;
    sourceImage = nil;
    progressHUD = nil;
    
    imageDownloadsInProgressDic = nil;
	imageDownloadsInWaitingArray = nil;
	iconDownLoad = nil;
    cardCard = nil;
    tempTextContent = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self accessMoreService];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
		return [self.listArray count];
        //return 20;
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) {
		//return 80.0f;
        if (self.listArray != nil && [self.listArray count] > 0) {
            NSArray *commentArray = [self.listArray objectAtIndex:[indexPath row]];
			NSString *text = [commentArray objectAtIndex:2];
			float length = text.length * 20;
            float width = length > 200 ? 200 : length;
            CGSize titleSize = [text sizeWithFont:[UIFont systemFontOfSize:16]
                                constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                    lineBreakMode:UILineBreakModeWordWrap];
            //20为气泡上下间隔,50为头像高度 30为时间高度
            CGFloat height = (titleSize.height + 20) > 50 ? titleSize.height + 20 : 50;
			return height + 10;
        }else {
            return 0;
        }
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell = nil;
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] init];
        view.tag = 'v';
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 'i';
        [view addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectZero;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 'l';
        label.textAlignment = UITextAlignmentLeft;
        [view addSubview:label];
        [label release];
        
        [cell.contentView addSubview:view];
        [view release];
        
//        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
//        timeLabel.text = @"";
//        timeLabel.textColor = [UIColor grayColor];
//        timeLabel.tag = 1;
//        timeLabel.font = [UIFont systemFontOfSize:14.0f];
//        timeLabel.textAlignment = UITextAlignmentCenter;
//        timeLabel.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:timeLabel];
//        [timeLabel release];
    }
    
    if (self.listArray != nil && [self.listArray count] > 0)
    {
//        UILabel *time = (UILabel *)[cell.contentView viewWithTag:1];
//        int createTime = [[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:3] intValue];
//        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
//        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
//        [outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
//        NSString *dateString = [outputFormat stringFromDate:date];
//        time.text = dateString;
//        [outputFormat release];
        
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:'l'];
        label.text = [NSString stringWithFormat:@"%@",[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:2]];
        float length = label.text.length * 20;
        float width = length > 200 ? 200 : length;
        CGSize titleSize = [label.text sizeWithFont:[UIFont systemFontOfSize:16]
                                  constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                      lineBreakMode:UILineBreakModeWordWrap];
        
        UIView *view = (UIView *)[cell.contentView viewWithTag:'v'];
        
        int senderId = [[[self.listArray objectAtIndex:[indexPath row]] objectAtIndex:1] intValue];
        if (senderId == 0)
        {
            view.frame = CGRectMake(70, 10,  titleSize.width+20, titleSize.height+10);
            
            UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            headerImageView.tag = 'a';
            [cell.contentView addSubview:headerImageView];
            headerImageView.layer.masksToBounds = YES;
            headerImageView.layer.cornerRadius = 6;
            
            UIImage *headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_小秘书" ofType:@"png"]];
            headerImageView.image = headerImage;
            
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            button.frame = CGRectMake(10, 30, 50, 50);
//            [button addTarget:self action:@selector(iconButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:button];
            
//            NSString *picName = [Common encodeBase64:(NSMutableData *)[sourceImage dataUsingEncoding: NSUTF8StringEncoding]];
//            UIImage *image = nil;
//            if (picName.length > 1) {
//                image = [FileManager getPhoto:picName];
//            }
//            UIImage *cardIcon = [image fillSize:CGSizeMake(50, 50)];
//            if (cardIcon == nil)
//            {
//                UIImage *headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认头像" ofType:@"png"]];
//                headerImageView.image = [headerImage fillSize:CGSizeMake(50, 50)];
//                [self startIconDownload:sourceImage forIndex:indexPath];
//            }
//            else
//            {
//                headerImageView.image = cardIcon;
//            }
            
            label.frame = CGRectMake(15, 10, titleSize.width, titleSize.height);
        }
        else
        {
            UIImage *headerImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认头像" ofType:@"png"]];
            UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320-60, 10, 50, 50)];
            [cell.contentView addSubview:headerImageView];
            headerImageView.image = [headerImage fillSize:CGSizeMake(50, 50)];
            headerImageView.layer.masksToBounds = YES;
            headerImageView.layer.cornerRadius = 6;
            
            view.frame = CGRectMake(320-70-titleSize.width - 20, 10,  titleSize.width+20, titleSize.height+50);
            
            NSString *piclink = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_image];
            NSString *photoname = [Common encodeBase64:(NSMutableData *)[piclink dataUsingEncoding: NSUTF8StringEncoding]];
            UIImage *img = [FileManager getPhoto:photoname];
            if (img != nil) {
                
                headerImageView.image = [img fillSize:CGSizeMake(50, 50)];
            }
            
            label.frame = CGRectMake(10, 10, titleSize.width, titleSize.height);
        }
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:'i'];
        UIImage *balloonImg = nil;
        if (senderId == 0)
        {
            balloonImg = [UIImage imageNamed:@"balloon_l.png"];
        }
        else
        {
            balloonImg = [UIImage imageNamed:@"balloon_r.png"];
        }
        
        balloonImg = [balloonImg stretchableImageWithLeftCapWidth:10 topCapHeight:25];
        imgView.frame = CGRectMake(0, 0, titleSize.width+25, titleSize.height+20);
        imgView.image = balloonImg;
        
    }
    return cell;
}

//ios7去掉cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
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
	
    UIButton *bgBtn = (UIButton *)[self.view viewWithTag:2005];
    if (bgBtn != nil) {
        [bgBtn removeFromSuperview];
    }
	//新增一个遮罩按钮
	UIButton *backGrougBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	backGrougBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (keyboardBounds.size.height + containerFrame.size.height) - 20);
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
    
    self.tableView.frame = CGRectMake(0, 0, 320, 371);
    
	// commit animations
	[UIView commitAnimations];
    
    //改变tableView的大小以及位置
    [self performSelector:@selector(setTableViewSizeAndOrigin) withObject:nil afterDelay:[duration doubleValue]];
	
	//更改按钮状态
	[self buttonChange:YES];
	
}

-(void) keyboardWillHide:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    self.tableView.frame = CGRectMake(0, 0 - keyboardBounds.size.height, 320, 124);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    self.tableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 40.0f);
    
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
	self.tempTextContent = textView.text;
	textView.text = @"填写您的建议或问题";
	textView.textColor = [UIColor grayColor];
	[textView resignFirstResponder];
}
#pragma mark 改变键盘按钮
-(void)buttonChange:(BOOL)isKeyboardShow
{
	//判断软键盘显示
	if (isKeyboardShow)
	{
        UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
        
        //缩小输入框
        if (sendBtn.hidden)
        {
            UIImageView *entryImageView = (UIImageView *)[containerView viewWithTag:2000];
            CGRect entryFrame = entryImageView.frame;
            entryFrame.size.width -= 50.0f;
            
            CGRect textFrame = textView.frame;
            textFrame.size.width -= 50.0f;
            
            entryImageView.frame = entryFrame;
            textView.frame = textFrame;
        }
		
		//显示字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = NO;
		
		//显示发送按钮
		sendBtn.hidden = NO;
        
	}
	else
	{
		//拉长输入框
        //隐藏字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = YES;
		
		//隐藏发送按钮
		UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
		sendBtn.hidden = YES;
        
		UIImageView *entryImageView = (UIImageView *)[containerView viewWithTag:2000];
		CGRect entryFrame = entryImageView.frame;
		entryFrame.size.width += 50.0f;
		
		CGRect textFrame = textView.frame;
		textFrame.size.width += 50.0f;
		
		entryImageView.frame = entryFrame;
		textView.frame = textFrame;
		
	}
    
}

#pragma mark 点击监听
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//输入内容 存起来
	self.tempTextContent = textView.text;
	textView.text = @"填写您的建议或问题";
	textView.textColor = [UIColor grayColor];
    
	[textView resignFirstResponder];
}

#pragma mark -----HPGrowingTextViewDelegate methods
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
        return YES;
	}
	else
	{
		LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
		[self.navigationController pushViewController:login animated:YES];
		[login release];
		return NO;
	}
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
	if([growingTextView.text isEqualToString:@"填写您的建议或问题"])
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

#pragma mark-----LoginViewDelegate method
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    
}

#pragma mark ----private methods
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

- (void)accessService
{
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
    
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:FEEDBACK_LIST_COMMAND_ID accessAdress:@"more/feedbackList.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	switch (commandid) {
		case FEEDBACK_LIST_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
            
		}break;
        case OPERAT_SEND_FEEDBACK:
		{
            [self performSelectorOnMainThread:@selector(messageSendResult:) withObject:resultArray waitUntilDone:NO];
		}break;
        case FEEDBACK_LIST_MORE_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}break;
            
		default:
			break;
	}
}

- (void)update:(NSMutableArray *)resultArray
{
    //移出loading
    [self.spinner removeFromSuperview];
    
    //NSLog(@"resultArray === %@",resultArray);
    self.listArray = resultArray;
    if ([resultArray count] <= 20) {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],@"欢迎您和客服小秘书联系。如果您在使用中有任何建议或问题，记得给我留言反馈哦！",[NSNumber numberWithInt:0], nil];
        [self.listArray insertObject:arr atIndex:0];
    }
    
	if ([self.listArray count] == 0) {
//		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.tableView.scrollEnabled = NO;
//		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//		label.text = @"您还未跟TA打过招呼哦，快招呼一声！";
//        label.tag = 11;
//		label.backgroundColor = [UIColor clearColor];
//		label.textColor = [UIColor grayColor];
//		label.textAlignment = UITextAlignmentCenter;
//		label.font = [UIFont systemFontOfSize:12.0f];
//		[self.view addSubview:label];
//		[label release];
	}else {
        self.tableView.scrollEnabled = YES;
        UILabel *label = (UILabel *)[self.view viewWithTag:11];
        if (label != nil) {
            [label removeFromSuperview];
        }
    }
    
    [self.tableView reloadData];
    
    //滚动到最后一行
    if ([self.listArray count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}


//- (void)iconButtonPressed:(id)sender
//{
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    if (!window)
//    {
//        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
//    }
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    array = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK theColumn:@"user_id" theColumnValue:sourceStr withAll:NO];
//    
//    NSMutableArray *cardInfo = nil;
//    if ([array count] > 0)
//    {
//        cardInfo = (NSMutableArray *)[array objectAtIndex:0];
//    }
//    alertCardViewController *alertCard = [[[alertCardViewController alloc] initWithFrame:window.bounds info:cardInfo userID:self.sourceStr] autorelease];
//    alertCard.delegate = self;
//    [window addSubview:alertCard];
//    [alertCard showFromPoint:[self.view center]];
//    self.cardCard = alertCard;
//    
//}

- (void)addCommentView
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 305, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	textView.returnKeyType = UIReturnKeyDone; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor grayColor];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = @"填写您的建议或问题";
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
	
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[[UIImageView alloc] initWithImage:entryBackground] autorelease];
    entryImageView.frame = CGRectMake(5, 0, 310, 40);
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
	[sendBtn addTarget:self action:@selector(publishComment:) forControlEvents:UIControlEventTouchUpInside];
	[sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
	[sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:sendBtn];
    
}

//发表评论
-(void)publishComment:(id)sender
{
    NSMutableArray *memberArray = (NSMutableArray *)[DBOperate queryData:T_MEMBER_INFO theColumn:@"" theColumnValue:@"" withAll:YES];
    int userId = [[[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
    NSString *content = textView.text;
    //NSLog(@"content===%@",content);
    //把回车 转化成 空格
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    if ([content length] > 0)
    {
        if ([content length] > 140)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"回复内容不能超过140个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 124)];
            progressHUD.labelText = @"发送中... ";
            [self.view addSubview:progressHUD];
            [self.view bringSubviewToFront:progressHUD];
            [progressHUD show:YES];
            
            NSString *reqUrl = @"more/feedbacks.do?param=%@";
            NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
										 [Common getSecureString],@"keyvalue",
										 [NSNumber numberWithInt: SITE_ID],@"site_id",
										 [NSNumber numberWithInt: userId],@"user_id",
										 content,@"content",nil];
			
			[[DataManager sharedManager] accessService:jsontestDic
											   command:OPERAT_SEND_FEEDBACK
										  accessAdress:reqUrl
											  delegate:self
											 withParam:nil];
        }
    }
    else
    {
        [self hiddenKeyboard];
    }
    _isLoadMore = YES;
}

- (void)messageSendResult:(NSMutableArray *)resultArray
{
    NSString *ret = [resultArray objectAtIndex:0];
    if ([ret intValue] == 1) {
        if (progressHUD != nil) {
            //progressHUD.delegate = self;
            progressHUD.labelText = @"发送成功";
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            [progressHUD hide:YES afterDelay:1.0f];
        }
        
        [self performSelector:@selector(appendTableWith:) withObject:textView.text afterDelay:1.0];
        
        //初始化
        tempTextContent = @"";
        textView.text = @"";
        
    }else {
        if (progressHUD != nil) {
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            progressHUD.labelText = @"发送失败";
            [progressHUD hide:YES afterDelay:1.0f];
        }
    }
}

- (void)appendTableWith:(NSString *)text
{
    //把回车 转化成 空格
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    self.tableView.scrollEnabled = YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:11];
    if (label != nil) {
        [label removeFromSuperview];
    }
    
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    NSString *userIdStr = [NSString stringWithFormat:@"%d",_userId];
    //填充数据
    int oldCount = [self.listArray count];
    NSMutableArray *infoList = [[NSMutableArray alloc]init];
    [infoList addObject:@"-1"];
    [infoList addObject:userIdStr];
    [infoList addObject:text];
    [infoList addObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
    [self.listArray addObject:infoList];
    [infoList release];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    NSIndexPath *insertNewPath = [NSIndexPath indexPathForRow:oldCount inSection:0];
    [insertIndexPaths addObject:insertNewPath];
    
    if ([self.listArray count] != 0 && [self.listArray count] != 1)
    {
        
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
        //滚动到最后一行
        if ([self.listArray count] > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
        }
        
        [self.tableView reloadRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)setTableViewSizeAndOrigin
{
    self.tableView.frame = CGRectMake(0, 0, 320, 124);
    
    //滚动到最后一行
    if ([self.listArray count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)accessMoreService{
    if ([self.listArray count] == 1) {
        //下拉缩回
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
    }else {
        int lastId = [[[self.listArray objectAtIndex:1] objectAtIndex:0] intValue];
        //NSLog(@"lastId===%d",lastId);
        int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
        NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [Common getSecureString],@"keyvalue",
                                            [NSNumber numberWithInt: SITE_ID],@"site_id",
                                            [NSNumber numberWithInt:_userId],@"user_id",
                                            [NSNumber numberWithInt:lastId],@"info_id",nil];
        
        [[DataManager sharedManager] accessService:jsontestDic command:FEEDBACK_LIST_MORE_COMMAND_ID accessAdress:@"more/feedbackList.do?param=%@" delegate:self withParam:jsontestDic];
    }
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    if ([resultArray count] > 0 && [resultArray count] <= 20)
    {
        int oldCount = [self.listArray count];
        
        //填充数组
        for (int i = [resultArray count]-1; i >= 0; i--)
        {
            NSMutableArray *item = [resultArray objectAtIndex:i];
            [self.listArray insertObject:item atIndex:1];
        }
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
        NSMutableArray *reloadIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
		for (int ind = 0; ind < [resultArray count]; ind++)
		{
			NSIndexPath *insertNewPath = [NSIndexPath indexPathForRow:(oldCount + ind) inSection:0];
			[insertIndexPaths insertObject:insertNewPath atIndex:0];
            
            NSIndexPath *reloadNewPath = [NSIndexPath indexPathForRow:ind inSection:0];
			[reloadIndexPaths insertObject:reloadNewPath atIndex:0];
		}
        
		[self.tableView insertRowsAtIndexPaths:insertIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadRowsAtIndexPaths:reloadIndexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    //下拉缩回
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
}


- (void)feedback
{
    [textView becomeFirstResponder];
}

- (void)favoriteLogin
{
    //    LoginViewController *login = [[LoginViewController alloc] init];
    //    login.delegate = self;
    //    [self.navigationController pushViewController:login animated:YES];
    //    [login release];
}

- (void)goUrl:(NSString *)url
{
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = url;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

@end
