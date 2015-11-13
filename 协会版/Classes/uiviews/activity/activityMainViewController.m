//
//  activityMainViewController.m
//  xieHui
//
//  Created by siphp on 13-4-24.
//
//

#import "activityMainViewController.h"
#import "activityTabButton.h"
#import "activityViewController.h"
#import "activityHistoryViewController.h"
#import "activityDetailViewController.h"
#import "DBOperate.h"
#import "Common.h"

@interface activityMainViewController ()

@end

@implementation activityMainViewController

@synthesize currentSelectedIndex;
@synthesize activityView;
@synthesize activityHistoryView;
@synthesize isFromAd;
@synthesize infoId;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.isFromAd = NO;
        self.infoId = 0;
    }
    return self;
}

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
	// Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor orangeColor];
    
    self.title = @"活动平台";
    
    [self showToolBar];
    
    //默认选中第一个
    UIButton *currentSelectedButton = (UIButton*)[self.view viewWithTag:self.currentSelectedIndex];
    [self buttonClick:currentSelectedButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

//工具栏
-(void)showToolBar
{
    UIView *toolBarView = [[UIView alloc] initWithFrame:
                           CGRectMake(0.0f, VIEW_HEIGHT - 20 - 44 - 40.0f, 320.0f, 40.0f)];
    [self.view addSubview:toolBarView];
    
    UIImageView *toolBarBackgroundView = [[UIImageView alloc] initWithFrame:
                                          CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:
					  [[NSBundle mainBundle] pathForResource:@"共用_下bar" ofType:@"png"]];
	toolBarBackgroundView.backgroundColor = [UIColor clearColor];
	toolBarBackgroundView.userInteractionEnabled = YES;
    toolBarBackgroundView.image = image;
    [image release];
	[toolBarView addSubview:toolBarBackgroundView];
    [toolBarBackgroundView release];
    
    //添加按钮
    NSArray *toolItems = [NSArray arrayWithObjects:@"近期活动",@"往期活动",nil];
    int itemsCouns = [toolItems count];
    int bTag = 1000;
    self.currentSelectedIndex = bTag + 1;
    CGFloat oneButtonWidth = self.view.frame.size.width/itemsCouns;
    CGFloat marginWidth = oneButtonWidth/2;
    CGFloat fixWidth = 0.0f;
    for (NSString *itemTitle in toolItems)
    {
        UIButton *button = [activityTabButton buttonWithType:UIButtonTypeCustom];
        button.tag = ++bTag;
        fixWidth = marginWidth + ((button.tag - 1000)-1) * oneButtonWidth;
		[button setFrame:CGRectMake(0.0f , 0.0f , (self.view.frame.size.width / 2), 40.0f)];
        button.center = CGPointMake(fixWidth , 20.0f);
		[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //选中后背景图片
        NSString *selectedBackgroundPicName = @"共用_下bar_select";
        [button setBackgroundImage :[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectedBackgroundPicName ofType:@"png"]] forState:UIControlStateSelected];
        
        //未选中图标
        NSString *normalPicName = [NSString stringWithFormat:@"icon_%@_normal",itemTitle];
        [button setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:normalPicName ofType:@"png"]] forState:UIControlStateNormal];
        
        //选中后图标
        NSString *selectedPicName = [NSString stringWithFormat:@"icon_%@_selected",itemTitle];
        [button setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectedPicName ofType:@"png"]] forState:UIControlStateSelected];
        
        //字体居中跟大小
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        
        //未选中文字
        [button setTitle:itemTitle forState:UIControlStateNormal];
        
        //选中后文字
        [button setTitle:itemTitle forState:UIControlStateSelected];
        
        //未选中文字颜色
        [button setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0] forState:UIControlStateNormal];
        
        //选中后文字颜色
        [button setTitleColor:[UIColor colorWithRed:0.72f green:0.5f blue:0.23f alpha:1.0] forState:UIControlStateSelected];
        
        [toolBarView addSubview:button];
    }
    
    [toolBarView release];
}

//功能按钮
-(void)buttonClick:(id)sender
{
	UIButton *currentButton = sender;
    if (!currentButton.selected)
    {
        //取消上一次选中
        UIButton *currentSelectedButton = (UIButton*)[self.view viewWithTag:self.currentSelectedIndex];
        if ([currentSelectedButton isKindOfClass:[UIButton class]])
        {
            [currentSelectedButton setSelected:NO];
        }
        
        switch (self.currentSelectedIndex)
        {
            case 1001:
            {
                self.activityView.view.hidden = YES;
                break;
            }
            case 1002:
            {
                self.activityHistoryView.view.hidden = YES;
                break;
            }
            default:
                break;
        }
        
        //设置本次选中
        [currentButton setSelected:YES];
        self.currentSelectedIndex = currentButton.tag;
        
        switch (currentButton.tag)
        {
            case 1001:
            {
                [self activity];
                break;
            }
            case 1002:
            {
                [self activityHistory];
                break;
            }
            default:
                break;
        }
    }
}

//近期活动
-(void)activity
{
    if ([self.activityView.view isDescendantOfView:self.view])
    {
        self.activityView.view.hidden = NO;
    }
    else
    {
        //监视活动列表获取数据
        if (self.isFromAd)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(activityDetail)
                                                         name:@"loadActivity"
                                                       object:nil];
        }
        activityViewController *tempActivityView = [[activityViewController alloc] init];
        self.activityView = tempActivityView;
        [tempActivityView release];
        [self.view addSubview:self.activityView.view];
    }
}

//往期活动
-(void)activityHistory
{
    if ([self.activityHistoryView.view isDescendantOfView:self.view])
    {
        self.activityHistoryView.view.hidden = NO;
    }
    else
    {
        activityHistoryViewController *tempActivityHistoryView = [[activityHistoryViewController alloc] init];
        tempActivityHistoryView.view.frame = CGRectMake( 0.0f , 0.0f ,self.view.frame.size.width , self.view.frame.size.height - 40.0f);
        self.activityHistoryView = tempActivityHistoryView;
        [tempActivityHistoryView release];
        [self.view addSubview:self.activityHistoryView.view];
    }
}

//模拟活动点击
-(void)activityDetail
{
    
    NSMutableArray *activityItems = [DBOperate queryData:T_ACTIVITY
               theColumn:@"id" theColumnValue:[NSString stringWithFormat:@"%d",self.infoId] orderBy:@"id" orderType:@"desc" withAll:NO];
    
    if ([activityItems count] > 0)
    {
        NSArray *activityArray = [activityItems objectAtIndex:0];
        activityDetailViewController *activityDetailView = [[activityDetailViewController alloc] init];
        
        activityDetailView.activityArray = activityArray;

        //活动图片处理
        activityDetailView.picArray = [DBOperate queryData:T_ACTIVITY_PIC
                                                     theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_id] orderBy:@"id" orderType:@"asc" withAll:NO];

        //用户图片处理
        activityDetailView.userPicArray = [DBOperate queryData:T_ACTIVITY_USER_PIC
                                                         theColumn:@"activity_id" theColumnValue:[activityArray objectAtIndex:activity_id] orderBy:@"id" orderType:@"desc" withAll:NO];
        
        [self.navigationController pushViewController:activityDetailView animated:YES];
        [activityDetailView release];
    }
    else
    {
        UIButton *currentSelectedButton = (UIButton*)[self.view viewWithTag:1002];
        [self buttonClick:currentSelectedButton];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activityView = nil;
    self.activityHistoryView = nil;
}


- (void)dealloc {
	[self.activityView release];
    [self.activityHistoryView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
