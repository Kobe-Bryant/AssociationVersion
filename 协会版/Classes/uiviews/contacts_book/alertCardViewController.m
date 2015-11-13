//
//  alertCardViewController.m
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "alertCardViewController.h"
#import "newestMemberViewController.h"
#import "callSystemApp.h"
#import "Common.h"

@interface alertCardViewController ()

@end

@implementation alertCardViewController

@synthesize cardInfo;
@synthesize cardDetail;
@synthesize cUserId;
@synthesize mobileStr;
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)frame info:(NSMutableArray *)cInfo userID:(NSString *)userId{
	if ((self = [super initWithFrame:frame])) {
        
        self.cardInfo = cInfo;
        self.cUserId = userId;
        
		self.headerLabel.text = @"";

        // Margin between edge of container frame and panel. Default = 20.0
        self.outerMarginX = 10.0f;
        self.outerMarginY = ([UIScreen mainScreen].bounds.size.height - 300.0f) / 2;
        
        // Margin between edge of panel and the content area. Default = 20.0
        self.innerMargin = 0.0f;
        
        // Border color of the panel. Default = [UIColor whiteColor]
        self.borderColor = [UIColor clearColor];
        
        // Border width of the panel. Default = 1.5f;
        self.borderWidth = 0.0f;
        
        // Corner radius of the panel. Default = 4.0f
        self.cornerRadius = 10.0f;
        
        // Color of the panel itself. Default = [UIColor colorWithWhite:0.0 alpha:0.8]
        self.contentColor = [UIColor  colorWithPatternImage:[UIImage imageNamed:@"名片背景.png" ]];;
        
        // Shows the bounce animation. Default = YES
        self.shouldBounce = YES;
        
        // Height of the title view. Default = 40.0f
        [self setTitleBarHeight:0];
        
        // The gradient style (Linear, linear reversed, radial, radial reversed, center highlight). Default = UAGradientBackgroundStyleLinear
        [[self titleBar] setGradientStyle:(0)];
        
        // The line mode of the gradient view (top, bottom, both, none). Top is a white line, bottom is a black line.
        [[self titleBar] setLineMode: pow(2, 0)];
        
        // The noise layer opacity. Default = 0.4
        //[[self titleBar] setNoiseOpacity:(((arc4random() % 10) + 1) * 0.1)];
        
        // The header label, a UILabel with the same frame as the titleBar
        //[self headerLabel].font = [UIFont boldSystemFontOfSize:floor(self.titleBarHeight / 2.0)];
        
        
		//////////////////////////////////////
		// SETUP RANDOM CONTENT
		//////////////////////////////////////
        
        cardDetailViewController *tempCardDetail = [[cardDetailViewController alloc] init];
        tempCardDetail.cardInfo = self.cardInfo;
        tempCardDetail.cUserId = self.cUserId;
        [tempCardDetail.view setFrame:CGRectMake( 0.0f , 0.0f , 320.0f , 320.0f)];
        
        self.cardDetail = tempCardDetail;
        self.cardDetail.delegate = self;
        [tempCardDetail release];
        [self.contentView addSubview:self.cardDetail.view];
        
	}	
	return self;
}

- (id)initWithFrame:(CGRect)frame  withContent:(NSString *)str withMobile:(NSString *)mobile{
	if ((self = [super initWithFrame:frame])) {
        
		self.headerLabel.text = @"";
        
        // Margin between edge of container frame and panel. Default = 20.0
        self.outerMarginX = 10.0f;
        self.outerMarginY = ([UIScreen mainScreen].bounds.size.height - 300.0f) / 2;
        
        // Margin between edge of panel and the content area. Default = 20.0
        self.innerMargin = 0.0f;
        
        // Border color of the panel. Default = [UIColor whiteColor]
        self.borderColor = [UIColor clearColor];
        
        // Border width of the panel. Default = 1.5f;
        self.borderWidth = 0.0f;
        
        // Corner radius of the panel. Default = 4.0f
        self.cornerRadius = 10.0f;
        
        // Color of the panel itself. Default = [UIColor colorWithWhite:0.0 alpha:0.8]
        self.contentColor = [UIColor  colorWithPatternImage:[UIImage imageNamed:@"名片背景.png" ]];;
        
        // Shows the bounce animation. Default = YES
        self.shouldBounce = YES;
        
        // Height of the title view. Default = 40.0f
        [self setTitleBarHeight:0];
        
        // The gradient style (Linear, linear reversed, radial, radial reversed, center highlight). Default = UAGradientBackgroundStyleLinear
        [[self titleBar] setGradientStyle:(0)];
        
        // The line mode of the gradient view (top, bottom, both, none). Top is a white line, bottom is a black line.
        [[self titleBar] setLineMode: pow(2, 0)];
        
        // The noise layer opacity. Default = 0.4
        //[[self titleBar] setNoiseOpacity:(((arc4random() % 10) + 1) * 0.1)];
        
        // The header label, a UILabel with the same frame as the titleBar
        //[self headerLabel].font = [UIFont boldSystemFontOfSize:floor(self.titleBarHeight / 2.0)];
        
        
		//////////////////////////////////////
		// SETUP RANDOM CONTENT
		//////////////////////////////////////
        
        self.mobileStr = mobile;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 35,120,25 )];
        label1.text = TIPS_REG_CONTENT1;
        label1.font = [UIFont systemFontOfSize:16.0f];
        label1.textAlignment = UITextAlignmentRight;
        label1.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        label1.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label1];
        [label1 release];  
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), 35,160,25 )];
        label2.text = str;
        label2.font = [UIFont boldSystemFontOfSize:18.0f];
        label2.textAlignment = UITextAlignmentLeft;
        label2.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        label2.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label2];
        [label2 release];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(label2.frame) ,280,25 )];
        label3.text = TIPS_REG_CONTENT2;
        label3.font = [UIFont systemFontOfSize:16.0f];
        label3.textAlignment = UITextAlignmentLeft;
        label3.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        label3.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label3];
        [label3 release];
        
        UILabel *label31 = [[UILabel alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(label3.frame) ,280,25 )];
        label31.text = TIPS_REG_CONTENT3;
        label31.font = [UIFont systemFontOfSize:16.0f];
        label31.textAlignment = UITextAlignmentLeft;
        label31.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        label31.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label31];
        [label31 release];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(32,CGRectGetMaxY(label31.frame) + 10 ,260,30 )];
        label4.text = @"请申请会员";
        label4.font = [UIFont systemFontOfSize:16.0f];
        label4.textAlignment = UITextAlignmentLeft;
        label4.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        label4.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label4];
        [label4 release];
        
        UIImage *cellImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Phone-Hook" ofType:@"png"]];
        
        UIButton *cellButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
		cellButton1.frame = CGRectMake(30, CGRectGetMaxY(label4.frame) , cellImage.size.width, cellImage.size.height);
		[cellButton1 setBackgroundImage:cellImage forState:UIControlStateNormal];
		[cellButton1 addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:cellButton1];
        
        //拨打的icon
        UIImageView *callImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(200.0f, 7.0f, 30, 30)];
        UIImage *callImage1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
        callImageView1.image = callImage1;
        [callImage1 release];
        [cellButton1 addSubview:callImageView1];
        [callImageView1 release];
		
		UILabel *str1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 150, 33)];
		str1.text = @"联系客服  快速申请";
		str1.font = [UIFont systemFontOfSize:16.0f];
		str1.textAlignment = UITextAlignmentLeft;
		str1.backgroundColor = [UIColor clearColor];
		[cellButton1 addSubview:str1];
		[str1 release];

        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(32,CGRectGetMaxY(cellButton1.frame) + 10,260,30 )];
        label5.text = @"寻求帮助";
        label5.font = [UIFont systemFontOfSize:16.0f];
        label5.textAlignment = UITextAlignmentLeft;
        label5.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        label5.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label5];
        [label5 release];
        
        UIButton *cellButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
		cellButton2.frame = CGRectMake(30, CGRectGetMaxY(label5.frame) , cellImage.size.width, cellImage.size.height);
		[cellButton2 setBackgroundImage:cellImage forState:UIControlStateNormal];
		[cellButton2 addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:cellButton2];
        
        UIImageView *callImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(200.0f, 7.0f, 30, 30)];
        UIImage *callImage2 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"拨打电话icon" ofType:@"png"]];
        callImageView2.image = callImage2;
        [callImage2 release];
        [cellButton2 addSubview:callImageView2];
        [callImageView2 release];
		
		UILabel *str2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 150, 33)];
		str2.text = @"联系客服  找回密码";
		str2.font = [UIFont systemFontOfSize:16.0f];
		str2.textAlignment = UITextAlignmentLeft;
		str2.backgroundColor = [UIColor clearColor];
		[cellButton2 addSubview:str2];
		[str2 release];
        
        [cellImage release];

	}	
	return self;
}

- (void)callAction
{
    [callSystemApp makeCall:self.mobileStr];
}
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
 */

#pragma mark -
#pragma mark cardDetail delegate
- (void)feedbackButtonTouch
{
    NSLog(@"=========== alertCard done !!!");
    [self hide];
    if ([delegate respondsToSelector:@selector(feedback)]) 
    {
        //[delegate feedback];
        [delegate performSelector:@selector(feedback) withObject:nil afterDelay:0.4];
    }
}

- (void)favoriteButtonTouch
{
    [self hide];
    if ([delegate respondsToSelector:@selector(favoriteLogin)]) 
    {
        [delegate performSelector:@selector(favoriteLogin) withObject:nil afterDelay:0.4];
    }
}

- (void)urlButtonTouch:(NSString *)url
{
    [self hide];
    if ([delegate respondsToSelector:@selector(goUrl:)]) 
    {
        [delegate performSelector:@selector(goUrl:) withObject:url afterDelay:0.4];
    }
}

- (void)viewDidUnload
{
    //[super viewDidUnload];
    self.cardInfo = nil;
    self.cUserId = nil;
    self.cardDetail = nil;
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    self.cardInfo = nil;
    self.cUserId = nil;
    self.cardDetail = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
