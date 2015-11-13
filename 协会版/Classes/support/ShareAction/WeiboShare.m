//
//  WeiboShare.m
//  xieHui
//
//  Created by yunlai on 13-5-6.
//
//

#import "WeiboShare.h"
#import "OpenApi.h"
#import "Common.h"
#import "WBEngine.h"
#import "DBOperate.h"

#define oauthMode InWebView

static WeiboShare *weiboShare = nil;

@implementation WeiboShare

@synthesize sinaWeibo;

+ (WeiboShare *)defaultWeiboShare
{
    @synchronized(self) {
        if (weiboShare == nil) {
            weiboShare = [[WeiboShare alloc]init];
        }
        return weiboShare;
    }
}

- (void)sinaWeiboShareText:(NSString *)text shareImage:(UIImage *)image
{
    NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:SINA withAll:NO];
    
    if (weiboArray != nil && [weiboArray count] > 0) {
        
        NSArray *array = [weiboArray objectAtIndex:0];
        sinaWeibo = [[SinaWeibo alloc] initWithAppKey:SinaAppKey appSecret:SinaAppSecret appRedirectURI:redirectUrl andDelegate:self];
        sinaWeibo.userID = [array objectAtIndex:weibo_user_id];
        sinaWeibo.accessToken = [array objectAtIndex:weibo_access_token];
        sinaWeibo.expirationDate = [NSDate dateWithTimeIntervalSince1970:[[array objectAtIndex:weibo_expires_time] doubleValue]];
        
        [sinaWeibo requestWithURL:@"statuses/upload.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status",image, @"pic", nil]
                       httpMethod:@"POST"
                         delegate:self];
    }
}

- (void)tencentWeiboShareText:(NSString *)text shareImage:(UIImage *)image
{
    NSArray *weiboArray = [DBOperate queryData:T_WEIBO_USERINFO theColumn:@"weiboType" theColumnValue:TENCENT withAll:NO];
    
    if (weiboArray != nil && [weiboArray count] > 0) {
        NSArray *array = [weiboArray objectAtIndex:0];
        //用GCD进行异步操作
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            OpenApi *openApi = [[OpenApi alloc] initForApi:[OpenSdkBase getAppKey]
                                                 appSecret:[OpenSdkBase getAppSecret]
                                               accessToken:[array objectAtIndex:weibo_access_token]
                                              accessSecret:nil
                                                    openid:[array objectAtIndex:weibo_open_id]
                                                 oauthType:oauthMode];
            openApi.delegate = self;
            
            //发表带图片微博
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"temp.png"];
            [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
            //发表带图片微博
            [openApi publishWeiboWithImage:filePath
                              weiboContent:text
                                      jing:@""
                                       wei:@""
                                    format:@"json"
                                  clientip:[OpenSdkBase getClientIp]
                                  syncflag:@"1"];
        });
    }
}

#pragma mark - SinaWeiboRequest Delegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    //NSLog(@"SinaWeiboRequest  share  fail ......");
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        //NSLog(@"SinaWeiboRequest  share  success ......");
    }
}

#pragma mark - WBEngine Methods
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error{
	//NSLog(@"WBEngine  share  fail ......");
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result{
	NSLog(@"WBEngine  share  success ......");
}

#pragma mark - tencentAPi Delegate
- (void) publishQWeiboSuccess {
	NSLog(@"tencentAPi  share  success ......");
}
-(void) getUserInfoSuccess:(NSString*)userInfo
{}

-(void) publishQWeiboFail
{
    //NSLog(@"tencentAPi  share  fail ......");
}

@end
