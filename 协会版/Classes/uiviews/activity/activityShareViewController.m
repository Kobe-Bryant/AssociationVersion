//
//  activityShareViewController.m
//  xieHui
//
//  Created by yunlai on 13-5-3.
//
//

#import "activityShareViewController.h"
#import "activityShareView.h"
#import "DBOperate.h"
#import "Common.h"
#import "alertView.h"
#import "WeiboShare.h"
#import "JSONKit.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import <QuartzCore/QuartzCore.h>

#define ToolViewHeight      50.f
#define ActivityViewSpace   10.f
#define ImageViewWidth      70.f

// weibo识别枚举
typedef enum
{
    WeiBoSINA,          // 新浪
    WeiBoTENCENT,       // 腾讯
    WeiBoMax
}WeiBoEnum;

@interface activityShareViewController ()
{
    CGFloat width;
    CGFloat height;
    CGFloat autoheight;
    NSInteger shareFlag;
    int ID;
    NSString *url;
    NSString *lessen_url;
    BOOL flag;
}

@property (retain, nonatomic) activityShareView *sinaView;
@property (retain, nonatomic) activityShareView *tenView;
@property (retain, nonatomic) MBProgressHUD *progressHUD;
@property (retain, nonatomic) UILabel *alabel;

- (void)leftAction:(id)sender;
- (void)rightAction:(id)sender;
- (void)willShowKeyboad:(NSNotification *)nc;
- (void)willHideKeyboad:(NSNotification *)nc;

- (void)setAutoViewFrame:(CGFloat)aheight;

- (BOOL)weiboJudge:(NSInteger)weiboFlag;
- (BOOL)weiboSinaActivity;
- (BOOL)weiboTencentActivity;

@end

@implementation activityShareViewController

@synthesize autoView = _autoView;
@synthesize textBackgroundView = _textBackgroundView;
@synthesize textViewC = _textViewC;
@synthesize imageView = _imageView;
@synthesize toolView = _toolView;

@synthesize sinaView;
@synthesize tenView;
@synthesize progressHUD;
@synthesize alabel;

@synthesize shareImage;
@synthesize info_id;
@synthesize user_id;
@synthesize upload;
@synthesize tableFlag;

// textBackgroundView 加载
- (void)textBackgroundViewLoad
{
    // textView的宽度
    CGFloat textViewWidth = _textBackgroundView.bounds.size.width - ActivityViewSpace;
    // textView的高度
    CGFloat textViewHeight = _textBackgroundView.bounds.size.height - 2*ActivityViewSpace;
    
    NSLog(@"textViewHeight = %f",textViewHeight);
    CGFloat imgwidth;

    if ([UIScreen mainScreen].applicationFrame.size.height > 500) {
        if (self.shareImage.size.width > self.shareImage.size.height) {
            //textViewHeight = 74.f;
            //imgwidth = self.shareImage.size.width*((textViewHeight/4)/self.shareImage.size.height);
            imgwidth = 111.f;
            _imageView.frame = CGRectMake(textViewWidth - imgwidth, ActivityViewSpace, imgwidth, 74.f);
        } else {
            //imgwidth = self.shareImage.size.width*((textViewHeight/2)/self.shareImage.size.height);
            imgwidth = 74.f;
            _imageView.frame = CGRectMake(textViewWidth - imgwidth, ActivityViewSpace, imgwidth, 110.f);
        }
        NSLog(@"imgwidth = %f",imgwidth);
    } else {
        if (self.shareImage.size.width > self.shareImage.size.height) {
            textViewHeight = 74;
            imgwidth = self.shareImage.size.width*(textViewHeight/self.shareImage.size.height);
            _imageView.frame = CGRectMake(textViewWidth - imgwidth, ActivityViewSpace, imgwidth, textViewHeight);
        } else {
            imgwidth = self.shareImage.size.width*(textViewHeight/self.shareImage.size.height);
            _imageView.frame = CGRectMake(textViewWidth - imgwidth, ActivityViewSpace, imgwidth, textViewHeight);
        }
        NSLog(@"imgwidth = %f",imgwidth);
    }
    
    _textViewC.frame = CGRectMake(0.f, 0.f, textViewWidth - imgwidth, textViewHeight);
}

// 分享栏加载
- (void)toolViewLoad
{
    // 分享到
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ActivityViewSpace, ActivityViewSpace, 7*ActivityViewSpace, 3*ActivityViewSpace)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"分享到", nil);
    [_toolView addSubview:label];
    [label release], label = nil;
    
    // 分享微博图标
    sinaView = [[activityShareView alloc]initWithFrame:CGRectMake(7*ActivityViewSpace, ActivityViewSpace/2, 4*ActivityViewSpace, 4*ActivityViewSpace) nonepath:[[NSBundle mainBundle] pathForResource:@"icon_分享_sina" ofType:@"png"] selectpath:[[NSBundle mainBundle] pathForResource:@"icon_分享_sina_selected" ofType:@"png"]];
    [sinaView setDelegateObject:self setBackFunctionName:@"weiboSinaActivity"];
    if ([self weiboJudge:WeiBoSINA]) {
        if (sinaView.selectIndex != 1) {
            sinaView.selectIndex = 2;
        } 
    }
    [_toolView addSubview:sinaView];
    
    tenView = [[activityShareView alloc]initWithFrame:CGRectMake(11*ActivityViewSpace + ActivityViewSpace/2, ActivityViewSpace/2, 4*ActivityViewSpace, 4*ActivityViewSpace) nonepath:[[NSBundle mainBundle] pathForResource:@"icon_分享_tx" ofType:@"png"] selectpath:[[NSBundle mainBundle] pathForResource:@"icon_分享_tx_selected" ofType:@"png"]];
    [tenView setDelegateObject:self setBackFunctionName:@"weiboTencentActivity"];
    if ([self weiboJudge:WeiBoTENCENT]) {
        if (tenView.selectIndex != 1) {
            tenView.selectIndex = 2;
        } 
    }
    [_toolView addSubview:tenView];
    
    alabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60.f, ActivityViewSpace, 60.f, 3*ActivityViewSpace)];
    alabel.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.f];
    alabel.font = [UIFont systemFontOfSize:12];
    [_toolView addSubview:alabel];
    
}

// autoView 自动加载
- (void)autoViewLoad
{
    _textBackgroundView.frame = CGRectMake(ActivityViewSpace, ActivityViewSpace, width - 2*ActivityViewSpace, _autoView.frame.size.height - ToolViewHeight - 2*ActivityViewSpace);
    
    [self textBackgroundViewLoad];
    
    _toolView.frame = CGRectMake(0.f, _autoView.frame.size.height - ToolViewHeight, width, ToolViewHeight);
    
    //[self toolViewLoad];
}

// 视图加载
- (void)viewLoad
{
    // 导航左按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
    [leftButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"返回按钮" ofType:@"png"]] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    [leftBarButton release];
    
    // 导航右按钮
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"发送", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    
    width = [UIScreen mainScreen].applicationFrame.size.width;
    height = [UIScreen mainScreen].applicationFrame.size.height;
    autoheight = height - 44.f - 216.f;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.f];
    
    // 自动适配view
    _autoView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, width, autoheight)];
    _autoView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.f];
    [self.view addSubview:_autoView];
    
    // text背景
    _textBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    _textBackgroundView.backgroundColor = [UIColor whiteColor];
    [_autoView addSubview:_textBackgroundView];
    
    // textView
    _textViewC = [[UITextView alloc]initWithFrame:CGRectZero];
    _textViewC.textColor = [UIColor blackColor];
    _textViewC.backgroundColor = [UIColor whiteColor];
    _textViewC.font = [UIFont systemFontOfSize:17.f];
    _textViewC.text = NSLocalizedString(@"我在现场", nil);
    _textViewC.returnKeyType = UIReturnKeyDefault;
    _textViewC.keyboardType = UIKeyboardTypeDefault;
    _textViewC.scrollEnabled = YES;
    _textViewC.delegate = self;
    _textViewC.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_textBackgroundView addSubview:_textViewC];
    
    // imageView
    _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _imageView.image = self.shareImage;//[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"微博分享图片背景" ofType:@"png"]];
    [_textBackgroundView addSubview:_imageView];
    
    // 分享栏
    _toolView = [[UIView alloc]initWithFrame:CGRectZero];
    _toolView.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.f];
    [_autoView addSubview:_toolView];
    
    // 分享栏load
    [self toolViewLoad];
    
    // 微博分享加载视图
    progressHUD = [[MBProgressHUD alloc] initWithView:_autoView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self viewLoad];
    
    ID = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboad:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboad:) name:UIKeyboardDidHideNotification object:nil];
    
    [self addObserver:self forKeyPath:@"_autoView.frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_textViewC becomeFirstResponder];
    
    self.navigationItem.title = NSLocalizedString(@"分享", nil);
}

// 网络请求
- (void)accessService
{
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:user_id],@"user_id",
                                        [NSNumber numberWithInt:info_id],@"info_id",
                                        _textViewC.text,@"desc",
                                        nil];
    
    NSString *reqstr = [Common TransformJson:jsontestDic withLinkStr: [ACCESS_SERVER_LINK stringByAppendingString:@"uploadactivityimage.do?param=%@"]];
    NSData *pictureData = UIImagePNGRepresentation(self.shareImage);
    upload = [[EPUploader alloc] initWithURL:[NSURL URLWithString:reqstr] filePath:pictureData delegate:self doneSelector:@selector(onUploadDone:) errorSelector:@selector(onUploadError:)];
    upload.uploaderDelegate = self;
}

// 左导航栏按钮
- (void)leftAction:(id)sender
{
    if ([_textViewC isFirstResponder]) {
        [_textViewC resignFirstResponder];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 右导航栏按钮
- (void)rightAction:(id)sender
{
    if (flag) {
        return;
    }
    
    flag = YES;
    
    if ([_textViewC.text length] >= 140) {
        [alertView showAlert:@"内容不能超过140个字"];
    } else {
        progressHUD.delegate = self;
        progressHUD.labelText = @"分享中，耐心一下...";
        [self.view addSubview:progressHUD];
        [self.view bringSubviewToFront:progressHUD];
        [progressHUD show:YES];
        
        [self performSelector:@selector(accessService)];
    }
}

// 键盘将要显示
- (void)willShowKeyboad:(NSNotification *)nc
{
    NSDictionary *info = [nc userInfo];
    // 键盘高度
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    [self setAutoViewFrame:keyboardSize.height];
}

// 键盘隐藏
- (void)willHideKeyboad:(NSNotification *)nc
{}

// 设置autoview的frame
- (void)setAutoViewFrame:(CGFloat)aheight
{
    CGRect autoframe = _autoView.frame;
    autoframe.size.height = height - 44.f - aheight;
    _autoView.frame = autoframe;
}

// 微博判断
- (BOOL)weiboJudge:(NSInteger)weiboFlag
{
    NSArray *weiboArray;
    
    if (weiboFlag == WeiBoSINA) {
        weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType"
                           theColumnValue:SINA withAll:NO];
    } else if (weiboFlag == WeiBoTENCENT) {
        weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType"
                           theColumnValue:TENCENT withAll:NO];
    }
    
    if (weiboArray != nil && [weiboArray count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

// 新浪微博
- (BOOL)weiboSinaActivity
{
    if (flag) {
        return NO;
    }
    
    if (sinaView.selectIndex == 1 || sinaView.selectIndex == 2) {
        return YES;
    } else {
        SinaViewController *sc = [[SinaViewController alloc] init];
        sc.delegate = self;
        [self.navigationController pushViewController:sc animated:YES];
        [sc release];
    }
    return NO;
}

// 腾讯微博
- (BOOL)weiboTencentActivity
{
    if (flag) {
        return NO;
    }
    
    if (tenView.selectIndex == 1 || tenView.selectIndex == 2) {
        return YES;
    } else {
        TencentViewController *tc = [[TencentViewController alloc] init];
        tc.delegate = self;
        [self.navigationController pushViewController:tc animated:YES];
        [tc release];
    }
    return NO;
}

#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if (flag) {
        return NO;
    }
    
    if (textView.text.length >= 140) {
        alabel.textColor = [UIColor redColor];
    } else {
        alabel.textColor = [UIColor blackColor];
    }
    
    alabel.text = [NSString stringWithFormat:@"%d/140",140 - textView.text.length];
    
    return YES;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"_autoView.frame"])
    {
        [self autoViewLoad];
    }
}

#pragma mark - OauthSinaWeiSuccessDelegate
- (void)oauthSinaSuccess   // 新浪微博回调
{
    sinaView.selectIndex = 2;
}

#pragma mark - OauthTencentWeiSuccessDelegate
- (void)oauthTencentSuccess  // 腾讯微博回调
{
    tenView.selectIndex = 2;
}

#pragma mark - MBProgressHUD
- (void)hudWasHidden:(MBProgressHUD *)hud {
	if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
	}
    flag = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:ID],@"id",
                          url,@"url",
                          lessen_url,@"lessen_url",
                          _textViewC.text,@"desc", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishUploadImage" object:dict];
	[self.navigationController popViewControllerAnimated:NO];
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atstr:(NSString*)str
{
    NSString *picName = [Common encodeBase64:(NSMutableData *)[str dataUsingEncoding: NSUTF8StringEncoding]];
    
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

// 插入到活动用户表中
- (void)insertActivityUserTable:(NSDictionary *)dict
{
    NSMutableArray *userPic = [[NSMutableArray alloc] init];
    [userPic addObject:[NSNumber numberWithInt:ID]];
    [userPic addObject:[NSNumber numberWithInt:info_id]];
    [userPic addObject:[dict objectForKey:@"url"]];
    [userPic addObject:[dict objectForKey:@"lessen_url"]];
    [userPic addObject:_textViewC.text];
    [DBOperate insertDataWithnotAutoID:userPic tableName:T_ACTIVITY_USER_PIC];
    [userPic release];
    
    //保证数据只有6条
	NSMutableArray *activityPicItems = [DBOperate queryData:T_ACTIVITY_USER_PIC
                                                  theColumn:@"activity_id" theColumnValue:[NSString stringWithFormat:@"%d",info_id] orderBy:@"id" orderType:@"desc" withAll:NO];
	
	for (int i = [activityPicItems count] - 1; i > 5; i--)
	{
		NSArray *activityPicArray = [activityPicItems objectAtIndex:i];
		NSString *activityPicId = [activityPicArray objectAtIndex:activity_user_pic_id];
        
        //删除对应用户上传的图片记录
		[DBOperate deleteData:T_ACTIVITY_USER_PIC
				  tableColumn:@"id"
				  columnValue:activityPicId];
	}
}

// 插入到历史活动用户表中
- (void)insertActivityHistoryUserTable:(NSDictionary *)dict
{
    NSMutableArray *userPic = [[NSMutableArray alloc] init];
    [userPic addObject:[NSNumber numberWithInt:ID]];
    [userPic addObject:[NSNumber numberWithInt:info_id]];
    [userPic addObject:[dict objectForKey:@"url"]];
    [userPic addObject:[dict objectForKey:@"lessen_url"]];
    [userPic addObject:_textViewC.text];
    [DBOperate insertDataWithnotAutoID:userPic tableName:T_ACTIVITY_HISTORY_USER_PIC];
    [userPic release];
    
    //保证数据只有6条
	NSMutableArray *activityPicItems = [DBOperate queryData:T_ACTIVITY_HISTORY_USER_PIC
                                                  theColumn:@"activity_id" theColumnValue:[NSString stringWithFormat:@"%d",info_id] orderBy:@"id" orderType:@"desc" withAll:NO];
	
	for (int i = [activityPicItems count] - 1; i > 5; i--)
	{
		NSArray *activityPicArray = [activityPicItems objectAtIndex:i];
		NSString *activityPicId = [activityPicArray objectAtIndex:activity_user_pic_id];
        
        //删除对应用户上传的图片记录
		[DBOperate deleteData:T_ACTIVITY_HISTORY_USER_PIC
				  tableColumn:@"id"
				  columnValue:activityPicId];
	}
}

// 判断历史表中有没有这个值
- (BOOL)ishaveInfoID
{
    NSArray *array = [DBOperate queryData:T_ACTIVITY_HISTORY
                                theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",info_id] orderBy:@"id" orderType:@"desc" withAll:NO];
    NSLog(@"array = %@",array);
    if (array.count == 0 || array == nil) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - EPUploaderDelegate
- (void)receiveResult:(NSString *)result
{
    NSDictionary *dict = [result objectFromJSONString];
    
    NSLog(@"dict====%@",dict);
    
    if ([[dict objectForKey:@"ret"] intValue] == 1) {
        
        [self savePhoto:self.shareImage
                  atstr:[dict objectForKey:@"url"]];

        [self savePhoto:[self.shareImage fillSize:CGSizeMake(75.f, 75.f)]
                  atstr:[dict objectForKey:@"lessen_url"]];
        
        ID = [[dict objectForKey:@"id"] intValue];
        [url release];
        url = [[dict objectForKey:@"url"] retain];
        [lessen_url release];
        lessen_url = [[dict objectForKey:@"lessen_url"] retain];
        
        if (tableFlag) {
            [self insertActivityUserTable:dict];
        } else {
            if ([self ishaveInfoID]) {
                [self insertActivityHistoryUserTable:dict];
            }
        }
        
        if (sinaView.selectIndex == 2) {
            // 新浪微博 发送
            [[WeiboShare defaultWeiboShare] sinaWeiboShareText:_textViewC.text shareImage:self.shareImage];
        }
        
        if (tenView.selectIndex == 2) {
            // 腾讯微博 发送
            [[WeiboShare defaultWeiboShare] tencentWeiboShareText:_textViewC.text shareImage:self.shareImage];
        }
        
        //[progressHUD setLabelText:@"内容已经分享到微博"];
        [progressHUD hide:YES afterDelay:1.0f];
    } else {
        //[progressHUD setLabelText:@"内容分享失败"];
        [progressHUD hide:YES afterDelay:1.0f];
    }
}

#pragma mark -----private methods
- (void)onUploadDone:(id)sender
{
    //    [progressHUD setLabelText:@"内容已经分享到微博"];
    //	[progressHUD hide:YES afterDelay:2.0f];
}

- (void)onUploadError:(id)sender
{
    //[progressHUD setLabelText:@"内容分享失败"];
	[progressHUD hide:YES afterDelay:1.0f];
}

#pragma mark -
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"_autoView.frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardDidHideNotification" object:nil];
    [_autoView release], _autoView = nil;
    [_textBackgroundView release], _textBackgroundView = nil;
    [_textViewC release], _textViewC = nil;
    [_imageView release], _imageView = nil;
    [_toolView release], _toolView = nil;
    [sinaView release], sinaView = nil;
    [tenView release], tenView = nil;
    [progressHUD release], progressHUD = nil;
    self.shareImage = nil;
    [alabel release], alabel = nil;
    [lessen_url release];
    [url release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
