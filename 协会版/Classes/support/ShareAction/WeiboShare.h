//
//  WeiboShare.h
//  xieHui
//
//  Created by yunlai on 13-5-6.
//
//

#import <Foundation/Foundation.h>

#import "SinaViewController.h"
#import "TencentViewController.h"

@interface WeiboShare : NSObject <OpenAPiDelegate,SinaWeiboDelegate,SinaWeiboRequestDelegate,WBEngineDelegate>

@property (retain, nonatomic) SinaWeibo *sinaWeibo;

// 微博单例
+ (WeiboShare *)defaultWeiboShare;

// 新浪分享
- (void)tencentWeiboShareText:(NSString *)text shareImage:(UIImage *)image;

// 腾讯分享
- (void)sinaWeiboShareText:(NSString *)text shareImage:(UIImage *)image;

@end
