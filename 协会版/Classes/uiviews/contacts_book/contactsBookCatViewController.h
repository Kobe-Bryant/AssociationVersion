//
//  contactsBookCatViewController.h
//  xieHui
//
//  Created by lai yun on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface contactsBookCatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,CommandOperationDelegate> {
	UITableView *myTableView;
	NSMutableArray *catItems;
	UIActivityIndicatorView *spinner;
    NSString *titleString;
}

@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) NSMutableArray *catItems;
@property(nonatomic,retain) UIActivityIndicatorView *spinner;
@property(nonatomic,retain) NSString *titleString;

//添加数据表视图
-(void)addTableView;

//网络获取数据
-(void)accessItemService;

//更新分类操作
-(void)updateCat;

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;

@end