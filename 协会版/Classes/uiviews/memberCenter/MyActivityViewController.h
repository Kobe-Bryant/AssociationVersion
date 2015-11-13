//
//  MyActivityViewController.h
//  xieHui
//
//  Created by LuoHui on 13-4-24.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "CommandOperation.h"
#import "MBProgressHUD.h"
#import "myImageView.h"

enum my_activity {
	my_activity_id,
    my_activity_title,
    my_activity_organizer,
    my_activity_address,
    my_activity_point_lng,
    my_activity_point_lat,
    my_activity_reg_end_time,
    my_activity_begin_time,
    my_activity_end_time,
    my_activity_activity_img_num,
    my_activity_desc,
    my_activity_phone,
    my_activity_report_url,
    my_activity_sum,
    my_activity_interests,
    my_activity_pic,
    my_activity_pics,
    my_activity_user_pics,
    my_activity_join_time
};

@interface MyActivityViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,CommandOperationDelegate,MBProgressHUDDelegate,myImageViewDelegate>
{
    UITableView *_myTableView;
    NSMutableArray *__listArray;
    
    UIView *noItemView;
    UIView *haveItemView;
    
    UIActivityIndicatorView *indicatorView;
    NSMutableDictionary *imageDownloadsInProgressDic;
	NSMutableArray *imageDownloadsInWaitingArray;
	IconDownLoader *iconDownLoad;
    
    UIActivityIndicatorView *spinner;
    CGFloat picWidth;
    CGFloat picHeight;
    
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgressDic;
@property (nonatomic, retain) NSMutableArray *imageDownloadsInWaitingArray;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@end 
