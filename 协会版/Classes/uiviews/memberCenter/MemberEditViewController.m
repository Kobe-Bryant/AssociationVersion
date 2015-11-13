//
//  MemberEditViewController.m
//  xieHui
//
//  Created by 来 云 on 12-10-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemberEditViewController.h"
#import "ProfessionAppDelegate.h"
#import "DataManager.h"
#import "Encry.h"
#import "Common.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "imageDownLoadInWaitingObject.h"
#import "UIImageScale.h"
#import "CustomPicker.h"
#import <QuartzCore/QuartzCore.h>
#define kTableViewTag  100
@interface MemberEditViewController ()

@end

@implementation MemberEditViewController
@synthesize memberHeaderView;
@synthesize nameTextField = _nameTextField;
@synthesize sexTextField = _sexTextField;
@synthesize postTextField = _postTextField;
@synthesize companyTextField = _companyTextField;
@synthesize phoneTextField = _phoneTextField;
@synthesize emailTextField = _emailTextField;
@synthesize urlTextField = _urlTextField;
@synthesize addrTextField = _addrTextField;
@synthesize addressTextField = _addressTextField;

@synthesize nameTempContent = _nameTempContent;
@synthesize sexTempContent = _sexTempContent;
@synthesize postTempContent = _postTempContent;
@synthesize companyTempContent = _companyTempContent;
@synthesize phoneTempContent = _phoneTempContent;
@synthesize emailTempContent = _emailTempContent;
@synthesize urlTempContent = _urlTempContent;
@synthesize addrTempContent = _addrTempContent;
@synthesize addressTempContent = _addressTempContent;

@synthesize upload;
@synthesize scaleImage;
@synthesize mbProgressHUD;
@synthesize itemArray;
@synthesize sexValue;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isLogin = YES;
    self.title = @"会员编辑";
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(finishAction)];
    [self.navigationItem setRightBarButtonItem:barButton];
    
    content = [[NSArray alloc] initWithObjects:@"女士",@"先生",nil];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
    self.tableView.backgroundView = nil;
    
    itemArray = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
	if ([dbArray count] != 0)
    {
		self.itemArray = [dbArray objectAtIndex:0];
        
        provinceStr = [self.itemArray objectAtIndex:member_info_province];
        cityStr = [self.itemArray objectAtIndex:member_info_city];
        districtStr = [self.itemArray objectAtIndex:member_info_district];
        
        self.nameTempContent = [self.itemArray objectAtIndex:member_info_memberFirstName];
        self.sexTempContent = @"";
        self.postTempContent = [self.itemArray objectAtIndex:member_info_post];
        self.companyTempContent = [self.itemArray objectAtIndex:member_info_companyName];
        
        // dufu mod 2013.05.02
        if ([[self.itemArray objectAtIndex:member_info_mobile] length] > 0) {
            self.phoneTempContent = [self.itemArray objectAtIndex:member_info_mobile];
        } else {
            self.phoneTempContent = [self.itemArray objectAtIndex:member_info_tel];
        }
        
        self.emailTempContent = [self.itemArray objectAtIndex:member_info_email];
        self.urlTempContent = [self.itemArray objectAtIndex:member_info_url];
        self.addrTempContent = [NSString stringWithFormat:@"%@ %@ %@",provinceStr,cityStr,districtStr];
        self.addressTempContent = [self.itemArray objectAtIndex:member_info_addr];
    }
    else
    {
        self.nameTempContent = @"";
        self.sexTempContent = @"";
        self.postTempContent = @"";
        self.companyTempContent = @"";
        self.phoneTempContent = @"";
        self.emailTempContent = @"";
        self.urlTempContent = @"";
        self.addrTempContent = @"";
        self.addressTempContent = @"";
    }
}

- (void)dealloc
{
    memberHeaderView = nil;
    
    _nameTextField = nil;
    _sexTextField = nil;
    _postTextField = nil;
    _companyTextField = nil;
    _phoneTextField = nil;
    _emailTextField = nil;
    _urlTextField = nil;
    _addrTextField = nil;
    _addressTextField = nil;
    
    _nameTempContent = nil;
    _sexTempContent = nil;
    _postTempContent = nil;
    _companyTempContent = nil;
    _phoneTempContent = nil;
    _emailTempContent = nil;
    _urlTempContent = nil;
    _addrTempContent = nil;
    _addressTempContent = nil;
    
    pickerview = nil;
    content = nil;
    iconDownLoad = nil;
	imageDownloadsInProgress = nil;
	imageDownloadsInWaiting = nil;
    upload = nil;
	scaleImage = nil;
    mbProgressHUD = nil;
    itemArray = nil;
    _actionSheet = nil;
    
    provinceStr = nil;
    cityStr = nil;
    districtStr = nil;
    sexValue = nil;
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    memberHeaderView = nil;
    
    _nameTextField = nil;
    _sexTextField = nil;
    _postTextField = nil;
    _companyTextField = nil;
    _phoneTextField = nil;
    _emailTextField = nil;
    _urlTextField = nil;
    _addrTextField = nil;
    _addressTextField = nil;
    
    _nameTempContent = nil;
    _sexTempContent = nil;
    _postTempContent = nil;
    _companyTempContent = nil;
    _phoneTempContent = nil;
    _emailTempContent = nil;
    _urlTempContent = nil;
    _addrTempContent = nil;
    _addressTempContent = nil;
    
    pickerview = nil;
    content = nil;
    iconDownLoad = nil;
	imageDownloadsInProgress = nil;
	imageDownloadsInWaiting = nil;
    upload = nil;
	scaleImage = nil;
    mbProgressHUD = nil;
    itemArray = nil;
    _actionSheet = nil;
    
    provinceStr = nil;
    cityStr = nil;
    districtStr = nil;
    sexValue = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return tableView.tag == kTableViewTag ? 3 : 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView.tag == kTableViewTag  ? 0 : 135;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //ios7新特性,解决分割线短一点
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (tableView.tag == kTableViewTag) {
        switch (indexPath.row) {
            case 0:
            {
                UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 190, 35)];
                nameText.delegate = self;
                self.nameTextField = nameText;
                _nameTextField.borderStyle = UITextBorderStyleNone;
                _nameTextField.backgroundColor = [UIColor clearColor];
                _nameTextField.font = [UIFont systemFontOfSize:14.0f];
                _nameTextField.returnKeyType = UIReturnKeyNext;
                _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_nameTextField];
                [nameText release];
                self.nameTextField.text = _nameTempContent;
            }break;
            case 1:
            {
                _sexTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 190, 35)];
                _sexTextField.tag = 1;
                _sexTextField.borderStyle = UITextBorderStyleNone;
                _sexTextField.placeholder = @"称呼";
                _sexTextField.backgroundColor = [UIColor clearColor];
                _sexTextField.font = [UIFont systemFontOfSize:14.0f];
                [self.sexTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_sexTextField];
                
                if ([[self.itemArray objectAtIndex:member_info_sex] intValue] == 1) {
                    self.sexTextField.text = @"先生";
                }else {
                    self.sexTextField.text = @"女士";
                }
                
                UIButton *btn = [UIButton buttonWithType:0];
                [btn addTarget:self action:@selector(selectSex) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = _sexTextField.bounds;
                [cell.contentView addSubview:btn];
            }break;
            case 2:
            {
                _postTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 190, 35)];
                _postTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                _postTextField.borderStyle = UITextBorderStyleNone;
                _postTextField.placeholder = @"职务";
                _postTextField.delegate = self;
                _postTextField.backgroundColor = [UIColor clearColor];
                _postTextField.font = [UIFont systemFontOfSize:14.0f];
                _postTextField.returnKeyType = UIReturnKeyNext;
                _postTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.postTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_postTextField];
                
                self.postTextField.text = _postTempContent;
            }break;
                
            default:
                break;
        }
    }else {
        switch (indexPath.row) {
            case 0:
            {
                UILabel *phone = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                phone.text = @"电话";
                phone.font = [UIFont systemFontOfSize:14.0f];
                phone.textAlignment = UITextAlignmentLeft;
                phone.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:phone];
                [phone release];
                
                UITextField *phoneText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(phone.frame), 0, 230, 35)];
                phoneText.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.phoneTextField = phoneText;
                _phoneTextField.delegate = self;
                _phoneTextField.borderStyle = UITextBorderStyleNone;
                _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
                _phoneTextField.backgroundColor = [UIColor clearColor];
                _phoneTextField.font = [UIFont systemFontOfSize:14.0f];
                _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.phoneTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_phoneTextField];
                [phoneText release];
                
                self.phoneTextField.text = _phoneTempContent;
            }
                break;
            case 1:
            {
                UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                name.text = @"邮箱";
                name.font = [UIFont systemFontOfSize:14.0f];
                name.textAlignment = UITextAlignmentLeft;
                name.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:name];
                [name release];
                
                UITextField *faxText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 0, 230, 35)];
                self.emailTextField = faxText;
                _emailTextField.delegate = self;
                _emailTextField.borderStyle = UITextBorderStyleNone;
                _emailTextField.backgroundColor = [UIColor clearColor];
                _emailTextField.font = [UIFont systemFontOfSize:14.0f];
                _emailTextField.returnKeyType = UIReturnKeyNext;
                _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_emailTextField];
                [faxText release];
                
                self.emailTextField.text = _emailTempContent;
            }
                break;
            case 2:
            {
                UILabel *phone = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                phone.text = @"公司";
                phone.font = [UIFont systemFontOfSize:14.0f];
                phone.textAlignment = UITextAlignmentLeft;
                phone.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:phone];
                [phone release];
                
                _companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(phone.frame), 0, 230, 35)];
                _companyTextField.borderStyle = UITextBorderStyleNone;
                //_companyTextField.placeholder = @"公司";
                _companyTextField.delegate = self;
                _companyTextField.backgroundColor = [UIColor clearColor];
                _companyTextField.font = [UIFont systemFontOfSize:14.0f];
                _companyTextField.returnKeyType = UIReturnKeyNext;
                _companyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.companyTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_companyTextField];
                
                self.companyTextField.text = _companyTempContent;
            }break;
            case 3:
            {
                UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                name.text = @"网址";
                name.font = [UIFont systemFontOfSize:14.0f];
                name.textAlignment = UITextAlignmentLeft;
                name.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:name];
                [name release];
                
                UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 0, 230, 35)];
                self.urlTextField = nameText;
                _urlTextField.delegate = self;
                _urlTextField.borderStyle = UITextBorderStyleNone;
                _urlTextField.backgroundColor = [UIColor clearColor];
                _urlTextField.font = [UIFont systemFontOfSize:14.0f];
                _urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.urlTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_urlTextField];
                [nameText release];
                
                self.urlTextField.text = _urlTempContent;
            }
                break;
            case 4:
            {
                UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                name.text = @"地区";
                name.font = [UIFont systemFontOfSize:14.0f];
                name.textAlignment = UITextAlignmentLeft;
                name.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:name];
                [name release];
                
                UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 0, 250, 35)];
                self.addrTextField = nameText;
                _addrTextField.tag = 2;
                _addrTextField.borderStyle = UITextBorderStyleNone;
                _addrTextField.backgroundColor = [UIColor clearColor];
                _addrTextField.font = [UIFont systemFontOfSize:14.0f];
                _addrTextField.enabled = NO;
                [self.addrTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_addrTextField];
                
                self.addrTextField.text = _addrTempContent;
                
                UIButton *btn = [UIButton buttonWithType:0];
                [btn addTarget:self action:@selector(selectCity) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = _addrTextField.bounds;
                [cell.contentView addSubview:btn];
                
            }
                break;
            case 5:
            {
                UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 35)];
                name.text = @"地址";
                name.font = [UIFont systemFontOfSize:14.0f];
                name.textAlignment = UITextAlignmentLeft;
                name.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:name];
                [name release];
                
                UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame), 0, 230, 35)];
                nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
                self.addressTextField = nameText;
                _addressTextField.delegate = self;
                _addressTextField.borderStyle = UITextBorderStyleNone;
                _addressTextField.backgroundColor = [UIColor clearColor];
                _addressTextField.font = [UIFont systemFontOfSize:14.0f];
                _addressTextField.returnKeyType = UIReturnKeyDone;
                _addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [self.addressTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [cell.contentView addSubview:_addressTextField];
                [nameText release];
                
                self.addressTextField.text = _addressTempContent;
            }
                break;
            default:
                break;
        }
        
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag != kTableViewTag) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 135)];
        headView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
        
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 80, 80)];
        self.memberHeaderView = headerImageView;
        [headView addSubview:memberHeaderView];
        [headerImageView release];
        memberHeaderView.userInteractionEnabled = YES;
        memberHeaderView.layer.masksToBounds = YES;
        memberHeaderView.layer.cornerRadius = 8;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
        [headerImageView addGestureRecognizer:tapGesture];
        tapGesture.delegate = self;
        [tapGesture release];
        
        UIImage *newsimage = [[UIImage alloc]initWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"编辑头像默认图片" ofType:@"png"]];
        memberHeaderView.image = [newsimage fillSize:CGSizeMake(80, 80)];
        [newsimage release];
        
        ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
        memberHeaderView.image = [deleagte.headerImage fillSize:CGSizeMake(80, 80)];
        
        UIImage *cellBGImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"会员中心电话列表上" ofType:@"png"]];
        
        UITableView *tab = [[UITableView alloc] initWithFrame:CGRectMake(320-cellBGImage.size.width - 10,10, cellBGImage.size.width + 10, 120) style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        tab.scrollEnabled = NO;
        tab.tag = kTableViewTag;
        tab.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
        tab.backgroundView = nil;
        
        if (IOS_VERSION >= 7.0) {
            tab.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tab.bounds.size.width, 10.f)];
        }
        
        [headView addSubview:tab];
        
        return headView;
    }else {
        return nil;
    }
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

#pragma mark ----UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
        [self.postTextField becomeFirstResponder];
    }
    if (textField == self.postTextField) {
        [self.postTextField resignFirstResponder];
        [self.phoneTextField becomeFirstResponder];
    }
    if (textField == self.companyTextField) {
        [self.companyTextField resignFirstResponder];
        [self.urlTextField becomeFirstResponder];
    }
    if (textField == self.phoneTextField) {
        [self.phoneTextField resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
    }
    if (textField == self.emailTextField) {
        [self.emailTextField resignFirstResponder];
        [self.companyTextField becomeFirstResponder];
    }
    if (textField == self.urlTextField) {
        [self.urlTextField resignFirstResponder];
        [self.addressTextField becomeFirstResponder];
    }
    if (textField == self.addressTextField) {
        [self.addressTextField resignFirstResponder];
        
    }
    
    return YES;
}

#pragma mark -
#pragma mark TextView
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField)
    {
        self.nameTempContent = textField.text;
    }
    
    if (textField == self.sexTextField)
    {
        self.sexTempContent = textField.text;
    }
    
    if (textField == self.postTextField)
    {
        self.postTempContent = textField.text;
    }
    
    if (textField == self.companyTextField)
    {
        self.companyTempContent = textField.text;
    }
    
    if (textField == self.phoneTextField)
    {
        self.phoneTempContent = textField.text;
    }
    
    if (textField == self.emailTextField)
    {
        self.emailTempContent = textField.text;
    }
    
    if (textField == self.urlTextField)
    {
        self.urlTempContent = textField.text;
    }
    
    if (textField == self.addrTextField)
    {
        self.addrTempContent = textField.text;
    }
    
    if (textField == self.addressTextField)
    {
        self.addressTempContent = textField.text;
    }
    
    return YES;
}

- (void)selectCity{
    [self hideKeyboard];
    TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:nil delegate:self];
    locateView.tag = 120;
    
    NSArray *arr = [self.addrTextField.text componentsSeparatedByString:@" "];
    locateView.strArray = arr;
    
    ProfessionAppDelegate *delegate =  (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
    [locateView showInView:delegate.window];
}

- (void)selectSex{
    [self hideKeyboard];
    
    ProfessionAppDelegate *delegate =  (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
    
    CustomPicker *picker = [[CustomPicker alloc] initWithTitle:nil withFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 130) delegate:self PickerArray:[NSMutableArray arrayWithObjects:@"先生",@"女士", nil] Obj:self.sexTextField];
    picker.delegate  = self;
    picker.tag = 109;
    [picker showInDelegateView:delegate.window];
    [picker release];
}
#pragma mark -----UIPickerViewDelegate methods
// 返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}
// 返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [content count];
}
// 设置当前行的内容，若果行没有显示则自动释放
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [content objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //NSString *result = [pickerView pickerView:pickerView titleForRow:row forComponent:component];
    NSString  *result = nil;
    result = [content objectAtIndex:row];
    //NSLog(@"result: %@",result);
    self.sexTextField.text = result;
    [result release];
    [pickerview resignFirstResponder];
}

#pragma mark ----UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 109) {
        CustomPicker *picker = (CustomPicker *)actionSheet;
        [picker.displayLabel removeFromSuperview];
        
    }else{
        
        
        if (actionSheet.tag == 120) {
            TSLocateView *tt = (TSLocateView *)actionSheet;
            
            _addrTextField.text = [NSString stringWithFormat:@"%@ %@ %@",tt.locate.country,tt.locate.city,tt.locate.state];
            
            self.addrTempContent = [NSString stringWithFormat:@"%@ %@ %@",tt.locate.country,tt.locate.city,tt.locate.state];
            
            provinceStr = tt.locate.country;
            cityStr = tt.locate.city;
            districtStr = tt.locate.state;
        }else {
            UIImagePickerController *myPicker  = [[UIImagePickerController alloc] init];
            
            myPicker.delegate = self;
            myPicker.editing = YES;
            switch (buttonIndex) {
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
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        [navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    }
}

- (void)dismissActionSheet{
    [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark -----UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    //	if(picker.sourceType==UIImagePickerControllerSourceTypeCamera){
    //
    //		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否上传到服务器？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    //		[alert show];
    //		[alert release];
    //
    //		[self dismissModalViewControllerAnimated:YES];
    //
    //	}else {
    //
    //
    //		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否上传到服务器？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    //		[alert show];
    //		[alert release];
    //
    //		[picker dismissModalViewControllerAnimated:YES];
    //    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    [picker dismissModalViewControllerAnimated:YES];
    
    _isChangedImage = YES;
    ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
    deleagte.headerImage = image;
    memberHeaderView.image = [image fillSize:CGSizeMake(80, 80)];
    self.scaleImage = [image fillSize:CGSizeMake(80, 80)];
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    self.mbProgressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.mbProgressHUD.delegate = self;
    self.mbProgressHUD.labelText = @"正在上传...";
    [self.view addSubview:self.mbProgressHUD];
    [self.mbProgressHUD show:YES];
    
    int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
    NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        [NSNumber numberWithInt:1],@"edition",nil];
    
    NSString *reqstr = [Common TransformJson:jsontestDic withLinkStr: [ACCESS_SERVER_LINK stringByAppendingString:@"member/updateinfo.do?param=%@"]];
    //self.scaleImage = [self.img scaleToSize:CGSizeMake(75, 75)];
    NSData *pictureData =UIImagePNGRepresentation(self.scaleImage);
    upload = [[EPUploader alloc] initWithURL:[NSURL URLWithString:reqstr] filePath:pictureData delegate:self doneSelector:@selector(onUploadDone:) errorSelector:@selector(onUploadError:)];
    upload.uploaderDelegate = self;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
}

//#pragma mark ------UIAlertViewDelegate methods
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//
//	if (buttonIndex == 0) {
//
//        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
//		self.mbProgressHUD = progressHUDTmp;
//		[progressHUDTmp release];
//		self.mbProgressHUD.delegate = self;
//		self.mbProgressHUD.labelText = @"正在上传...";
//		[self.view addSubview:self.mbProgressHUD];
//		[self.mbProgressHUD show:YES];
//
//		int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
//
//		NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                            [Common getSecureString],@"keyvalue",
//                                            [NSNumber numberWithInt: SITE_ID],@"site_id",
//                                            [NSNumber numberWithInt:_userId],@"user_id",
//                                            [NSNumber numberWithInt:1],@"edition",nil];
//
//		NSString *reqstr = [Common TransformJson:jsontestDic withLinkStr: [ACCESS_SERVER_LINK stringByAppendingString:@"member/updateinfo.do?param=%@"]];
//        //self.scaleImage = [self.img scaleToSize:CGSizeMake(75, 75)];
//        NSData *pictureData =UIImagePNGRepresentation(self.scaleImage);
//        upload = [[EPUploader alloc] initWithURL:[NSURL URLWithString:reqstr] filePath:pictureData delegate:self doneSelector:@selector(onUploadDone:) errorSelector:@selector(onUploadError:)];
//	    upload.uploaderDelegate = self;
//	}
//}

#pragma mark ---EPUploaderDelegate method
- (void)receiveResult:(NSString *)result
{
	NSDictionary *resultDic = [result JSONValue];
	NSLog(@"resultDic===%@",resultDic);
	NSString *retStr = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
	NSString *urlStr = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"url"]];
	if ([retStr isEqualToString:@"1"] && urlStr != nil) {
        
		NSArray *dbArr = [[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0];
		NSString *name = [dbArr objectAtIndex:member_info_name];
		NSString *userId = [NSString stringWithFormat:@"%d",[[dbArr objectAtIndex:member_info_memberId] intValue]];
        
		NSString *photoname = [Common encodeBase64:(NSMutableData *)[urlStr dataUsingEncoding: NSUTF8StringEncoding]];
        
        //NSString *piclink = @"http://192.168.1.180:8080/HY_APPInterfaceServer/user-pic/1/100/monkey-1348452072613.png";
		
		if ([FileManager savePhoto:photoname withImage:self.scaleImage]) {
			[DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"image" theColumnValue:urlStr ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
		}
	}
}

- (void) onUploadDone:(id)sender{
    
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];
	
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
	progressHUDTmp.delegate = self;
	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
	progressHUDTmp.mode = MBProgressHUDModeCustomView;
	progressHUDTmp.labelText = @"上传成功";
	[self.view addSubview:progressHUDTmp];
	[progressHUDTmp show:YES];
	[progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}
- (void) onUploadError:(id)sender{
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];
	
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
	progressHUDTmp.delegate = self;
	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
	progressHUDTmp.mode = MBProgressHUDModeCustomView;
	progressHUDTmp.labelText = @"上传失败";
	[self.view addSubview:progressHUDTmp];
	[progressHUDTmp show:YES];
	[progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

#pragma mark ---- loadImage Method
- (void)startIconDownload:(NSString*)imageURL forIndex:(NSIndexPath*)index
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader == nil && imageURL != nil && imageURL.length > 1)
    {
		if ([imageDownloadsInProgress count] >= DOWNLOAD_IMAGE_MAX_COUNT) {
            imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:imageURL withIndexPath:index withImageType:CUSTOMER_PHOTO];
            [imageDownloadsInWaiting addObject:one];
            [one release];
            return;
        }
        
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = imageURL;
        iconDownloader.indexPathInTableView = index;
        iconDownloader.imageType = CUSTOMER_PHOTO;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:index];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
        {
            //保存图片
            //UIImage *photo = iconDownloader.cardIcon;
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(80, 80)];
            NSString *url = [[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_image];
            
            NSString *photoname = [Common encodeBase64:(NSMutableData *)[url dataUsingEncoding: NSUTF8StringEncoding]];
            
            [FileManager savePhoto:photoname withImage:photo];
            memberHeaderView.image = photo;
            
            ProfessionAppDelegate *deleagte = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
            deleagte.headerImage = photo;
        }
		
		[imageDownloadsInProgress removeObjectForKey:indexPath];
		if ([imageDownloadsInWaiting count] > 0) {
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndex:one.indexPath];
			[imageDownloadsInWaiting removeObjectAtIndex:0];
		}
		
    }
}


#pragma mark-----private method
- (void)finishAction
{
    [self hideKeyboard];
    
    if (_nameTextField.text.length == 0) {
		MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		progressHUDTmp.delegate = self;
		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		progressHUDTmp.mode = MBProgressHUDModeCustomView;
		progressHUDTmp.labelText = @"姓名不能为空";
		[self.view addSubview:progressHUDTmp];
		[self.view bringSubviewToFront:progressHUDTmp];
		[progressHUDTmp show:YES];
		[progressHUDTmp hide:YES afterDelay:1];
	}else if (_sexTextField.text.length == 0) {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		progressHUDTmp.delegate = self;
		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		progressHUDTmp.mode = MBProgressHUDModeCustomView;
		progressHUDTmp.labelText = @"性别不能为空";
		[self.view addSubview:progressHUDTmp];
		[self.view bringSubviewToFront:progressHUDTmp];
		[progressHUDTmp show:YES];
		[progressHUDTmp hide:YES afterDelay:1];
    }else if (_phoneTextField.text.length > 0 && [[self checkTelNumberFormart:_phoneTextField.text] isEqualToString:@"格式不对"]) {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		progressHUDTmp.delegate = self;
		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		progressHUDTmp.mode = MBProgressHUDModeCustomView;
		progressHUDTmp.labelText = @"输入的电话号码格式不对";
        
		[self.view addSubview:progressHUDTmp];
		[self.view bringSubviewToFront:progressHUDTmp];
		[progressHUDTmp show:YES];
		[progressHUDTmp hide:YES afterDelay:1];
        
        //self.phoneTextField.text = @"";
        self.postTempContent = @"";
    }else if (([self checkEmail:_emailTextField.text] == NO) && _emailTextField.text.length > 0) {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		progressHUDTmp.delegate = self;
		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		progressHUDTmp.mode = MBProgressHUDModeCustomView;
		progressHUDTmp.labelText = @"请填写正确格式的邮箱";
		[self.view addSubview:progressHUDTmp];
		[self.view bringSubviewToFront:progressHUDTmp];
		[progressHUDTmp show:YES];
		[progressHUDTmp hide:YES afterDelay:1];
    }else if (_addrTextField.text.length == 0) {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
		progressHUDTmp.delegate = self;
		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
		progressHUDTmp.mode = MBProgressHUDModeCustomView;
		progressHUDTmp.labelText = @"地区不能为空";
		[self.view addSubview:progressHUDTmp];
		[self.view bringSubviewToFront:progressHUDTmp];
		[progressHUDTmp show:YES];
		[progressHUDTmp hide:YES afterDelay:1];
    }
    //    else if (_addressTextField.text.length == 0) {
    //        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    //		progressHUDTmp.delegate = self;
    //		progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
    //		progressHUDTmp.mode = MBProgressHUDModeCustomView;
    //		progressHUDTmp.labelText = @"地址不能为空";
    //		[self.view addSubview:progressHUDTmp];
    //		[self.view bringSubviewToFront:progressHUDTmp];
    //		[progressHUDTmp show:YES];
    //		[progressHUDTmp hide:YES afterDelay:1];
    //    }
    else {
        [self accessService];
        
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
        self.mbProgressHUD = progressHUDTmp;
        [progressHUDTmp release];
        self.mbProgressHUD.delegate = self;
        self.mbProgressHUD.labelText = @"正在提交...";
        [self.view addSubview:self.mbProgressHUD];
        [self.mbProgressHUD show:YES];
    }
    
}

- (void)changeImage
{
    [self hideKeyboard];
    
    UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中上传", nil];
    [action showInView:((ProfessionAppDelegate *)[UIApplication sharedApplication].delegate).window];
	[action release];
}

- (void)accessService
{
    if (self.phoneTextField.text.length > 0) {
        self.phoneTempContent = [self checkTelNumberFormart:self.phoneTextField.text];
    }else {
        self.phoneTempContent = @"";
    }
    
	int _userId = [[[[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0] objectAtIndex:member_info_memberId] intValue];
    
    if ([self.sexTextField.text isEqualToString:@"先生"]) {
        sexValue = @"1";
    }else {
        sexValue = @"0";
    }
	NSMutableDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [Common getSecureString],@"keyvalue",
                                        [NSNumber numberWithInt: SITE_ID],@"site_id",
                                        [NSNumber numberWithInt:_userId],@"user_id",
                                        self.nameTextField.text,@"name",
                                        self.emailTextField.text,@"email",
                                        [NSNumber numberWithInt:[sexValue intValue]],@"gender",
                                        self.postTextField.text,@"post",
                                        self.companyTextField.text,@"company_name",
                                        self.phoneTempContent,@"tel",
                                        self.urlTextField.text,@"url",
                                        provinceStr,@"province",
                                        cityStr,@"city",
                                        districtStr,@"district",
                                        self.addrTextField.text,@"city",
                                        self.addressTextField.text,@"address",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic command:MEMBER_EDIT_COMMAND_ID accessAdress:@"member/edit.do?param=%@" delegate:self withParam:jsontestDic];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
	switch (commandid) {
		case MEMBER_EDIT_COMMAND_ID:
		{
            NSString *resultstr = [[resultArray objectAtIndex:0] objectAtIndex:0];
            if ([resultstr isEqualToString:@"1"]) {
                [self performSelectorOnMainThread:@selector(editSuccess) withObject:nil waitUntilDone:NO];
            }else {
                [self performSelectorOnMainThread:@selector(editFail) withObject:nil waitUntilDone:NO];
            }
		}break;
        default:
			break;
	}
	
    //	if (progressHUD != nil) {
    //		[progressHUD removeFromSuperViewOnHide];
    //	}
}

- (void)editSuccess
{
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];
	
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
	progressHUDTmp.delegate = self;
	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-ok.png"]] autorelease];
	progressHUDTmp.mode = MBProgressHUDModeCustomView;
	progressHUDTmp.labelText = @"提交成功";
	[self.view addSubview:progressHUDTmp];
	[progressHUDTmp show:YES];
	[progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
    
    //    NSString *userId = [self.itemArray objectAtIndex:member_info_memberId];
    //    NSLog(@"userId=====%@",userId);
    //    NSLog(@"userId=====%@",_nameTextField.text);
    //    NSLog(@"userId=====%@",_postTextField.text);
    //    NSLog(@"userId=====%@",_companyTextField.text);
    //    NSLog(@"userId=====%@",_telTextField.text);
    //    NSLog(@"userId=====%@",_phoneTextField.text);
    //    NSLog(@"userId=====%@",provinceStr);
    //    NSLog(@"userId=====%@",cityStr);
    //    NSLog(@"userId=====%@",_addressTextField.text);
    
    NSArray *dbArr = [[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0];
    NSString *name = [dbArr objectAtIndex:member_info_name];
    NSString *userId = [NSString stringWithFormat:@"%d",[[dbArr objectAtIndex:member_info_memberId] intValue]];
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"memberFirstName" theColumnValue:_nameTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"sex" theColumnValue:sexValue ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"post" theColumnValue:_postTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"companyName" theColumnValue:_companyTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"tel" theColumnValue:self.phoneTempContent ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"email" theColumnValue:_emailTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"url" theColumnValue:_urlTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"province" theColumnValue:provinceStr ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"city" theColumnValue:cityStr ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"district" theColumnValue:districtStr ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    [DBOperate updateWithTwoConditions:T_MEMBER_INFO theColumn:@"addr" theColumnValue:_addressTextField.text ColumnOne:@"memberId" valueOne:userId columnTwo:@"memberName" valueTwo:name];
    
    
    
    //    [self.itemArray replaceObjectAtIndex:member_info_tel withObject:_phoneTextField.text];
    //    [self.itemArray replaceObjectAtIndex:member_info_email withObject:_emailTextField.text];
    //    [self.itemArray replaceObjectAtIndex:member_info_url withObject:_urlTextField.text];
    //    [self.itemArray replaceObjectAtIndex:member_info_province withObject:provinceStr];
    //    [self.itemArray replaceObjectAtIndex:member_info_city withObject:cityStr];
    //    [self.itemArray replaceObjectAtIndex:member_info_district withObject:districtStr];
    //    [self.itemArray replaceObjectAtIndex:member_info_addr withObject:_addressTextField.text];
    //    [DBOperate deleteData:T_MEMBER_INFO];
    //    [DBOperate insertDataWithnotAutoID:self.itemArray tableName:T_MEMBER_INFO];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)editFail
{
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];
	
	MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
	progressHUDTmp.delegate = self;
	progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
	progressHUDTmp.mode = MBProgressHUDModeCustomView;
	progressHUDTmp.labelText = @"提交失败";
	[self.view addSubview:progressHUDTmp];
	[progressHUDTmp show:YES];
	[progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

- (void)hideKeyboard
{
    [_nameTextField resignFirstResponder];
    [_postTextField resignFirstResponder];
    [_companyTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_urlTextField resignFirstResponder];
    [_addressTextField resignFirstResponder];
}

- (BOOL)checkEmail:(NSString *)str{
    NSArray *arr=[str componentsSeparatedByString:@"@"];
    
    if (arr.count>1) {
        NSString *str1=[arr objectAtIndex:0];
        NSString *str2=[arr objectAtIndex:1];
        NSArray *arr1=[str2 componentsSeparatedByString:@"."];
        
        if (str1.length>1&&str2.length>1) {
            if (arr1.count>1) {
                NSString *str3=[arr1 objectAtIndex:0];
                NSString *str4=[arr1 objectAtIndex:1];
                
                if (str3.length>1&&str4.length>1) {
                    return YES;
                }else {
                    return NO;
                }
            }else {
                return NO;
            }
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

- (NSString *)checkTel:(NSString *)str{
    
    return nil;
}

- (NSString *)checkTelNumberFormart:(NSString *)phoneNumber
{
    
    NSArray *array = [phoneNumber componentsSeparatedByString:@"-"];
    NSString *str = @"";
    for (int i = 0; i<array.count; i++) {
        str = [str stringByAppendingString:[array objectAtIndex:i]];
    }
    
    phoneNumber = str;
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    //NSString * PHS = @"^(01[0-9]|02[0-9]|0[3-9][0-9]{2})?([2-9][0-9]{6,7})+(\\[0-9]{1,4})?$";
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestphs= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if ([regextestmobile evaluateWithObject:phoneNumber] == YES)
    {
        NSMutableString *newNum = [NSMutableString string];
        [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(0, 3)]];
        [newNum appendString:@"-"];
        [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(3, 4)]];
        [newNum appendString:@"-"];
        [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(7, 4)]];
        return newNum;
    }else if([regextestphs evaluateWithObject:phoneNumber] == YES){
        if ([[phoneNumber substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"] || [[phoneNumber substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"02"]) {
            NSMutableString *newNum = [NSMutableString string];
            [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(0, 3)]];
            [newNum appendString:@"-"];
            [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(3, phoneNumber.length - 3)]];
            return newNum;
        }else{
            NSMutableString *newNum = [NSMutableString string];
            [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(0, 4)]];
            [newNum appendString:@"-"];
            [newNum appendString:[phoneNumber substringWithRange:NSMakeRange(4, phoneNumber.length - 4)]];
            return newNum;
        }
    }
    else
    {
        return @"格式不对";
    }
}
@end
