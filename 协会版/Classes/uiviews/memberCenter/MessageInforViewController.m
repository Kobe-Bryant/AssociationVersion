//
//  MessageInforViewController.m
//  xieHui
//
//  Created by 来 云 on 12-10-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageInforViewController.h"
#import "cardDetailViewController.h"
#import "DBOperate.h"
@interface MessageInforViewController ()

@end

@implementation MessageInforViewController
@synthesize cardDetail;
@synthesize catId;

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
    
    self.title = @"详细资料";
	
    //NSLog(@"catId====%@",catId);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    array = (NSMutableArray *)[DBOperate queryData:T_CONTACTS_BOOK theColumn:@"cat_id" theColumnValue:catId withAll:NO];
    
    cardDetailViewController *tempCardDetail = [[cardDetailViewController alloc] init];
    if (array != nil && [array count] > 0) {
        [array removeObjectAtIndex:[array count] - 1];
        tempCardDetail.cardInfo = array;
    }else {
        tempCardDetail.cardInfo = nil;
    }
    [tempCardDetail.view setFrame:CGRectMake( 10.0f , 0.0f , 320.0f , 320.0f)];
    
    self.cardDetail = tempCardDetail;
    self.cardDetail.delegate = self;
    [tempCardDetail release];
    [self.view addSubview:self.cardDetail.view];
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

- (void)feedbackButtonTouch
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
