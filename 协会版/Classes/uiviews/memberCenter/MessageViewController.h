//
//  MessageViewController.h
//  xieHui
//
//  Created by 来 云 on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "IconDownLoader.h"
#import "CommandOperation.h"
@interface MessageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MBProgressHUDDelegate,CommandOperationDelegate,IconDownloaderDelegate>
{
    UITableView *_messageTableView;
	NSMutableArray *__listArray;
    
    UIActivityIndicatorView *spinner;
    UIActivityIndicatorView *indicatorView;
    NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
    
    int rowValue;
}
@property (nonatomic, retain) UITableView *messageTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@end
