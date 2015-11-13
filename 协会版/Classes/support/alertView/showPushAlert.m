//
//  showPushAlert.m
//  AppStrom
//
//  Created by 掌商 on 11-9-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "showPushAlert.h"
#import "browserViewController.h"
#import "CustomTabBar.h"
#import "activityMainViewController.h"
#import "Common.h"

@implementation showPushAlert
@synthesize pushurl;
@synthesize theSuperViewController;
@synthesize alertV;
@synthesize pushTitle;
@synthesize pushType;
@synthesize pushInfoId;

-(id)initWithContent:(NSString*)content onViewController:(UINavigationController*)theViewController{

	if ([super init]!=nil) {
		self.theSuperViewController = theViewController;
		NSRange range = [content rangeOfString:@"http"];
		UIAlertView *av = nil;
		if (range.location != NSNotFound) {
			int start = range.location;
			self.pushurl = [content substringFromIndex:start];
			self.pushTitle = [content substringToIndex:start];
			NSString *showContent = [content substringToIndex:start];
			if (pushurl.length>1) {
				av = [[UIAlertView alloc] initWithTitle:nil message:showContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打开链接",nil];
			}
		}
		else {
		
			av = [[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
		
		}
		self.alertV = av;
		[av release];
		
	}
	return self;
}

-(id)initWithDic:(NSDictionary*)userInfo onViewController:(UINavigationController*)theViewController
{
    if ([super init]!=nil)
    {
        NSDictionary *titleDic = [userInfo objectForKey:@"aps"];
        self.pushTitle = [titleDic objectForKey:@"alert"];
        self.pushurl = [userInfo objectForKey:@"url"];
        self.pushType = [[userInfo objectForKey:@"type"] intValue];
        self.pushInfoId = [[userInfo objectForKey:@"info_id"] intValue];
        
		self.theSuperViewController = theViewController;
		UIAlertView *av = nil;
        if (self.pushTitle.length > 1)
        {
            if (self.pushType == 1 || self.pushType == 2 || self.pushType == 0)
            {
                if (self.pushurl.length>1)
                {
                    av = [[UIAlertView alloc] initWithTitle:nil message:self.pushTitle delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
                }
                else
                {
                    av = [[UIAlertView alloc] initWithTitle:nil message:self.pushTitle delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                }
            }
            else if(self.pushType == 3 || self.pushType == 4)
            {
                av = [[UIAlertView alloc] initWithTitle:nil message:self.pushTitle delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看",nil];
            }
        }
		self.alertV = av;
		[av release];
		
	}
	return self;
}

-(id)initWithTitle:(NSString*)title url:(NSString*)purl onViewController:(UINavigationController*)theViewController
{
    if ([super init]!=nil)
    {
		self.theSuperViewController = theViewController;
		UIAlertView *av = nil;
        if (title.length > 1)
        {
            if (purl.length>1)
            {
                self.pushurl = purl;
                self.pushTitle = title;
                av = [[UIAlertView alloc] initWithTitle:nil message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打开链接",nil];
            }
            else
            {
                av = [[UIAlertView alloc] initWithTitle:nil message:title delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            }
        }
		self.alertV = av;
		[av release];
		
	}
	return self;
}

-(void)showAlert{
  
	[alertV show];
	
}
- (void) alertView:(UIAlertView *) alertView1 clickedButtonAtIndex: (int) index
{
	if(index != alertView1.cancelButtonIndex)
	{
        if (self.pushType == 1 || self.pushType == 2)
        {
            //原来的资讯,产品 1:资讯 2:产品
            browserViewController *browser = [[browserViewController alloc] init];
            browser.url = self.pushurl;
            browser.webTitle = self.pushTitle;
            [self.theSuperViewController pushViewController:browser animated:YES];
            [browser release];
        }
        else
        {
            //活动跟消息 3:活动 4:消息
            if (self.pushType == 3)
            {
                if (self.pushInfoId > 0)
                {
                    activityMainViewController * activityMainView = [[activityMainViewController alloc] init];
                    activityMainView.isFromAd = YES;
                    activityMainView.infoId = self.pushInfoId;
                    
                    [self.theSuperViewController pushViewController:activityMainView animated:YES];
                    [activityMainView release];
                }
            }
            else if(self.pushType == 4)
            {
                NSArray *arrayViewControllers = self.theSuperViewController.viewControllers;
                if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
                {
                    [self.theSuperViewController popToRootViewControllerAnimated:NO];
                    CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                    is_push_with_msg = tabViewController.currentSelectedIndex == 90003 ? NO : YES;
                    [tabViewController selectedTab:[tabViewController.buttons objectAtIndex:3]];
                }
            }
        }
		
	}
	//self.alertV = nil;
	//[alertView1 release];
}

-(void)dealloc{
	if (alertV != nil) {
		[alertV dismissWithClickedButtonIndex:0 animated:YES];
		self.alertV = nil;
	}
   
	self.theSuperViewController = nil;
	self.pushurl = nil;
	self.pushTitle = nil;
	[super dealloc];
}
@end
