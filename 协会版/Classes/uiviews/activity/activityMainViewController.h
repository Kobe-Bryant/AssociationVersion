//
//  activityMainViewController.h
//  xieHui
//
//  Created by siphp on 13-4-24.
//
//

#import <UIKit/UIKit.h>

@class activityViewController;
@class activityHistoryViewController;

@interface activityMainViewController : UIViewController
{
    int currentSelectedIndex;
    activityViewController *activityView;
    activityHistoryViewController *activityHistoryView;
    BOOL isFromAd;
    int infoId;
}

@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, retain) activityViewController *activityView;
@property (nonatomic, retain) activityHistoryViewController *activityHistoryView;
@property(nonatomic,assign) BOOL isFromAd;
@property(nonatomic,assign) int infoId;

//工具栏
-(void)showToolBar;

//功能按钮
-(void)buttonClick:(id)sender;

//近期活动
-(void)activity;

//往期活动
-(void)activityHistory;

@end
