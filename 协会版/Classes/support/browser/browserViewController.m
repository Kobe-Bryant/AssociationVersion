    //
//  browserViewController.m
//  Profession
//
//  Created by siphp on 12-8-25.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "browserViewController.h"
#import "Common.h"
#import "LoginViewController.h"

@implementation browserViewController

@synthesize webView;
@synthesize titleString;
@synthesize url;
@synthesize webTitle;
@synthesize shareImage;
@synthesize spinner;
@synthesize isShowTool;
@synthesize ShareSheet;
@synthesize isSignFlag;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleString;
    
    CGFloat fixHeight = VIEW_HEIGHT - 20.0f - 44.0f;
    
    if (isShowTool) 
    {
        fixHeight = VIEW_HEIGHT - 20.0f - 44.0f - 44.0f;
        [self showToolBar];
    }
	
	UIWebView *tempWebView = [[UIWebView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, fixHeight)];
	self.webView = tempWebView;
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	[self.view addSubview:webView];
	[tempWebView release];
    
    if (isSignFlag) {
        // dufu add 2013.05.20
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        recognizer.delegate = self;
        [webView addGestureRecognizer:recognizer];
        [recognizer release];
    }

	if ([self.url length] > 1)
	{
		//开始请求连接
		NSURL *webUrl =[NSURL URLWithString:self.url];
		NSURLRequest *request =[NSURLRequest requestWithURL:webUrl];
		[webView loadRequest:request];
	}

}

//工具栏
-(void)showToolBar
{
    UIView *toolBarView = [[UIView alloc] initWithFrame:
                           CGRectMake(0.0f, VIEW_HEIGHT - 20.0f - 44.0f - 44.0f, 320.0f, 44.0f)];
    [self.view addSubview:toolBarView];
    
    UIImageView *toolBarBackgroundView = [[UIImageView alloc] initWithFrame:
								CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:
					  [[NSBundle mainBundle] pathForResource:@"共用_下bar" ofType:@"png"]];
	toolBarBackgroundView.backgroundColor = [UIColor clearColor];
	toolBarBackgroundView.userInteractionEnabled = YES;
    toolBarBackgroundView.image = image;
    [image release];
	[toolBarView addSubview:toolBarBackgroundView];
    [toolBarBackgroundView release];
    
    
    //添加按钮
    NSArray *toolItems = [NSArray arrayWithObjects:@"分享",@"刷新",nil];
    int itemsCouns = [toolItems count];
    int bTag = 1000;
    CGFloat oneButtonWidth = self.view.frame.size.width/itemsCouns;
    CGFloat marginWidth = oneButtonWidth/2;
    CGFloat fixWidth = 0.0f;
    for (NSString *itemTitle in toolItems) 
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = ++bTag;
        fixWidth = marginWidth + ((button.tag - 1000)-1) * oneButtonWidth;
		[button setFrame:CGRectMake(0.0f , 0.0f , 44.0f, 44.0f)];
        button.center = CGPointMake(fixWidth , 22.0f);
		[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置背景图
        NSString *picName = [NSString stringWithFormat:@"工具栏%@icon",itemTitle];
        [button setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:picName ofType:@"png"]] forState:UIControlStateNormal];
		
		UILabel *bTitle = [[UILabel alloc]initWithFrame:CGRectMake(0.0f , 22.0f , 44.0f , 20.0f)];
		bTitle.font = [UIFont boldSystemFontOfSize:12.0];
		bTitle.textAlignment = UITextAlignmentCenter;
		bTitle.backgroundColor = [UIColor clearColor];
        bTitle.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
		bTitle.text = itemTitle;
		[button addSubview:bTitle];
		[bTitle release];
        [toolBarView addSubview:button];
        
    }
    
    [toolBarView release];
}

//功能按钮
-(void)buttonClick:(id)sender
{
	UIButton *currentButton = sender;
	switch (currentButton.tag) 
	{
		case 1001:
		{
            isshare = YES;
            [self share];
			break;
		}
		case 1002:
		{
            [self reload];
			break;
		}
		default:
			break;
	}
	//[self topViewAnimation:@"up"];
}

//分享
-(void)share
{
    if (!isshare) {
        return;
    }
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
	NSString *link = self.url;
	NSString *content = self.webTitle;
	NSString *allContent = [NSString stringWithFormat:@"%@  %@",content,link];
    
    // 分享的内容信息字典
    NSDictionary *dict;
    if (self.shareImage.size.width > 2)
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                self.shareImage,ShareImage,
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl, nil];
    }
    else
    {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%@   %@",allContent,SHARE_CONTENTS],ShareAllContent,
                content,ShareContent,
                link,ShareUrl,  nil];
    }
    
    return dict;
}

//刷新
-(void)reload
{
	[webView reload];
}

#pragma mark -
#pragma mark webView委托

//当网页视图被指示载入内容而得到通知
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*) reuqest navigationType:(UIWebViewNavigationType)navigationType
{
    isshare = NO;
    NSString *reuqestString = [NSString stringWithFormat:@"%@",reuqest.URL];
    NSString *appleDownUrl1 = @"https://itunes.apple.com/";
    NSString *appleDownUrl2 = @"http://itunes.apple.com/";
    if ([reuqestString rangeOfString:appleDownUrl1 options:NSCaseInsensitiveSearch].location == NSNotFound && [reuqestString rangeOfString:appleDownUrl2 options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        return YES;
    }
    else 
    {
        [[UIApplication sharedApplication] openURL:reuqest.URL];
        return NO;
    }

}

//当网页视图已经开始加载一个请求后，得到通知。
-(void)webViewDidStartLoad:(UIWebView*)webView
{
	//添加loading图标
	UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	[tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, self.webView.frame.size.height / 2.0)];
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
}

//当网页视图结束加载一个请求之后，得到通知。 
-(void)webViewDidFinishLoad:(UIWebView*)webView
{
	[self.spinner removeFromSuperview];
}

//当在请求加载中发生错误时，得到通知。会提供一个NSSError对象，以标识所发生错误类型。  
-(void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error
{
	NSLog(@"浏览器浏览发生错误...");
}

// dufu 2013.05.20
// 手势
#pragma mark - UITapGestureRecognizer
- (void)handlePanFrom:(UITapGestureRecognizer *)sender
{
    isshare = YES;
    [self performSelector:@selector(share) withObject:nil afterDelay:0.5];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
    self.titleString = nil;
	self.url = nil;
    self.webTitle = nil;
    self.shareImage = nil;
	self.spinner = nil;
}


- (void)dealloc {
	self.webView = nil;
    [self.titleString release];
	self.url = nil;
    self.webTitle = nil;
    self.shareImage = nil;
	self.spinner = nil;
    [ShareSheet release];  // dufu add 2013.04.25
    [super dealloc];
}


@end
