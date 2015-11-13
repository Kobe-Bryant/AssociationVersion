//
//  ZbarViewController.m
//  xieHui
//
//  Created by 来 云 on 12-11-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZbarViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DBOperate.h"
#import "FileManager.h"
#import "QRCodeGenerator.h"
#import "UIImageScale.h"
#import "alertView.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
@interface ZbarViewController ()

@end

@implementation ZbarViewController
@synthesize memberHeaderView;

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
    self.title = @"我的二维码";
	
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0f];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"名片背景" ofType:@"png"]];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - image.size.width) * 0.5, 20, image.size.width, image.size.height)];
    bgImageView.image = image;
    [self.view addSubview:bgImageView];
    [image release];
    
    //新增右上角保存按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];  
    saveButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [saveButton addTarget:self action:@selector(saveCode) forControlEvents:UIControlEventTouchDown];
    [saveButton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"保存按钮" ofType:@"png"]] forState:UIControlStateNormal];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    
    UIImageView *_cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20 , 10 , 50, 50)];
    [bgImageView addSubview:_cImageView];
    self.memberHeaderView = _cImageView;
    memberHeaderView.layer.masksToBounds = YES;
    memberHeaderView.layer.cornerRadius = 6;
    
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认头像" ofType:@"png"]];
    _cImageView.image = [img fillSize:CGSizeMake(50, 50)];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, 10, 60, 20)];
	nameLabel.text = @"";
	nameLabel.font = [UIFont systemFontOfSize:16.0f];
	nameLabel.tag = 100;
	nameLabel.textAlignment = UITextAlignmentLeft;
	nameLabel.backgroundColor = [UIColor clearColor];
	[bgImageView addSubview:nameLabel];
	[nameLabel release];
	
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 15, 10, 100, 20)];
	levelLabel.text = @"";
	levelLabel.font = [UIFont systemFontOfSize:14.0f];
	levelLabel.tag = 200;
	levelLabel.textAlignment = UITextAlignmentLeft;
	levelLabel.backgroundColor = [UIColor clearColor];
	[bgImageView addSubview:levelLabel];
	[levelLabel release];
    
	UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, 30, 200, 35)];
	companyLabel.text = @"";
	companyLabel.font = [UIFont systemFontOfSize:14.0f];
	companyLabel.tag = 300;
    companyLabel.numberOfLines = 2;
	companyLabel.textAlignment = UITextAlignmentLeft;
	companyLabel.backgroundColor = [UIColor clearColor];
	[bgImageView addSubview:companyLabel];
	[companyLabel release];

    
    UIImage *seporateImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
    UIImageView *seporateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_cImageView.frame) + 5, bgImageView.frame.size.width, seporateImage.size.height)];
    seporateImageView.image = seporateImage;
    [bgImageView addSubview:seporateImageView];
    [seporateImage release];
    [seporateImageView release];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(seporateImageView.frame) + 10, 180, 180)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [bgImageView addSubview:whiteView];
    CALayer *layer1=[whiteView layer];
    [layer1 setMasksToBounds:NO];
    [layer1 setCornerRadius:8.0];
    [layer1 setBorderWidth:1.0];
    [layer1 setBorderColor:[[UIColor whiteColor] CGColor]];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(whiteView.frame) + 5, 300, 30)];
    strLabel.text = @"快拍一下";
    strLabel.textColor = [UIColor blackColor];
    strLabel.backgroundColor = [UIColor clearColor];
    strLabel.textAlignment = UITextAlignmentCenter;
    [bgImageView addSubview:strLabel];
    [strLabel release];
    
    [bgImageView release];
    
    NSArray *ayArr = [[DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES] objectAtIndex:0];
    NSString *name = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_memberFirstName]];
    NSString *company = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_companyName]];
    NSString *post = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_post]];
    
    // dufu mod 2013.05.21
    NSString *mobile;
    if ([[ayArr objectAtIndex:member_info_mobile] length] > 0) {
        mobile = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_mobile]];
    } else {
        mobile = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_tel]];
    }
    
    NSString *email = [NSString stringWithFormat:@"%@",[ayArr objectAtIndex:member_info_email]];
    NSString *addr = [NSString stringWithFormat:@"%@%@%@%@",[ayArr objectAtIndex:member_info_province],[ayArr objectAtIndex:member_info_city],[ayArr objectAtIndex:member_info_district],[ayArr objectAtIndex:member_info_addr]];
    //NSLog(@"mobile = %@",mobile);
    NSString *infoStr = [NSString stringWithFormat:@"MECARD:N:%@;ORG:%@;TIL:%@;TEL:%@;EMAIL:%@;ADR:%@;;",name,company,post,mobile,email,addr];
    //NSLog(@"infoStr = %@",infoStr);
    
//    NSString *infoStr = @"MECARD:N:miss;ORG:sss;TIL:2ssss;TEL:1234567;EMAIL:qq@163.com;ADR:深圳南山;;";
    zbarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 140, 140)];
    [whiteView addSubview:zbarImageView];
    zbarImageView.backgroundColor = [UIColor clearColor];
    zbarImageView.image = [QRCodeGenerator qrImageForString:infoStr imageSize:zbarImageView.bounds.size.width];
    [whiteView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *dbArray = [DBOperate queryData:T_MEMBER_INFO theColumn:nil theColumnValue:nil withAll:YES];
	if ([dbArray count] != 0) {
		NSArray *ay = [dbArray objectAtIndex:0];
		
		UILabel *name = (UILabel *)[self.view viewWithTag:100];
		NSString *nameStr = [ay objectAtIndex:member_info_memberFirstName];
        name.text = nameStr;
        
        //名字间距
        NSString *nameString = nameStr;
        CGSize nameConstraint = CGSizeMake(20000.0f, 20.0f);
        CGSize nameSize = [nameString sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:nameConstraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat fixWidth = nameSize.width + 10.0f;
        
		NSString *levelStr = [ay objectAtIndex:member_info_post];
		UILabel *level = (UILabel *)[self.view viewWithTag:200];
        [level setFrame:CGRectMake(90 + fixWidth, 10, 100, 20)];
        level.text = levelStr;
        
		NSString *companyStr = [ay objectAtIndex:member_info_companyName];
		UILabel *company = (UILabel *)[self.view viewWithTag:300];
        company.text = companyStr;
        
        NSString *piclink = [ay objectAtIndex:member_info_image];

        NSString *photoname = [Common encodeBase64:(NSMutableData *)[piclink dataUsingEncoding: NSUTF8StringEncoding]];
        UIImage *img = [FileManager getPhoto:photoname];
        if (img != nil) {
            memberHeaderView.image = [img fillSize:CGSizeMake(50, 50)];
        }else {
//            if (piclink.length > 0) {
//                [self startIconDownload:piclink forIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
//            }
        }
    }
}

//保存二维码
-(void)saveCode
{
    UIImage *codeImage = zbarImageView.image;
   	if (codeImage == nil) 
    {
		[alertView showAlert:@"无法保存,二维码不存在"];
	}
	else 
    {
		UIImageWriteToSavedPhotosAlbum(codeImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [alertView showAlert:@"名片二维码已保存到本地相册"];
	} 
}

#pragma mark -
#pragma mark 保存图片委托

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; 
{
	if (!error)
    {
		NSLog(@"codeImage written success");
    }
	else
    {
		NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
    }
}

- (void)dealloc
{
    [memberHeaderView release];
    [zbarImageView release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
