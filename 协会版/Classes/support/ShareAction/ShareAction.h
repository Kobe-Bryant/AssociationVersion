//
//  ShareAction.h
//  xieHui
//
//  Created by yunlai on 13-4-24.
//
//

#import <Foundation/Foundation.h>
#import "SinaViewController.h"
#import "TencentViewController.h"

#define ShareImage          @"shareImage"       // 分享的图片内容
#define ShareAllContent     @"shareAllContent"  // 分享的所有内容
#define ShareContent        @"shareContent"     // 分享的标题内容
#define ShareUrl            @"shareurl"         // 分享的内容链接

@protocol ShareDelegate <NSObject>

@optional
- (NSDictionary *)shareSheetRetureValue;

@end

@interface ShareAction : NSObject <UIActionSheetDelegate,UIAlertViewDelegate,OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate>
{
    id <ShareDelegate> shareDelegate;
    
    BOOL flag;
}

@property (retain, nonatomic) UIActionSheet *actionSheet;
@property (retain, nonatomic) UIViewController *navController;

// 分享委托
@property (assign, nonatomic) id <ShareDelegate> shareDelegate;
// 分享字典，里面有图片和内容
@property (retain, nonatomic) NSDictionary *shareData;

- (void)shareActionShow:(id)aView navController:(id)viewController;

@end
