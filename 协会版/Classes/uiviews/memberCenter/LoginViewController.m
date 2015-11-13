//
//  LoginViewController.m
//  Profession
//
//  Created by MC374 on 12-8-18.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "DBOperate.h"
#import "Encry.h"
#import "DataManager.h"
#import "Common.h"
#import "DBOperate.h"
#import "OpenSdkOauth.h"
#import "OpenApi.h"
#import "TencentViewController.h"
#import "SinaViewController.h"
#import "UIImageScale.h"
#import "FileManager.h"
#import "ProfessionAppDelegate.h"
#import "callSystemApp.h"
#import "MemberEditViewController.h"
#import "CustomTabBar.h"
#import "alertCardViewController.h"
#define kRowHeight 50.0f

@implementation LoginViewController
@synthesize nameTextField;
@synthesize passwordTextField;
@synthesize mbProgressHUD;
@synthesize headImageView;
@synthesize progressHUD;
@synthesize memberCenter;
@synthesize img;
@synthesize delegate;
@synthesize upload;
@synthesize scaleImage;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.title = @"会员";
    
    UIView *mainView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:mainView];
    
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardAction)];
	[mainView addGestureRecognizer:tapGesture];
	tapGesture.delegate = self;
	[tapGesture release];
	[mainView release];

//	loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 320, 120) style:UITableViewStyleGrouped];
//	loginTableView.delegate = self;
//	loginTableView.dataSource = self;
//	loginTableView.rowHeight = kRowHeight;
//	loginTableView.scrollEnabled = NO;
//	loginTableView.backgroundColor = [UIColor whiteColor];
//    loginTableView.backgroundView = nil;
//	[self.view addSubview:loginTableView];
    
	//----------ios7不支持UITableViewStyleGrouped类型的
    UIView *tableView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.masksToBounds = YES;
    tableView.layer.cornerRadius = 6;
    tableView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
    tableView.layer.borderWidth = 1;
    [self.view addSubview:tableView];
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 60, 40)];
    name.text = @"帐 号：";
    name.textAlignment = UITextAlignmentLeft;
    name.backgroundColor = [UIColor clearColor];
    [tableView addSubview:name];
    [name release];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 10, 220, 30)];
    nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField = nameText;
    nameTextField.borderStyle = UITextBorderStyleNone;
    nameTextField.backgroundColor = [UIColor clearColor];
    [self.nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [tableView addSubview:nameTextField];
    [nameText release];
    
    UILabel *seperator1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 300, 1)];
    seperator1.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
    [tableView addSubview:seperator1];
    [seperator1 release];
    
    UILabel *password = [[UILabel alloc] initWithFrame:CGRectMake(15, 50 + 5, 60, 40)];
    password.text = @"密 码：";
    password.textAlignment = UITextAlignmentLeft;
    password.backgroundColor = [UIColor clearColor];
    [tableView addSubview:password];
    [password release];
    
    UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(password.frame), 50 + 10, 220, 30)];
    self.passwordTextField = passwordText;
    passwordTextField.borderStyle = UITextBorderStyleNone;
    passwordTextField.backgroundColor = [UIColor clearColor];
    [self.passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate = self;
    [tableView addSubview:passwordTextField];
    [passwordText release];
    
    [tableView release];
    //------------------------------
    
	UIImage *btnImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"登 录按钮" ofType:@"png"]];
	UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
	loginButton.frame = CGRectMake((320 - btnImage.size.width) * 0.5f, CGRectGetMaxY(tableView.frame) + 10, btnImage.size.width, btnImage.size.height);
	[loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
	[loginButton setBackgroundImage:btnImage forState:UIControlStateNormal];
	[self.view addSubview:loginButton];
	[btnImage release];
	
    UIImage *btnImage1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"电话获取账号" ofType:@"png"]];
	UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
	registButton.frame = CGRectMake((320 - btnImage1.size.width) * 0.5f, CGRectGetMaxY(loginButton.frame) + 20, btnImage1.size.width, btnImage1.size.height);
	[registButton addTarget:self action:@selector(registAction) forControlEvents:UIControlEventTouchUpInside];
	[registButton setBackgroundImage:btnImage1 forState:UIControlStateNormal];
	[self.view addSubview:registButton];
	
	
	memberCenter = [[MenberCenterMainViewController alloc] init];
	
	memberCenter.loginViewController = self;
	memberCenter.delegate = self;
	
	[self.view addSubview:memberCenter.view];
    memberCenter.view.hidden = YES;
    
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
	self.progressHUD = progressHUDTmp;
	[progressHUDTmp release];	
	self.progressHUD.delegate = self;
	self.progressHUD.labelText = @"登录中...";
    
//	barButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(changeAction)];
	
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (_isLogin == YES) {
		memberCenter.view.hidden = NO;
		[memberCenter viewAppearAction];
		
		ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
		[memberCenter.memberHeaderView setImage:deleagte.headerImage];
        
        self.tabBarController.title = @"个人中心";
        
       // [self.tabBarController.navigationItem setRightBarButtonItem:barButton];
    }else {
        memberCenter.view.hidden = YES;
        self.tabBarController.title = @"登录";
        //[self.tabBarController.navigationItem setRightBarButtonItem:nil];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    nameTextField = nil;
	passwordTextField = nil;
	mbProgressHUD = nil;
	progressHUD = nil;
	
	memberCenter = nil;
	headImageView = nil;
	img = nil;
	
	delegate = nil;
	upload = nil;
	scaleImage = nil;
}


- (void)dealloc {
	[loginTableView release];
	[nameTextField release];
	[passwordTextField release];
	[mbProgressHUD release];
	
	[progressHUD release];
	
	[memberCenter release];
	[headImageView release];
	[img release];
	[upload release];
	[scaleImage release];
	[barButton release];
	loginTableView = nil;
	nameTextField = nil;
	passwordTextField = nil;
	mbProgressHUD = nil;
	progressHUD = nil;
	
	memberCenter = nil;
	headImageView = nil;
	img = nil;
	
	delegate = nil;
	upload = nil;
	scaleImage = nil;
    [super dealloc];
	
}


//#pragma mark -
//#pragma mark Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
//}
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//	
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];	
//	
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
//		
//		switch (indexPath.row) {
//            case 0:
//            {
//				UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 60, 40)];
//				name.text = @"帐 号：";			
//				name.textAlignment = UITextAlignmentLeft;
//				name.backgroundColor = [UIColor clearColor];
//				[cell.contentView addSubview:name];
//				[name release];
//                
//				UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 10, 220, 30)];
//				nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
//				self.nameTextField = nameText;
//				nameTextField.borderStyle = UITextBorderStyleNone;
//				nameTextField.backgroundColor = [UIColor clearColor];
//				[self.nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//				[cell.contentView addSubview:nameTextField];
//				[nameText release];
//			
//            }break;
//            case 1:
//            {
//                UILabel *password = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 60, 40)];
//				password.text = @"密 码：";
//				password.textAlignment = UITextAlignmentLeft;
//				password.backgroundColor = [UIColor clearColor];
//				[cell.contentView addSubview:password];
//				[password release];
//				    
//				UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(password.frame), 10, 220, 30)];
//				self.passwordTextField = passwordText;
//				passwordTextField.borderStyle = UITextBorderStyleNone;
//				passwordTextField.backgroundColor = [UIColor clearColor];
//                passwordTextField.returnKeyType = UIReturnKeyDone;
//                [self.passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//				passwordTextField.secureTextEntry = YES;
//                passwordTextField.delegate = self;
//				[cell.contentView addSubview:passwordTextField];
//				[passwordText release];
//                
//            }break;
//                           
//            default:
//                break;
//        }
//		
//    }
//	
//	return cell;
//}

#pragma mark -----UITextFieldDelegate  method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loginAction];
    return YES;
}

#pragma mark -----UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
	if(picker.sourceType==UIImagePickerControllerSourceTypeCamera){
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否上传到服务器？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
		[alert show];
		[alert release];
		
		[self dismissModalViewControllerAnimated:YES];
        
	}else {
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否上传到服务器？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
		[alert show];
		[alert release];
		
		[picker dismissModalViewControllerAnimated:YES];   
    }
	_isChangedImage = YES;
	ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
	deleagte.headerImage = image;
	[self.memberCenter.memberHeaderView setImage:deleagte.headerImage];
	self.img = deleagte.headerImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];  
    
}


#pragma mark ----MenberCenterMainViewControllerDelegate method
- (void)actionButtonIndex:(int)index imageView:(UIImageView *)imgView{
	self.headImageView = imgView;
	UIImagePickerController *myPicker  = [[UIImagePickerController alloc] init];
    myPicker.delegate = self;
    myPicker.editing = YES;
    switch (index) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                myPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
				myPicker.allowsEditing = YES;
                [self presentModalViewController:myPicker animated:YES];
				
            }        
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
                myPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
				myPicker.allowsEditing = YES;
                [self presentModalViewController:myPicker animated:YES];
				
            }
            
            break;
        default:
            break;
    }
	//[myPicker release];
	
}

#pragma mark ------UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	if (buttonIndex == 0) {
        
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		self.mbProgressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.mbProgressHUD.delegate = self;
		self.mbProgressHUD.labelText = @"正在上传...";
		[self.view addSubview:self.mbProgressHUD];
		[self.mbProgressHUD show:YES];
        
		int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
		
		NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 [Common getSecureString],@"keyvalue",
									 [NSNumber numberWithInt: SITE_ID],@"site_id",
									 [NSNumber numberWithInt:_userId],@"user_id",nil];
		
		NSString *reqstr = [Common TransformJson:jsontestDic withLinkStr: [ACCESS_SERVER_LINK stringByAppendingString:@"member/updateinfo.do?param=%@"]];
		self.scaleImage = [self.img scaleToSize:CGSizeMake(60, 60)];
		NSData *pictureData =UIImagePNGRepresentation(self.img);
		upload = [[EPUploader alloc] initWithURL:[NSURL URLWithString:reqstr] filePath:pictureData delegate:self doneSelector:@selector(onUploadDone:) errorSelector:@selector(onUploadError:)];
	    upload.uploaderDelegate = self;
	}
}

//#pragma mark ---EPUploaderDelegate method
//- (void)receiveResult:(NSString *)result
//{
//	NSDictionary *resultDic = [result JSONValue];
//	//NSLog(@"resultDic===%@",resultDic);
//	NSString *retStr = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
//	NSString *urlStr = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"url"]];
//	if ([retStr isEqualToString:@"1"] && urlStr != nil) {
//                
//		NSArray *dbArr = [[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0];
//		NSString *name = [dbArr objectAtIndex:member_info_name];
//		NSString *userId = [NSString stringWithFormat:@"%d",[[dbArr objectAtIndex:member_info_memberId] intValue]];
//		
//		//NSString *piclink = @"http://192.168.1.180:8080/HY_APPInterfaceServer/user-pic/1/100/monkey-1348452072613.png";
//		NSArray *sep_ay = [urlStr componentsSeparatedByString:@"/"];
//		//NSLog(@"sep_ay:%@",sep_ay);
//		
//		NSString *photoname = [[[sep_ay objectAtIndex:[sep_ay count] - 1] componentsSeparatedByString:@"."] objectAtIndex:0];
//		
//		if ([FileManager savePhoto:photoname withImage:self.scaleImage]) {
//			[DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"image" theColumnValue:urlStr ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
//			[DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"imageName" theColumnValue:photoname ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
//			
//		}
//	}	
//}

#pragma mark -----private methods
//- (void) onUploadDone:(id)sender{
//    
//    [self.mbProgressHUD hide:YES];
//    [self.mbProgressHUD removeFromSuperViewOnHide];
//	
//	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];	
//	progressHUDTmp.delegate = self;
//	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
//	progressHUDTmp.mode = MBProgressHUDModeCustomView;
//	progressHUDTmp.labelText = @"上传成功";
//	[self.view addSubview:progressHUDTmp];
//	[progressHUDTmp show:YES];
//	[progressHUDTmp hide:YES afterDelay:2];	
//    [progressHUDTmp release];
//}
//- (void) onUploadError:(id)sender{
//    [self.mbProgressHUD hide:YES];
//    [self.mbProgressHUD removeFromSuperViewOnHide];
//	
//	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
//	progressHUDTmp.delegate = self;
//	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
//	progressHUDTmp.mode = MBProgressHUDModeCustomView;
//	progressHUDTmp.labelText = @"上传失败";
//	[self.view addSubview:progressHUDTmp];
//	[progressHUDTmp show:YES];
//	[progressHUDTmp hide:YES afterDelay:2];	
//    [progressHUDTmp release];
//}

- (void)dismissKeyboardAction
{
	[nameTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}

- (void)loginAction
{
	[nameTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
	if (nameTextField.text.length == 0 || passwordTextField.text.length == 0) {
		MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		self.mbProgressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.mbProgressHUD.delegate = self;
		self.mbProgressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		self.mbProgressHUD.mode = MBProgressHUDModeCustomView;
		self.mbProgressHUD.labelText = @"帐号和密码不能为空";
		[self.view addSubview:self.mbProgressHUD];
		//[self.view bringSubviewToFront:self.mbProgressHUD];
		[self.mbProgressHUD show:YES];
		[self.mbProgressHUD hide:YES afterDelay:1];
		
	}else {
		MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		self.mbProgressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.mbProgressHUD.delegate = self;
		self.mbProgressHUD.labelText = @"登录中...";
		[self.view addSubview:self.mbProgressHUD];
		[self.mbProgressHUD show:YES];
		
		[self accessService];
	}

}

- (void)registAction
{
    NSArray *dbArr = [DBOperate queryData:T_PHONENUM theColumn:nil theColumnValue:nil withAll:YES];
    NSString *mobileStr = nil;
    if (dbArr != nil && [dbArr count] > 0) {
        mobileStr = [[dbArr objectAtIndex:0] objectAtIndex:phoneNum_mobile];
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    alertCardViewController *alert = [[alertCardViewController alloc] initWithFrame:window.bounds withContent:kAPPName withMobile:mobileStr];
    
    [window addSubview:alert];
    [alert showFromPoint:[self.view center]];
}

- (void)accessService
{
    NSString *location = [NSString stringWithFormat:@"%f,%f",myLocation.latitude,myLocation.longitude];
    
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
								 nameTextField.text,@"login_name",
								 passwordTextField.text,@"login_pwd",
                                 location,@"lat-and-long",
                                 [NSNumber numberWithInt: 1],@"edition",
                                 [Common getMacAddress],@"mac_addr",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_LOGIN_COMMAND_ID 
								  accessAdress:@"member/login.do?param=%@" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case MEMBER_LOGIN_COMMAND_ID:
		{
			NSString *resultstr = [[resultArray objectAtIndex:0] objectAtIndex:0];
			if ([resultstr isEqualToString:@"1"]) {
				[self performSelectorOnMainThread:@selector(loginSuccess:) withObject:resultArray waitUntilDone:NO];
			}else {
				[self performSelectorOnMainThread:@selector(loginFail) withObject:nil waitUntilDone:NO];
			}
		}break;
        default:
			break;
	}
	
	if (progressHUD != nil) {
		[progressHUD removeFromSuperViewOnHide];
	}
}


- (void)loginSuccess:(NSMutableArray*)resultArray
{
	self.mbProgressHUD.hidden = YES;
	
	_isLogin = YES;
	
    self.tabBarController.title = @"个人中心";
    //[self.tabBarController.navigationItem setRightBarButtonItem:barButton];
    
	NSMutableArray *infoArray = [resultArray objectAtIndex:1];
	[infoArray removeObjectAtIndex:1];
	[infoArray insertObject:nameTextField.text atIndex:1];
	[infoArray removeObjectAtIndex:3];
	[infoArray insertObject:passwordTextField.text atIndex:3];
	//NSLog(@"infoArray====%@",infoArray);
	[DBOperate deleteData:T_MEMBER_INFO];
	[DBOperate insertData:infoArray tableName:T_MEMBER_INFO];

	nameTextField.text = nil;
	passwordTextField.text = nil;
	
	if (delegate != nil) {
		[self.navigationController popViewControllerAnimated:YES];		
		[delegate loginWithResult:YES];
	}
	
    _isChangedImage = NO;
    self.memberCenter.view.hidden = NO;
	[self.view bringSubviewToFront:self.memberCenter.view];
	[memberCenter viewAppearAction];
    
    
    int num = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_newMessageNum] intValue];
    if (num > 0) 
    {
        UIView *msgTipView = [[UIView alloc] initWithFrame:CGRectMake(230,1,24,24)];
        msgTipView.tag = 22222;
        
        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
        {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            [tabViewController.customTab addSubview:msgTipView];
        }
        else
        {
            tabEntranceViewController *tabViewController = [arrayViewControllers objectAtIndex:0];
            [tabViewController.tabBar addSubview:msgTipView];
        }
            
        CGFloat fixWidth;
        if (num >= 100)
        {
            fixWidth = 34;
            if (num > 999) 
            {
                num = 999;
            }
        }
        else
        {
            fixWidth = 24;
        }
        
        UIImage *msgImg = [[UIImage imageNamed:@"小红点.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:24];
        UIImageView *msgImageView = [[UIImageView alloc] initWithImage:msgImg];
        msgImageView.frame = CGRectMake(0, 0, fixWidth, 24);
        msgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [msgTipView addSubview:msgImageView];
        
        NSString *msgNum = [NSString stringWithFormat:@"%d",num];
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:msgImageView.frame];
        msgLabel.text = msgNum;
        msgLabel.textColor = [UIColor whiteColor];
        msgLabel.font = [UIFont systemFontOfSize:14.0f];
        msgLabel.textAlignment = UITextAlignmentCenter;
        msgLabel.backgroundColor = [UIColor clearColor];
        [msgTipView addSubview:msgLabel];

    }
}

- (void)loginFail
{
	_isLogin = NO;
    memberCenter.view.hidden = YES;
	self.mbProgressHUD.hidden = YES;
	
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
	progressHUDTmp.delegate = self;
	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
	progressHUDTmp.mode = MBProgressHUDModeCustomView;
	progressHUDTmp.labelText = @"用户名和密码错误，请重新输入";
	[self.view addSubview:progressHUDTmp];
	[progressHUDTmp show:YES];
	[progressHUDTmp hide:YES afterDelay:1.5];
	[progressHUDTmp release];
	
	if (delegate != nil) {
		[delegate loginWithResult:NO];
	}
}

//- (void)changeAction
//{
//    MemberEditViewController *edit = [[MemberEditViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    [self.navigationController pushViewController:edit animated:YES];
//}

#pragma mark ----registerViewDelegate method
- (void)registerSuccess{
    [delegate loginWithResult:YES];
}
@end
