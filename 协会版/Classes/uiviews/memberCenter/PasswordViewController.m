//
//  PasswordViewController.m
//  xieHui
//
//  Created by yunlai on 13-6-5.
//
//

/*
 此文件用作密码修改
 */

#import "PasswordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "alertView.h"
#import "DBOperate.h"


@interface PasswordViewController ()
{
    UITextField *oldTextField;
    UITextField *newsTextField;
    
    NSString *userName;
    NSString *userPassword;
    
    int value;
}

// 旧密码
@property (retain, nonatomic) UITextField *oldTextField;
// 新密码
@property (retain, nonatomic) UITextField *newsTextField;
// 用户账号
@property (retain, nonatomic) NSString *userName;
// 用户密码
@property (retain, nonatomic) NSString *userPassword;


@end

@implementation PasswordViewController

@synthesize MBview;
@synthesize oldTextField;
@synthesize newsTextField;
@synthesize userName;
@synthesize userPassword;
@synthesize progressHUD;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"修改密码";
    self.view.backgroundColor = [UIColor colorWithRed:235.f/255.f green:235.f/255.f blue:235.f/255.f alpha:1];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishButton:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    
    CGFloat imageWidth = 300.f;
    CGFloat imageHeight = 44.f;
    
    MBview = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, imageWidth, 200.f)];
    MBview.backgroundColor = [UIColor colorWithRed:235.f/255.f green:235.f/255.f blue:235.f/255.f alpha:1];
    [self.view addSubview:MBview];
    
    UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(10.f, 30.f, imageWidth, imageHeight*2)];
    bgview.backgroundColor = [UIColor whiteColor];
    bgview.layer.masksToBounds = YES;
    bgview.layer.cornerRadius = 8.f;
    bgview.layer.borderWidth = 1.f;
    bgview.layer.borderColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1].CGColor;
    [self.view addSubview:bgview];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0.f, imageHeight, imageWidth, 1.f)];
    line.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1];
    [bgview addSubview:line];
    [line release], line = nil;
    
    oldTextField = [[UITextField alloc]initWithFrame:CGRectMake(30.f, 12.f, imageWidth-40, imageHeight-20.f)];
    oldTextField.placeholder = @"请输入旧密码";
    oldTextField.secureTextEntry = YES; //密码
    oldTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    oldTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    oldTextField.returnKeyType = UIReturnKeyDone;
    oldTextField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    oldTextField.delegate = self;
    [bgview addSubview:oldTextField];
    
    newsTextField = [[UITextField alloc]initWithFrame:CGRectMake(30.f, imageHeight+12.f, imageWidth-40.f, imageHeight-20.f)];
    newsTextField.placeholder = @"请输入新密码";
    newsTextField.secureTextEntry = YES; //密码
    newsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    newsTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    newsTextField.returnKeyType = UIReturnKeyDone;
    newsTextField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    newsTextField.delegate = self;
    [bgview addSubview:newsTextField];
    
    [bgview release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
    NSArray *memberArray = [dbArray objectAtIndex:0];
    self.userName = [memberArray objectAtIndex:member_info_name];
    self.userPassword = [memberArray objectAtIndex:member_info_password];
    
    [oldTextField becomeFirstResponder];
}

//网络获取数据
-(void)accessService
{
    NSString *reqUrl = @"member/alterpwd.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 self.userName,@"username",
                                 oldTextField.text,@"old_pwd",
                                 newsTextField.text,@"new_pwd",
								 nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:MEMBER_PASSWORD_COMMAND_ID
								  accessAdress:reqUrl
									  delegate:self
									 withParam:nil];
}

// 发送前的判断
- (void)sendJudge
{
    if (oldTextField.text.length == 0) {
        [alertView showAlert:@"旧密码不可以为空"];
    } else if (newsTextField.text.length == 0) {
        [alertView showAlert:@"新密码不可以为空"];
    } else if ((oldTextField.text.length > 0 && oldTextField.text.length < 6) || (newsTextField.text.length > 0 && oldTextField.text.length < 6)) {
        [alertView showAlert:@"请正确输入您的密码，密码一般大于等于6位小于15位"];
    } else {
        
        // 加载视图
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:MBview];
        self.progressHUD = progressHUDTmp;
        [progressHUDTmp release];
        self.progressHUD.delegate = self;
        self.progressHUD.labelText = @"正在修改...";
        [self.view addSubview:self.progressHUD];
        [self.view bringSubviewToFront:self.progressHUD];
        [self.progressHUD show:YES];
        
        [self performSelector:@selector(accessService)];
    }
}

// 完成按钮
- (void)finishButton:(id)sender
{
    [self sendJudge];
}

// 隐藏网络指示器，放在主线程中操作
- (void)hideprogressHUD
{
    [self.progressHUD hide:YES afterDelay:1.0f];
}

// 密码修改成功，更新数据库
- (void)updatePassword
{
    [DBOperate updateData:T_MEMBER_INFO
              tableColumn:@"memberPassword"
              columnValue:newsTextField.text
          conditionColumn:@"memberName"
     conditionColumnValue:self.userName];
}

#pragma mark - CommandOperationDelegate
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == MEMBER_PASSWORD_COMMAND_ID) {
        NSArray *arr = [NSArray arrayWithArray:resultArray];
        if (arr.count > 0) {
            value = [[arr objectAtIndex:0] intValue];
            
            if (value == 0) {
                [self.progressHUD setLabelText:@"修改密码失败"];
            } else if (value == 1) {
                [self updatePassword];
                [self.progressHUD setLabelText:@"修改密码成功"];
            } else if (value == 2) {
                [self.progressHUD setLabelText:@"输入的密码有误"];
            }
        } else {
            [self.progressHUD setLabelText:@"网络连接失败"];
        }
    }
    
    [self performSelectorOnMainThread:@selector(hideprogressHUD) withObject:nil waitUntilDone:NO];
}

#pragma mark - MBProgressHUD
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
	}
    if (value == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendJudge];
    
    return YES;
}

- (void)dealloc
{
    [oldTextField release], oldTextField = nil;
    [newsTextField release], newsTextField = nil;
    [MBview release], MBview = nil;
    self.userName = nil;
    self.userPassword = nil;
    self.progressHUD = nil;
    
    [super dealloc];
}

@end
