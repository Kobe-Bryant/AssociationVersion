//
//  CommentViewController.m
//  Profession
//
//  Created by LuoHui on 12-10-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"
#import "Common.h"
#import "DataManager.h"


#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define USER_NAME_HEIGHT 30.0f

@interface CommentViewController ()

@end

@implementation CommentViewController
@synthesize myTableView = _myTableView;
@synthesize listArray = __listArray;
@synthesize _type;
@synthesize _infoId;
@synthesize tempTextContent;
@synthesize userId;
@synthesize infoTitle;
@synthesize button;
@synthesize isFromSuper;
@synthesize spinner;
@synthesize moreLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __listArray = [[NSMutableArray alloc] init];
        
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
	self.title = @"评论";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	progressHUD.labelText = LOADING_TIPS;
	[self.view addSubview:progressHUD];
	[self.view bringSubviewToFront:progressHUD];
	[progressHUD show:YES];
	
	[self accessService];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, VIEW_HEIGHT - 20.0f - 44.0f - 40.0f) style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.scrollEnabled = YES;
	[_myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_myTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_myTableView];
    
    [self addCommentView];
    
    if (_refreshHeaderView == nil) {		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
										   initWithFrame:CGRectMake(0.0f, 0.0f - _myTableView.bounds.size.height, self.view.frame.size.width, _myTableView.bounds.size.height)];
		view.delegate = self;
		[_myTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:YES];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_myTableView release];
    _myTableView = nil;
    [__listArray release];
    __listArray = nil;
    
    [_type release];
    _type = nil;
    [_infoId release];
    _infoId = nil;
    [infoTitle release];
    infoTitle = nil;
    [progressHUD release];
    progressHUD = nil;
    [containerView release];
    containerView = nil;
    [textView release];
    textView = nil;
    [tempTextContent release];
    tempTextContent = nil;
    [userId release];
    userId = nil;
    [_refreshHeaderView release];
	_refreshHeaderView = nil;
    [spinner release];
    spinner = nil;
    [moreLabel release];
    moreLabel = nil;
    [super dealloc];
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
        //return 20;
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) 
    {
		//return 80.0f;
        if (self.listArray != nil && [self.listArray count] > 0) {
            NSArray *commentArray = [self.listArray objectAtIndex:[indexPath row]];
			NSString *text = [commentArray objectAtIndex:comment_list_content];		
			CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);		
			CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];		
			//CGFloat height = MAX(size.height + USER_NAME_HEIGHT, 60.0f);
            CGFloat height = size.height;
			return height + 40;
        }
	}
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1)
    {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UILabel *tempMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 30)];
        tempMoreLabel.tag = 200;
        [tempMoreLabel setFont:[UIFont systemFontOfSize:14.0f]];
        tempMoreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
        tempMoreLabel.text = _loadingMore ? @"没有更多数据了" : @"上拉加载更多";
        tempMoreLabel.textAlignment = UITextAlignmentCenter;
        tempMoreLabel.backgroundColor = [UIColor clearColor];
        self.moreLabel = tempMoreLabel;
        [tempMoreLabel release];
		[vv addSubview:self.moreLabel];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.backgroundColor = [UIColor clearColor];
		btn.frame = CGRectMake(0, 0, 320, 50);
		[btn addTarget:self action:@selector(getMoreAction) forControlEvents:UIControlEventTouchUpInside];
		[vv addSubview:btn];
        
        //添加loading图标
        UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [tempSpinner setCenter:CGPointMake(vv.frame.size.width / 3, vv.frame.size.height / 2.0)];
        self.spinner = tempSpinner;
        [vv addSubview:self.spinner];
        [tempSpinner release];
        
		return vv;
        
	}
    else
    {
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
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
		//add name label
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, 0,  CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - 120 , USER_NAME_HEIGHT )];
        nameLabel.tag = 1003;
        [nameLabel setFont:[UIFont systemFontOfSize:12.0f]];
        nameLabel.text = @"";
        nameLabel.textColor = [UIColor colorWithRed:0.26 green: 0.35 blue: 0.46 alpha:1.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        [[cell contentView] addSubview:nameLabel];
        [nameLabel release];
        
        //add time Label
        //int offset = contentLabel.frame.size.height;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 20,0, 130 , USER_NAME_HEIGHT )];
        timeLabel.tag = 1005;
        [timeLabel setFont:[UIFont systemFontOfSize:10.0f]];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
        timeLabel.backgroundColor = [UIColor clearColor];
        [[cell contentView] addSubview:timeLabel];
        [timeLabel release];
        
        
        //add content label
        UILabel *contentLabel = nil;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.tag = 1004;
        [contentLabel setLineBreakMode:UILineBreakModeWordWrap];
        [contentLabel setMinimumFontSize:14];
        [contentLabel setNumberOfLines:0];
        [contentLabel setFont:[UIFont systemFontOfSize:14]];
        contentLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:contentLabel];
		
    }
	
	if (self.listArray != nil && indexPath.row < [self.listArray count]) {
		NSArray *cellArray = [self.listArray objectAtIndex:indexPath.row];
        
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1003];
        if(nameLabel != nil){
            nameLabel.text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:comment_list_userName]];
        }
        
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:1005];
        if (timeLabel != nil) {
            int createTime = [[cellArray objectAtIndex:comment_list_creatTime] intValue];
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
            NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
            [outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *dateString = [outputFormat stringFromDate:date];
            timeLabel.text = [NSString stringWithFormat:@"%@ 发表",dateString];
            [outputFormat release];
        }
        
        UILabel *content = (UILabel *)[cell.contentView viewWithTag:1004];
        NSString *text = [NSString stringWithFormat:@"%@",[cellArray objectAtIndex:comment_list_content]];
        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        float fixHeight = size.height;
        fixHeight = fixHeight == 0 ? 10.f : fixHeight;
        [content setFrame:CGRectMake(CELL_CONTENT_MARGIN, CGRectGetMaxY(nameLabel.frame), CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), fixHeight)];
        [content setText:text];
        
        //        UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
        //		UIImageView *separatorImageView = [[UIImageView alloc] init];
        //		[separatorImageView setFrame:CGRectMake(0, CGRectGetMaxY(content.frame) + 9, 320, separatorImage.size.height)];
        //		[separatorImageView setImage:separatorImage];
        //		[cell.contentView addSubview:separatorImageView];
        //		[separatorImageView release];
        //		[separatorImage release];
        
    }
	return cell;
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_myTableView];	
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self accessRefreshService];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            self.moreLabel.text=@"松开加载更多";
            
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];

    if (_isAllowLoadingMore && !_loadingMore)
    {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            [self getMoreAction];
        }
        else
        {
            self.moreLabel.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.listArray count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
    
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
    self.tempTextContent = textView.text;
    textView.text = @"说两句";
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
    textView.text = @"说两句";
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
        [textView becomeFirstResponder];
		
	}
    
}

#pragma mark ----private methods
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

- (void)accessService
{    
	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [Common getCommentListVersion:[_type intValue] withInfoID:[_infoId intValue]],@"ver",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:[_type intValue]],@"type",
                                        [NSNumber numberWithInt:[_infoId intValue]],@"info_id",
                                        [NSNumber numberWithInt:0],@"comment_id",
                                        [NSNumber numberWithInt:1],@"edition",
                                        nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:COMMENTLIST_COMMAND_ID accessAdress:@"comment/list.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)accessRefreshService
{
    if ([self.listArray count] == 0 || self.listArray == nil) {
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    }else {
        int newId = [[[self.listArray objectAtIndex:0] objectAtIndex:comment_list_commentId] intValue];
        //NSLog(@"newId===%d",newId);
        NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [Common getSecureString],@"keyvalue",
                                            [Common getCommentListVersion:[_type intValue] withInfoID:[_infoId intValue]],@"ver",
                                            [NSNumber numberWithInt: SITE_ID],@"site_id",
                                            [NSNumber numberWithInt:[_type intValue]],@"type",
                                            [NSNumber numberWithInt:[_infoId intValue]],@"info_id",
                                            [NSNumber numberWithInt:newId],@"comment_id",
                                            [NSNumber numberWithInt:1],@"edition",
                                            nil];
        
        [[DataManager sharedManager] accessService:jsontestDic command:COMMENTLIST_COMMAND_ID accessAdress:@"comment/list.do?param=%@" delegate:self withParam:jsontestDic];
        
    }
}
- (void)accessMoreService{
	int lastId = [[[self.listArray objectAtIndex:self.listArray.count - 1] objectAtIndex:comment_list_commentId] intValue];
    //NSLog(@"lastId===%d",lastId);
	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt:-1],@"ver",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:[_type intValue]],@"type",
                                        [NSNumber numberWithInt:[_infoId intValue]],@"info_id",
                                        [NSNumber numberWithInt:lastId],@"comment_id",
                                        [NSNumber numberWithInt:1],@"edition",
                                        nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:COMMENTLIST_MORE_COMMAND_ID accessAdress:@"comment/list.do?param=%@" delegate:self withParam:jsontestDic];
    
}

- (void)getMoreAction
{
    _loadingMore = YES;
    
	self.moreLabel.text=@" 加载中 ...";
	
    [self.spinner startAnimating];
    
	[self accessMoreService];
	
}


- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	//NSLog(@"=====%@",resultArray);
	switch (commandid) {
		case COMMENTLIST_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
		}
			break;
		case COMMENTLIST_MORE_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
        case ACCESS_COMMENT_NEWS_COMMAND_ID:
		{
			[self performSelectorOnMainThread:@selector(publishCommentResult:) withObject:resultArray waitUntilDone:NO];
		}
			break;
		default:
			break;
	}
}

- (void)update
{
	self.listArray = (NSMutableArray *)[DBOperate queryData:T_COMMENTLIST theColumn:@"typeId" equalValue:_type theColumn:@"infoId" equalValue:_infoId];
    
	//NSLog(@"self.listArray========%@",self.listArray);
	//NSLog(@"[self.listArray count]=====%d",[self.listArray count]);
	
	if ([self.listArray count] == 0) {
		self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		label.text = @"还没有人说什么哦，赶紧抢先第一个发言吧!";
        label.tag = 111;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor grayColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:12.0f];
		[self.myTableView addSubview:label];
		[label release];
	}else {
        UILabel *label = (UILabel *)[self.myTableView viewWithTag:111];
        [label removeFromSuperview];
        
        [_myTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
	[_myTableView reloadData];
	
	if (progressHUD != nil) {
		if (progressHUD) {
			[progressHUD removeFromSuperview];
		}
	}
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    //loading图标移除
    if (self.spinner != nil) {
        [self.spinner stopAnimating];
    }
    
    if ([resultArray count] > 0)
    {
        
        for (int i = 0; i < [resultArray count];i++ )
        {
            NSMutableArray *item = [resultArray objectAtIndex:i];
            [self.listArray addObject:item];
        }
        
        [self.myTableView reloadData];
        
        if ([resultArray count] >= 20)
        {
            _loadingMore = NO;
            
            if (self.moreLabel) {
                self.moreLabel.text = @"上拉加载更多";
            }
        }
        else
        {
            if (self.moreLabel) {
                self.moreLabel.text = @"没有更多数据了";
            }
        }
        
    }
    else
    {
        if (self.moreLabel) {
            self.moreLabel.text = @"没有更多数据了";
        }
    }
    
}

- (void)addCommentView
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_myTableView.frame), 320, 40)];
    
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
    textView.text = @"说两句";
    
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
    if ([memberArray count] > 0) 
    {
        self.userId = [[memberArray objectAtIndex:0] objectAtIndex:member_info_memberId];
    }
    
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
            progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
            progressHUD.labelText = @"发送中... ";
            [self.view addSubview:progressHUD];
            [self.view bringSubviewToFront:progressHUD];
            [progressHUD show:YES];
            
            NSString *reqUrl = @"comment/pro.do?param=%@";					
            NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [Common getSecureString],@"keyvalue",
                                         [NSNumber numberWithInt: SITE_ID],@"site_id",
                                         [NSString stringWithFormat:@"%@",self.userId],@"user_id",
                                         [NSString stringWithFormat:@"%@",_type],@"type",
                                         [NSString stringWithFormat:@"%@",_infoId],@"info_id",
                                         [NSString stringWithFormat:@"%@",self.infoTitle],@"title",
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
        [textView resignFirstResponder];
    }
    
}

- (void)publishCommentResult:(NSMutableArray *)resultArray
{
    NSString *ret = [resultArray objectAtIndex:0];
    if ([ret intValue] == 1) {
        if (progressHUD != nil) {
            //progressHUD.delegate = self;
            progressHUD.labelText = @"评论成功";
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            //[progressHUD hide:YES afterDelay:1.0f];
        }
        self.tempTextContent = @"";
        textView.text = @"说两句";
        textView.textColor = [UIColor grayColor]; 
        [self accessService];
    }else {
        if (progressHUD != nil) {
            progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
            progressHUD.mode = MBProgressHUDModeCustomView;
            progressHUD.labelText = @"发送失败";
            [progressHUD hide:YES afterDelay:1.0f];
        }
    }
    
    if (isFromSuper == YES) {
        NSString *commentNum = [resultArray objectAtIndex:1];
        [button setTitle:[NSString stringWithFormat:@"%@评论",commentNum]];
    }
}

#pragma mark ---MBProgressHUDDelegate method
//- (void)hudWasHidden:(MBProgressHUD *)hud{
//	[self.navigationController popViewControllerAnimated:YES];
//    //[self accessRefreshService];
//}
@end
