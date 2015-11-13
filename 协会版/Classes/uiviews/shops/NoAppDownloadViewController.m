//
//  NoAppDownloadViewController.m
//  xieHui
//
//  Created by LuoHui on 13-4-23.
//
//

#import "NoAppDownloadViewController.h"
#import "DBOperate.h"
#import "Common.h"
#import "DataManager.h"
#import "browserViewController.h"

@interface NoAppDownloadViewController ()

@end

@implementation NoAppDownloadViewController
@synthesize uId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"单位";
    self.view.backgroundColor = [UIColor clearColor];
    
    //CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height - 20 - 44;
    
    UIImage *logoImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_无企业移动APP" ofType:@"png"]];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - logoImg.size.width) * 0.5, self.view.frame.size.height * 0.5 * 0.5 * 0.5, logoImg.size.width, logoImg.size.height)];
    logoView.image = logoImg;
    logoView.layer.masksToBounds = YES;
    logoView.layer.cornerRadius = 10;
    [self.view addSubview:logoView];
    [logoView release];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame) + 40, 320, 30)];
    strLabel.backgroundColor = [UIColor clearColor];
    strLabel.text = @"天哪！TA还没有自己的企业移动APP！";
    strLabel.textAlignment = UITextAlignmentCenter;
    strLabel.textColor = [UIColor darkTextColor];
    strLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:strLabel];
    [strLabel release];
    
    UIImage *btnImage = [UIImage imageNamed:@"button_green.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((320 - 230) * 0.5, CGRectGetMaxY(strLabel.frame) + 20, 230, 50);
    [btn setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(knowApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIImage *btnImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_了解企业移动APP" ofType:@"png"]];
    UIImageView *btnView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (btn.frame.size.height - btnImg.size.height) * 0.5, btnImg.size.width, btnImg.size.height)];
    btnView.image = btnImg;
    [btn addSubview:btnView];
    [btnView release];
    
    UILabel *btnStr = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnView.frame) + 5, (btn.frame.size.height - 30) * 0.5, btn.frame.size.width - CGRectGetMaxX(btnView.frame) - 5, 30)];
    btnStr.backgroundColor = [UIColor clearColor];
    btnStr.text = @"了解企业移动APP";
    btnStr.textAlignment = UITextAlignmentLeft;
    btnStr.textColor = [UIColor whiteColor];
    btnStr.font = [UIFont systemFontOfSize:16];
    [btn addSubview:btnStr];
    [btnStr release];
    
    [self accessService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [uId release];
    [super dealloc];
}

#pragma mark ---- private method
- (void)knowApp
{
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isShowTool = NO;
    browser.url = SHOWAPP_URL;
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

- (void)accessService
{
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:[uId intValue]],@"user_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:SENDMESSAGE_COMMAND_ID accessAdress:@"sendmessage.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case SENDMESSAGE_COMMAND_ID:
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
    
}
@end
