//
//  activityShareViewController.h
//  xieHui
//
//  Created by yunlai on 13-5-3.
//
//

#import <UIKit/UIKit.h>

#import "SinaViewController.h"
#import "TencentViewController.h"
#import "EPUploader.h"
#import "MBProgressHUD.h"

@interface activityShareViewController : UIViewController <UITextViewDelegate,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate,MBProgressHUDDelegate,EPUploaderDelegate>
{
    UIView *_autoView;
    UIView *_textBackgroundView;
    UITextView *_textViewC;
    UIImageView *_imageView;
    UIView *_toolView;
}

// 自动滚动层
@property (retain, nonatomic) UIView *autoView;
// textViewC 的背景层
@property (retain, nonatomic) UIView *textBackgroundView;
// textViewC 视图
@property (retain, nonatomic) UITextView *textViewC;
// 右侧图片视图
@property (retain, nonatomic) UIImageView *imageView;
// 分享视图
@property (retain, nonatomic) UIView *toolView;
// 上传类
@property (retain, nonatomic) EPUploader *upload;
// 分享的图片，上个页面传进来
@property (retain, nonatomic) UIImage *shareImage;
// 活动ID，上个页面传进来
@property (assign, nonatomic) int info_id;
// 用户ID，上个页面传进来
@property (assign, nonatomic) int user_id;
// 判断插入的数据库，上个页面传进来
@property (assign, nonatomic) BOOL tableFlag;

@end
