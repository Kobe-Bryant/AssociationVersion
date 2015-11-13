//
//  demandRecommendViewController.h
//  Profession
//
//  Created by lai yun on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "DataManager.h"

@interface demandRecommendViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,CommandOperationDelegate> {
	UITableView *myTableView;
	NSMutableArray *demandItems;
	EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
	UIActivityIndicatorView *spinner;
    UILabel *moreLabel;
    BOOL _loadingMore;
    BOOL _isAllowLoadingMore;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *demandItems;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) UILabel *moreLabel;

//显示求购列表
-(void)showDemand;

//添加数据表视图
-(void)addTableView;

//网络获取数据
-(void)accessItemService;

//网络获取更多数据
-(void)accessMoreService:(int)itemUpdateTime;

//更新求购的操作
-(void)updateDemand;

//更多的操作
-(void)appendTableWith:(NSMutableArray *)data;

//回归常态
-(void)backNormal;

//更多回归常态
-(void)moreBackNormal:(BOOL)isHaveMoreData;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;


@end