//
//  ShareAction.m
//  xieHui
//
//  Created by yunlai on 13-4-24.
//
//

#import "ShareAction.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "SendMsgToWeChat.h"
#import "ShareToBlogViewController.h"
#import "SinaViewController.h"
#import "DBOperate.h"
#import "Common.h"
#import "callSystemApp.h"
#import "UIImageScale.h"

#define WXDownAddress @"http://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"

// 分享
typedef enum
{
    ShareWXFriendCircle,    // 微信朋友圈
    ShareWXFriend,          // 微信好友
    ShareSina,              // 新浪微博
    ShareTencent,           // 腾讯微博
    SharePhone,             // 手机用户
    ShareMax
} SHAREENUM;

@implementation ShareAction

@synthesize actionSheet;
@synthesize navController;

@synthesize shareDelegate;
@synthesize shareData;

- (void)dealloc
{
    [actionSheet release], actionSheet = nil;
    [navController release];
    [shareData release];
    
    [super dealloc];
}

- (void)shareActionShow:(id)aView navController:(id)viewController
{
    [navController release];
    navController = [viewController retain];
    
    if (flag) {
        return;
    }
    
    flag = YES;
    
    // 创建一个UIActionSheet实例
    actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
    // 设置actionSheet为默认模式
    actionSheet.actionSheetStyle = UIBarStyleDefault;

    
    // 分享数组
    NSArray *array = [NSArray arrayWithObjects:
                      @"分享到微信朋友圈",
                      @"分享到微信好友",
                      @"分享到新浪微博",
                      @"分享到腾讯微博",
                      @"分享到手机用户", nil];
    
    for (NSString *str in array){
		[actionSheet addButtonWithTitle:str];
	}
	[actionSheet addButtonWithTitle:@"取消"];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:(UIView*)aView];
}



// 微信 分享
- (void)WXShareInt:(int)intWX dict:(NSDictionary *)shareDict
{
    // 是否安装微信
    if(![WXApi isWXAppInstalled]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"使用微信可以方便、免费的与好友分享图片、新闻"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"下载微信",nil];
        [alertView show];
        [alertView release];
    }else {
        // 发送数据实例创建
        SendMsgToWeChat *sendMsg = [[SendMsgToWeChat alloc] init];
        // 得到标题
        NSString *content = [shareDict objectForKey:ShareContent];
        // 得到所有内容
        NSString *AllContent = [shareDict objectForKey:ShareAllContent];
        // 得到URL链接
        NSString *url = [shareDict objectForKey:ShareUrl];
        // 得到图片
        UIImage *image = [shareDict objectForKey:ShareImage];
        // 图片缩小到WX接受的范围内
        UIImage *imagesss = nil;
        if (image) {
            imagesss = [image scaleToSize:CGSizeMake(57.0, 57.0)];
        } else {
            imagesss = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"微信分享默认图" ofType:@"png"]];
        }
        
        // 分享数据到微信好友
        [sendMsg sendNewsContent:content newsDescription:AllContent newsImage:imagesss newUrl:url shareType:intWX];
        [sendMsg release];
    }
}

//  weibo 分享
- (void)weiboShareInt:(int)intWeibo dict:(NSDictionary *)shareDict
{
    ShareToBlogViewController *share = [[ShareToBlogViewController alloc] init];
    share.weiBoType = intWeibo;
    share.shareImage = [shareDict objectForKey:ShareImage];
    if (share.shareImage) {
        share.checkBoxSelected = YES;
    } else {
        share.checkBoxSelected = NO;
    }
    share.defaultContent = [shareDict objectForKey:ShareAllContent];
    [(UINavigationController*)navController pushViewController:share animated:YES];
    [share release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex)
	{
        // 微信如果没有安装，从此处跳到安装目录
		NSURL *url = [NSURL URLWithString:WXDownAddress];
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"buttonIndex: %d",buttonIndex);
    
    // 判断shareAction委托是否实现
    if ([self.shareDelegate respondsToSelector:@selector(shareSheetRetureValue)]) {
        [shareData release];
        shareData = [[self.shareDelegate shareSheetRetureValue] retain];
    }
    NSLog(@"shareData%@",shareData);
    flag = NO;
    
    //NSLog(@"shareData = %@",shareData);
    
    switch (buttonIndex) {
        case ShareWXFriendCircle:
            {
                [self WXShareInt:0 dict:shareData];
            }
            break;
        case ShareWXFriend:
            {
                [self WXShareInt:1 dict:shareData];
            }
            break;
        case ShareSina:
            {
                NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType"
                                            theColumnValue:SINA withAll:NO];
                if (weiboArray != nil && [weiboArray count] > 0) {
                    
                    [self weiboShareInt:0 dict:shareData];
                    
                }else {
                    SinaViewController *sc = [[SinaViewController alloc] init];
                    sc.delegate = self;
                    [(UINavigationController*)navController pushViewController:sc animated:YES];
                    [sc release];
                }
            }
            break;
        case ShareTencent:
            {
                NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType"
                                            theColumnValue:TENCENT withAll:NO];
                if (weiboArray != nil && [weiboArray count] > 0) {
                    
                    [self weiboShareInt:1 dict:shareData];
                    
                }else {
                    TencentViewController *tc = [[TencentViewController alloc] init];
                    tc.delegate = self;
                    [(UINavigationController*)navController pushViewController:tc animated:YES];
                    [tc release];
                }
            }
            break;
        case SharePhone:
            {
                [callSystemApp sendMessageTo:@"" inUIViewController:(UINavigationController*)navController withContent:[shareData objectForKey:ShareAllContent]];
            }
            break;
        default:
            break;
    }
}

#pragma mark OauthSinaSeccessDelagate
- (void) oauthSinaSuccess
{
    if ([self.shareDelegate respondsToSelector:@selector(shareSheetRetureValue)]) {
        [shareData release];
        shareData = [[self.shareDelegate shareSheetRetureValue] retain];
    }
    
	[self weiboShareInt:0 dict:shareData];
}

#pragma mark OauthTencentSeccessDelagate
- (void) oauthTencentSuccess
{
    if ([self.shareDelegate respondsToSelector:@selector(shareSheetRetureValue)]) {
        [shareData release];
        shareData = [[self.shareDelegate shareSheetRetureValue] retain];
    }
    
	[self weiboShareInt:1 dict:shareData];
}

@end
