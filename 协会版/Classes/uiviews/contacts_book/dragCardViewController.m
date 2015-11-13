//
//  dragCardViewController.m
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "dragCardViewController.h"

@interface dragCardViewController ()

@end

@implementation dragCardViewController

@synthesize delegate;
@synthesize cardInfo;
@synthesize cUserId;
@synthesize cardDetail;

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
	if ((self = [super init])) {
        
        self.cardInfo = cInfo;
        self.cUserId = userId;
        [self.view setFrame:frame];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        //背景
        UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
        backGroundImageView.image = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"滑动名片背景" ofType:@"png"]];
        [self.view addSubview:backGroundImageView];
        [backGroundImageView release];
        
        cardDetailViewController *tempCardDetail = [[cardDetailViewController alloc] init];
        tempCardDetail.cardInfo = self.cardInfo;
        tempCardDetail.cUserId = self.cUserId;
        [tempCardDetail.view setFrame:CGRectMake( 10.0f , 10.0f , 320.0f , 364.0f)];
        
        self.cardDetail = tempCardDetail;
        self.cardDetail.delegate = self;
        [tempCardDetail release];
        [self.view addSubview:self.cardDetail.view];
    
	}
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // self.view.backgroundColor = [UIColorwhiteColorr];
    upFixHeight = ([UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f) / 2;
    downFixHeight = ([UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f) + 124.0f;
}

//弹出名片
- (void)showCardView
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.view.center.y], [NSNumber numberWithFloat:upFixHeight - 10.0f],[NSNumber numberWithFloat:upFixHeight],nil];
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0] , [NSNumber numberWithFloat:0.7] , [NSNumber numberWithFloat:1.0], nil];
    animation.duration = 0.3;
    //animation.speed = 0.8;
    [self.view.layer addAnimation:animation forKey:@"position"];
    self.view.layer.position = CGPointMake(160, upFixHeight);
}

//隐藏名片
- (void)hideCardView
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.view.center.y], [NSNumber numberWithFloat:downFixHeight + 10.0f],[NSNumber numberWithFloat:downFixHeight],nil];
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0] , [NSNumber numberWithFloat:0.7] , [NSNumber numberWithFloat:1.0], nil];
    animation.duration = 0.3;
    //animation.speed = 0.8;
    [self.view.layer addAnimation:animation forKey:@"position"];
    self.view.layer.position = CGPointMake(160, downFixHeight);
    
}

- (void)overLayViewChanged:(CGPoint)point
{
	CGPoint selfViewPoint = self.view.center;
	CGPoint currentPoint = CGPointMake(selfViewPoint.x, selfViewPoint.y + point.y);
	
//	//最上面 
//	if(currentPoint.y < 160)
//	{
//        NSLog(@"======够了 top");
//		currentPoint.y = -320 ;
//	}
//	
//	//最下边
//	else  if(currentPoint.y > 620)
//	{
//        NSLog(@"======够了 bottom");
//		currentPoint.y = 480;
//	}
    
	self.view.center = currentPoint;

}

- (void)overLayViewTouchEnd:(CGPoint)point
{
	CGPoint selfViewPoint = self.view.center;
	CGPoint currentPoint = CGPointMake(selfViewPoint.x, selfViewPoint.y + point.y);
    
    if (point.y > 0) 
    {
        // +50 的区间
        if(currentPoint.y < (upFixHeight + 50.0f))
        {
            [self showCardView];
        }
        else
        {
            [self hideCardView];
        }
    }
    else 
    {
        // -50 的区间
        if(currentPoint.y < (downFixHeight - 50.0f))
        {
            [self showCardView];
        }
        else
        {
            [self hideCardView];
        }
    }
}

- (void)overLayViewTap
{
    CGPoint selfViewPoint = self.view.center;
    if (selfViewPoint.y <= upFixHeight) 
    {
        [self hideCardView];
    }
    else 
    {
        [self showCardView];
    }
	
}

#pragma mark -
#pragma mark cardDetail delegate
- (void)feedbackButtonTouch
{
    NSLog(@"=========== dragCard done !!!");
    [self hideCardView];
    if ([delegate respondsToSelector:@selector(feedback)]) 
    {
        //[delegate feedback];
        [delegate performSelector:@selector(feedback) withObject:nil afterDelay:0.4];
    }
}

- (void)favoriteButtonTouch
{
    [self hideCardView];
    if ([delegate respondsToSelector:@selector(favoriteLogin)]) 
    {
        //[delegate feedback];
        [delegate performSelector:@selector(favoriteLogin) withObject:nil afterDelay:0.4];
    }
}

- (void)urlButtonTouch:(NSString *)url
{
    [self hideCardView];
    if ([delegate respondsToSelector:@selector(goUrl:)]) 
    {
        [delegate performSelector:@selector(goUrl:) withObject:url afterDelay:0.4];
    }
}

#pragma mark -
#pragma mark touch delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	taped = YES;
	UITouch *touch = [touches anyObject];
    pointStart = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	taped = NO;
	UITouch *touch = [touches anyObject];
	CGPoint prePoint = [touch previousLocationInView:[[UIApplication sharedApplication] keyWindow]];
	CGPoint currentPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
	//NSLog(@"touchesMoved   point = %@", NSStringFromCGPoint(currentPoint));
    
    [self overLayViewChanged:CGPointMake(currentPoint.x - prePoint.x, currentPoint.y - prePoint.y)];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint currentPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    //NSLog(@"touchesCancelled   point = %@", NSStringFromCGPoint(currentPoint));

    [self overLayViewTouchEnd:CGPointMake(currentPoint.x - pointStart.x, currentPoint.y - pointStart.y)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint currentPoint = [touch locationInView:[[UIApplication sharedApplication] keyWindow]];
    //NSLog(@" touchesEnded  point = %@", NSStringFromCGPoint(currentPoint));
	
	if(taped)
	{
        [self overLayViewTap];
	}
	else 
    {
        [self overLayViewTouchEnd:CGPointMake(currentPoint.x - pointStart.x, currentPoint.y - pointStart.y)];
	}
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.delegate = nil;
    self.cardInfo = nil;
    self.cUserId = nil;
    self.cardDetail = nil;
}

- (void)dealloc {
    self.delegate = nil;
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
