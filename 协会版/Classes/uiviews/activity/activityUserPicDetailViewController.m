    //
//  activityUserPicDetailViewController
//  Profession
//
//  Created by siphp on 12-8-14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "activityUserPicDetailViewController.h"
#import "Common.h"
#import "UIImageScale.h"
#import "FileManager.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"

@implementation activityUserPicDetailViewController

@synthesize picArray;
@synthesize showPicScrollView;
@synthesize imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting;
@synthesize photoWith;
@synthesize photoHigh;
@synthesize chooseIndex;
@synthesize progressHUD;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	[self.navigationController.navigationBar setTranslucent:YES];
    
    if (IOS_VERSION >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    tapOnce = 0;

	photoWith = photoWith == 0.0f ? 320.0f : photoWith;
	photoHigh = photoHigh == 0.0f ? 460.0f : photoHigh;
	
	NSMutableDictionary *idip = [[NSMutableDictionary alloc]init];
	self.imageDownloadsInProgress = idip;
	[idip release];
	
	NSMutableArray *wait = [[NSMutableArray alloc]init];
	self.imageDownloadsInWaiting = wait;
	[wait release];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap]; //这个可以加到任何控件上,比如你只想响应WebView，我正好填满整个屏幕
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.numberOfTapsRequired = 1;
    [singleTap release];
    
	if (self.picArray != nil || [self.picArray count] != 0) 
	{
		[self showPic];
	}
}

-(void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	//self.navigationController.navigationBarHidden=NO;
	[self.navigationController.navigationBar setTranslucent:NO];
}

-(void)showPic
{	
	int pageCount = [self.picArray count];
	
	if (self.showPicScrollView == nil && self.picArray != nil && pageCount > 0)
	{
        CGFloat yValue = (VIEW_HEIGHT - 20.0f - 460.0f) / 2;
//        if (IOS_VERSION >= 7.0) {
//            yValue = yValue - 20;
//        }
        
		UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( -5.0f, yValue, self.view.frame.size.width + 10.0f, 460.f)];
		tmpScroll.contentSize = CGSizeMake(pageCount * tmpScroll.frame.size.width, photoHigh);
		tmpScroll.pagingEnabled = YES;
		tmpScroll.delegate = self;
		tmpScroll.showsHorizontalScrollIndicator = NO;
		tmpScroll.showsVerticalScrollIndicator = NO;
		tmpScroll.tag = 100;
		self.showPicScrollView=tmpScroll;
		[tmpScroll release];
		
		for(int i = 0;i < pageCount;i++)
		{
            CGFloat fixHeight = (photoHigh + (photoHigh/2));
            UIScrollView *tmpImageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(i * self.showPicScrollView.frame.size.width + 5.0f, (self.showPicScrollView.frame.size.height - fixHeight) / 2 ,photoWith, fixHeight)];
            tmpImageScroll.contentSize = CGSizeMake(photoWith, 460);
            tmpImageScroll.pagingEnabled = NO;
            tmpImageScroll.delegate = self;
            tmpImageScroll.maximumZoomScale = 2.0;
            tmpImageScroll.minimumZoomScale = 1.0;
            tmpImageScroll.showsHorizontalScrollIndicator = NO;
            tmpImageScroll.showsVerticalScrollIndicator = NO;
            tmpImageScroll.backgroundColor = [UIColor clearColor];
            tmpImageScroll.tag = 200+i;
            
            myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake(0.0f , (tmpImageScroll.frame.size.height - photoHigh) / 2,
											photoWith, photoHigh) withImageId:i];
            
			myiv.mydelegate = self;
			myiv.tag = 2000;
			
			[tmpImageScroll addSubview:myiv];
            [myiv release];
            [self.showPicScrollView addSubview:tmpImageScroll];
            [tmpImageScroll release];
			
			if (self.picArray != nil && pageCount > 0 && i < pageCount) 
			{
				NSArray *pic = [self.picArray objectAtIndex:i];
                
                //缩略图
                NSString *thumbPhotoUrl = [pic objectAtIndex:3];
                NSString *thumbPicName = [Common encodeBase64:(NSMutableData *)[thumbPhotoUrl dataUsingEncoding: NSUTF8StringEncoding]];
                UIImage *thumbPhoto = [FileManager getPhoto:thumbPicName];
                myiv.image = thumbPhoto;
				
                //大图
				NSString *photoUrl = [pic objectAtIndex:2];
				NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
				
				if (photoUrl.length > 1) 
				{
					UIImage *photo = [FileManager getPhoto:picName];
					if (photo.size.width > 2)
					{
                        //重新调整尺寸
                        CGFloat currentImageHeight = photo.size.height * (photoWith /photo.size.width);
                        CGFloat currentFixHeight = (currentImageHeight + (currentImageHeight/2));
                        tmpImageScroll.frame = CGRectMake(i * self.showPicScrollView.frame.size.width + 5.0f, (self.showPicScrollView.frame.size.height - currentFixHeight) / 2 ,photoWith, currentFixHeight);
                        
                        myiv.frame = CGRectMake(0.0f , (tmpImageScroll.frame.size.height - currentImageHeight) / 2,
                                                photoWith, currentImageHeight);

						myiv.image = photo;//[photo fillSize:CGSizeMake(photoWith,photoHigh)];
					}
					else
					{
						[myiv startSpinner];
                        myiv.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
						[self startIconDownload:photoUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
					}
				}
                
                UILabel *backlabel = [[UILabel alloc] initWithFrame:CGRectZero];
                backlabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
                //添加描述          
                UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [descInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
                descInfoLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
                descInfoLabel.backgroundColor = [UIColor clearColor];
                descInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
                descInfoLabel.numberOfLines = 0;
                NSString *descText = [pic objectAtIndex:4];
                descInfoLabel.text = descText;
                CGSize constraint = CGSizeMake(photoWith-20.f, 20000.0f);
                CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                float descFixHeight = size.height + 20.0f;
                descFixHeight = descFixHeight == 0 ? 50.0f : MAX(descFixHeight,50.0f);
                [descInfoLabel setFrame:CGRectMake(10.f, 0.f , photoWith-15.f, descFixHeight)];
                
                [backlabel setFrame:CGRectMake(i * self.showPicScrollView.frame.size.width+5.f, self.showPicScrollView.frame.size.height - descFixHeight , photoWith, descFixHeight)];
                
                [backlabel addSubview:descInfoLabel];
                [descInfoLabel release];
                [self.showPicScrollView addSubview:backlabel];
                [backlabel release];
			}
		}		
	}
	self.showPicScrollView.contentOffset = CGPointMake(self.showPicScrollView.frame.size.width * chooseIndex, 0.0f);
	
	[self.view addSubview:self.showPicScrollView];
	
	self.title = [NSString stringWithFormat:@"%d / %d",chooseIndex+1,[self.picArray count]];
	
}

//网络获取更多数据
-(void)accessPicMoreService
{
    NSString *reqUrl = @"activityimglist.do?param=%@";
    
    //取本地最后一条
    int userPicId = 0;
    NSString *activityId = @"0";
    if ([self.picArray count] > 0)
    {
        NSArray *array = [self.picArray objectAtIndex:([self.picArray count] - 1)];
        userPicId = [[array objectAtIndex:activity_user_pic_id] intValue];
        activityId = [array objectAtIndex:activity_user_pic_activity_id];
    }

	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",
                                 [NSNumber numberWithInt: userPicId],@"info_id",
                                 activityId,@"activity_id",
								 nil];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  activityId,@"activityId",
								  nil];
	
	[[DataManager sharedManager] accessService:jsontestDic
									   command:OPERAT_ACTIVITY_USER_PIC_MORE
								  accessAdress:reqUrl
									  delegate:self
									 withParam:param];
}

//保存缓存图片
-(bool)savePhoto:(UIImage*)photo atIndexPath:(NSIndexPath*)indexPath
{
	
	int countItems = [self.picArray count];
	
	if (countItems > [indexPath row]) 
	{
		NSArray *pic = [self.picArray objectAtIndex:[indexPath row]];
		NSString *picName = [Common encodeBase64:(NSMutableData *)[[pic objectAtIndex:2] dataUsingEncoding: NSUTF8StringEncoding]];
		//保存缓存图片
		if([FileManager savePhoto:picName withImage:photo])
		{
			return YES;
		}
		else 
		{
			return NO;
		}
		
	}
	return NO;
}

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath
{
	IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil && photoURL != nil && photoURL.length > 1) 
    {
		if ([imageDownloadsInProgress count]>= 5) {
			imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc]init:photoURL withIndexPath:indexPath withImageType:CUSTOMER_PHOTO];
			[imageDownloadsInWaiting addObject:one];
			[one release];
			return;
		}
        IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
        iconDownloader.downloadURL = photoURL;
        iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.imageType = CUSTOMER_PHOTO;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSIndexPath *)indexPath withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{ 
			//保存图片
			[self savePhoto:iconDownloader.cardIcon atIndexPath:indexPath];
			UIImage *photo = iconDownloader.cardIcon;//[iconDownloader.cardIcon fillSize:CGSizeMake(photoWith, photoHigh)];
            
            UIScrollView *imageScroll = (UIScrollView *)[self.showPicScrollView viewWithTag:200+[indexPath row]];
			myImageView *currentMyImageView = (myImageView *)[imageScroll viewWithTag:2000];
            
            //重新调整尺寸
            CGFloat currentImageHeight = photo.size.height * (photoWith /photo.size.width);
            CGFloat currentFixHeight = (currentImageHeight + (currentImageHeight/2));
            imageScroll.frame = CGRectMake(imageScroll.frame.origin.x, (self.showPicScrollView.frame.size.height - currentFixHeight) / 2 ,photoWith, currentFixHeight);
            
            currentMyImageView.frame = CGRectMake(0.0f , (imageScroll.frame.size.height - currentImageHeight) / 2,
                                    photoWith, currentImageHeight);

			currentMyImageView.image = photo;
			[currentMyImageView stopSpinner];
		}
		
		[imageDownloadsInProgress removeObjectForKey:indexPath];
		if ([imageDownloadsInWaiting count]>0) 
		{
			imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
			[self startIconDownload:one.imageURL forIndexPath:one.indexPath];
			[imageDownloadsInWaiting removeObjectAtIndex:0];
		}
		
    }
}

//追加用户图片
-(void)appendUserPic:(NSMutableArray *)data
{
    if (data != nil && [data count] > 0)
	{
        int oldPicCount = [self.picArray count];
        
        //合并数据
		for (int i = 0; i < [data count];i++ )
		{
			NSArray *array = [data objectAtIndex:i];
			[self.picArray addObject:array];
		}
        
        int picCount = [self.picArray count];
        
        for(int i = oldPicCount;i < picCount;i++)
		{
            CGFloat fixHeight = (photoHigh + (photoHigh/2));
            UIScrollView *tmpImageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(i * self.showPicScrollView.frame.size.width + 5.0f, (self.showPicScrollView.frame.size.height - fixHeight) / 2 ,photoWith, fixHeight)];
            tmpImageScroll.contentSize = CGSizeMake(photoWith, 460);
            tmpImageScroll.pagingEnabled = NO;
            tmpImageScroll.delegate = self;
            tmpImageScroll.maximumZoomScale = 2.0;
            tmpImageScroll.minimumZoomScale = 1.0;
            tmpImageScroll.showsHorizontalScrollIndicator = NO;
            tmpImageScroll.showsVerticalScrollIndicator = NO;
            tmpImageScroll.backgroundColor = [UIColor clearColor];
            tmpImageScroll.tag = 200+i;
            
            myImageView *myiv = [[myImageView alloc]initWithFrame:
								 CGRectMake(0.0f , (tmpImageScroll.frame.size.height - photoHigh) / 2,
											photoWith, photoHigh) withImageId:i];
            
			myiv.mydelegate = self;
			myiv.tag = 2000;
			
			[tmpImageScroll addSubview:myiv];
            [myiv release];
            [self.showPicScrollView addSubview:tmpImageScroll];
            [tmpImageScroll release];
			
            NSArray *pic = [self.picArray objectAtIndex:i];
            
            //缩略图
            NSString *thumbPhotoUrl = [pic objectAtIndex:3];
            NSString *thumbPicName = [Common encodeBase64:(NSMutableData *)[thumbPhotoUrl dataUsingEncoding: NSUTF8StringEncoding]];
            UIImage *thumbPhoto = [FileManager getPhoto:thumbPicName];
            myiv.image = thumbPhoto;
            
            //大图
            NSString *photoUrl = [pic objectAtIndex:2];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (photoUrl.length > 1)
            {
                UIImage *photo = [FileManager getPhoto:picName];
                if (photo.size.width > 2)
                {
                    
                    //重新调整尺寸
                    CGFloat currentImageHeight = photo.size.height * (photoWith /photo.size.width);
                    CGFloat currentFixHeight = (currentImageHeight + (currentImageHeight/2));
                    tmpImageScroll.frame = CGRectMake(i * self.showPicScrollView.frame.size.width + 5.0f, (self.showPicScrollView.frame.size.height - currentFixHeight) / 2 ,photoWith, currentFixHeight);
                    
                    myiv.frame = CGRectMake(0.0f , (tmpImageScroll.frame.size.height - currentImageHeight) / 2,
                                            photoWith, currentImageHeight);
                    
                    myiv.image = photo; //[photo fillSize:CGSizeMake(photoWith,photoHigh)];
                }
                else
                {
                    [myiv startSpinner];
                    myiv.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
                    [self startIconDownload:photoUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }
            
            UILabel *backlabel = [[UILabel alloc] initWithFrame:CGRectZero];
            backlabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
            if ([self.navigationController isNavigationBarHidden]) {
                backlabel.hidden = YES;
            }
            //添加描述
            UILabel *descInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [descInfoLabel setFont:[UIFont systemFontOfSize:14.0f]];
            descInfoLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
            descInfoLabel.backgroundColor = [UIColor clearColor];
            descInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
            descInfoLabel.numberOfLines = 0;
            NSString *descText = [pic objectAtIndex:4];
            descInfoLabel.text = descText;
            CGSize constraint = CGSizeMake(photoWith-20.f, 20000.0f);
            CGSize size = [descText sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            float descFixHeight = size.height + 20.0f;
            descFixHeight = descFixHeight == 0 ? 50.0f : MAX(descFixHeight,50.0f);
            [descInfoLabel setFrame:CGRectMake(10.f, 0.f , photoWith-15.f, descFixHeight)];
            
            [backlabel setFrame:CGRectMake(i * self.showPicScrollView.frame.size.width+5.f, self.showPicScrollView.frame.size.height - descFixHeight , photoWith, descFixHeight)];
            
            [backlabel addSubview:descInfoLabel];
            [descInfoLabel release];
            [self.showPicScrollView addSubview:backlabel];
            [backlabel release];
        
		}
        
        self.showPicScrollView.contentSize = CGSizeMake(picCount * self.showPicScrollView.frame.size.width, photoHigh);
		
        _loadingMore = NO;
        
	}
    
    //移出提示层
    if (self.progressHUD)
    {
        [progressHUD hide:YES afterDelay:0.0f];
    }

}

// dufu  add 2013.05.16
// 是否隐藏图片备注
- (void)isHidebackLabel:(BOOL)stats
{
    NSArray *UIViewSub = self.showPicScrollView.subviews;
    for (UILabel *view in UIViewSub) {
        if ([view isKindOfClass:[UILabel class]]) {
            if (stats == YES) {
                [UIView animateWithDuration:0.5f animations:^(void) {
                    CGRect viewRect = view.frame;
                    viewRect.origin.y = 460.f;
                    view.frame = viewRect;
                }];
            } else {
                [UIView animateWithDuration:0.5f animations:^(void) {
                    CGRect viewRect = view.frame;
                    viewRect.origin.y = 460.f - view.frame.size.height;
                    view.frame = viewRect;
                }];
            }
        }
    }
}


//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch(commandid)
    {
        //更多图片刷新
        case OPERAT_ACTIVITY_USER_PIC_MORE:
            [self performSelectorOnMainThread:@selector(appendUserPic:) withObject:resultArray waitUntilDone:NO];
            break;
            
        default:   ;
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)singleTap
{
    BOOL navBarState = [self.navigationController isNavigationBarHidden];
	[self.navigationController setNavigationBarHidden:!navBarState animated:YES];
    [self isHidebackLabel:!navBarState];
    
    tapOnce = 0;
}

-(void)doubleTap
{
    UIScrollView *imageScroll = (UIScrollView *)[self.showPicScrollView viewWithTag:200+chooseIndex];
    
    CGFloat zs = imageScroll.zoomScale;
	zs = (zs == imageScroll.minimumZoomScale) ? imageScroll.maximumZoomScale : imageScroll.minimumZoomScale;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	imageScroll.zoomScale = zs;
	[UIView commitAnimations];
    
    tapOnce = 0;
}

-(void)reSetTapOnce
{
    tapOnce = 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    tapOnce++;
    
    NSTimeInterval delaytime = 0.3;
    
    if (tapOnce == 1)
    {
        [self performSelector:@selector(singleTap) withObject:nil afterDelay:delaytime];
    }
    else if(tapOnce == 2)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
        [self performSelector:@selector(doubleTap) withObject:nil afterDelay:delaytime];
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doubleTap) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reSetTapOnce) object:nil];
        [self performSelector:@selector(reSetTapOnce) withObject:nil afterDelay:delaytime];
    }
}

#pragma mark -
#pragma mark 图片滚动委托
//- (void)imageViewTouchesEnd:(int)picId
//{	
//	BOOL navBarState = [self.navigationController isNavigationBarHidden];
//	[self.navigationController setNavigationBarHidden:!navBarState animated:YES];
//    [self isHidebackLabel:!navBarState];
//}
//
//- (void)imageViewDoubleTouchesEnd:(int)picId
//{	
//    UIScrollView *imageScroll = (UIScrollView *)[self.showPicScrollView viewWithTag:200+picId];
//    
//    CGFloat zs = imageScroll.zoomScale;
//	zs = (zs == imageScroll.minimumZoomScale) ? imageScroll.maximumZoomScale : imageScroll.minimumZoomScale;
//	
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.3];            
//	imageScroll.zoomScale = zs;    
//	[UIView commitAnimations];
//}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{	
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    //[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if (scrollView == self.showPicScrollView)
    {
        if (_isAllowLoadingMore && !_loadingMore)
        {
            float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
            if (rightEdge > scrollView.contentSize.width + 10.0f)
            {
                //松开 载入更多
                _loadingMore = YES;
                
                //添加loading图标
                MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
                self.progressHUD = progressHUDTmp;
                [progressHUDTmp release];
                self.progressHUD.delegate = self;
                self.progressHUD.labelText = LOADING_TIPS;
                [self.view addSubview:self.progressHUD];
                [self.view bringSubviewToFront:self.progressHUD];
                [self.progressHUD show:YES];
                
                //数据
                [self accessPicMoreService];
                
            }
            else
            {
                //NSLog(@"----右拉加载更多------");
            }
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.showPicScrollView)
    {
        float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
        if (rightEdge >= scrollView.contentSize.width && rightEdge > self.showPicScrollView.frame.size.width && [self.picArray count] >= 6)
        {
            _isAllowLoadingMore = YES;
        }
        else
        {
            _isAllowLoadingMore = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView{
    if (aScrollView.tag == 100) {
		CGPoint offset = aScrollView.contentOffset;
		int currentPage = offset.x / self.showPicScrollView.frame.size.width;
        chooseIndex = currentPage;
		self.title = [NSString stringWithFormat:@"%d / %d",currentPage+1,[self.picArray count]];
        
        int pageCount = [self.picArray count];
		for(int i = 0;i < pageCount;i++)
		{
            UIScrollView *imageScroll = (UIScrollView *)[self.showPicScrollView viewWithTag:200+i];
            imageScroll.zoomScale = imageScroll.minimumZoomScale;
        }
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView
{
    if (aScrollView.tag != 100)
    {
        UIImageView *imageview = (UIImageView *)[aScrollView viewWithTag:2000];
        return imageview;
    }
    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale
{
	if (aScrollView.tag != 100) 
    {
		float pwidth = aScrollView.frame.size.width*scale;
		float pheigth = aScrollView.frame.size.height*scale;
		aScrollView.contentSize = CGSizeMake(pwidth,pheigth);
	}	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.picArray = nil;
	self.showPicScrollView.delegate = nil;
	self.showPicScrollView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    self.progressHUD.delegate = nil;
	self.progressHUD = nil;
}


- (void)dealloc {
	self.picArray = nil;
	self.showPicScrollView.delegate = nil;
	self.showPicScrollView = nil;
	for (IconDownLoader *one in [imageDownloadsInProgress allValues]){
		one.delegate = nil;
	}
	self.imageDownloadsInProgress = nil;
	self.imageDownloadsInWaiting = nil;
    self.progressHUD.delegate = nil;
	self.progressHUD = nil;
    [super dealloc];
}


@end
