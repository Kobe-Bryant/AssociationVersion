//
//  CustomTabBar.m
//  LeqiClient
//
//  Created by ui on 11-5-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTabBar.h"
#import "tabEntranceViewController.h"
#import "Common.h"
#import "MButton.h"

@implementation CustomTabBar

@synthesize currentSelectedIndex;
@synthesize buttons;
@synthesize customTab;
@synthesize isHideToolbar;

- (id)init{
	[super init];
	return self;
}

- (void) viewDidLoad{
	[super viewDidLoad];
	slideBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomfocus.png"]];
	
	[self hideRealTabBar];
	[self customTabBar];
    isHideToolbar = NO;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)hideRealTabBar{
	for(UIView *view in self.view.subviews){
		if([view isKindOfClass:[UITabBar class]]){
			view.hidden = YES;
			break;
		}
	}
}

- (void)hideExistingTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
}

- (void)customTabBar{
	
	//UIView *tabBarBackGroundView = [[UIView alloc] initWithFrame:self.tabBar.frame];
	//tabBarBackGroundView.backgroundColor = [UIColor grayColor];
    
    UIView *tempCustomTab = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 367.0f , 320.0f , 49.0f)];
    tempCustomTab.backgroundColor = [UIColor clearColor];
    self.customTab = tempCustomTab;
    [tempCustomTab release];
    [self.view addSubview:self.customTab];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"定制下bar.png"]];
	imgView.frame = CGRectMake(0.0f , 0.0f , imgView.image.size.width, imgView.image.size.height);
	[self.customTab addSubview:imgView];
	[imgView release];
    
    slideBg.frame = CGRectMake(0.0f , 0.0f , 64.0f, 49.0f);
    [self.customTab addSubview:slideBg];
    
	//创建按钮
	int viewCount = 5;//[tabArray count];
	self.buttons = [NSMutableArray arrayWithCapacity:viewCount];
	double _width = 320 / viewCount;
    NSArray *itemTitle = ARRAYS_TAB_BAR;
	NSArray *itemChooseTitle = ARRAYS_SELECTED_TAB_BAR;
	for (int i = 0; i < viewCount; i++) {
		UIButton *btn = [MButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i*_width, 0.0f , _width, 49.0f);
		[btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
		btn.tag = i+90000;
        
        //未选中图片
		[btn setImage:[UIImage imageNamed:[itemTitle objectAtIndex:i]] forState:UIControlStateNormal];
        
        //选中后图片
		[btn setImage:[UIImage imageNamed:[itemChooseTitle objectAtIndex:i]] forState:UIControlStateSelected];
        
        //字体居中跟大小
        btn.titleLabel.textAlignment = UITextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        //未选中文字
        [btn setTitle:[itemTitle objectAtIndex:i] forState:UIControlStateNormal];
        
        //选中后文字
        [btn setTitle:[itemTitle objectAtIndex:i] forState:UIControlStateSelected];
        
        //未选中文字颜色
        UIColor *colorUnselectedTabBar = COLOR_UNSELECTED_TAB_BAR;
        [btn setTitleColor:colorUnselectedTabBar forState:UIControlStateNormal];
        
        //选中后文字颜色
        UIColor *colorSelectedTabBar = COLOR_SELECTED_TAB_BAR;
        [btn setTitleColor:colorSelectedTabBar forState:UIControlStateSelected];
        
		[self.buttons addObject:btn];
		[self.customTab addSubview:btn];
		[btn release];
	}

	currentSelectedIndex = 90000;
	

}

- (void)selectedTab:(UIButton *)button{
    
    if (!button.selected)
    {
        //取消上一次选中
        UIButton *currentSelectedButton = (UIButton*)[self.view viewWithTag:self.currentSelectedIndex];
        if ([currentSelectedButton isKindOfClass:[UIButton class]])
        {
            [currentSelectedButton setSelected:NO];
        }	
        
        currentSelectingIndex = button.tag - 90000;
        
        //设置本次选中
        [button setSelected:YES];
        self.currentSelectedIndex = button.tag;
        self.selectedIndex = self.currentSelectedIndex-90000;
        
        CGFloat fixHeight;
        
        fixHeight = [UIScreen mainScreen].bounds.size.height - 49.0f - 44.0f - 20.0f;

        self.customTab.frame = CGRectMake(self.customTab.frame.origin.x,fixHeight,320.0f,49.0f);
        
        //执行选中事件
        if(self.delegate != nil)
        {
            [self.delegate tabBarController:self didSelectViewController:self.selectedViewController];
        }
        
        //选中动画效果
        [self performSelector:@selector(slideTabBg:) withObject:button];
    }
    
}

- (void)slideTabBg:(UIButton *)btn{
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:0.20];  
	[UIView setAnimationDelegate:self];
	slideBg.frame = CGRectMake(btn.frame.origin.x , slideBg.frame.origin.y, slideBg.image.size.width, slideBg.image.size.height);
	[UIView commitAnimations];
}

- (void) dealloc{
	[slideBg release];
	[buttons release];
    [customTab release];
	[super dealloc];
}


@end
