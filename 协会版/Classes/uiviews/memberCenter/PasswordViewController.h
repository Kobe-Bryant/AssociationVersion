//
//  PasswordViewController.h
//  xieHui
//
//  Created by yunlai on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@interface PasswordViewController : UIViewController <UITextFieldDelegate,CommandOperationDelegate,MBProgressHUDDelegate>
{
    UIView *MBview;
}

// 网络指示器
@property (retain, nonatomic) MBProgressHUD *progressHUD;

@property (retain, nonatomic) UIView *MBview;

@end
