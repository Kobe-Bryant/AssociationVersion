//
//  SearchViewController.h
//  Profession
//
//  Created by MC374 on 12-8-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate> {
	UISearchBar *seachBar;
	UITableView *recordTableView;
	UIButton *preSelectBtn;
	NSArray *searchRecordArray;
	int selectIndex;
}

@property (nonatomic,retain) UIButton *preSelectBtn;
@property (nonatomic,retain) NSArray *searchRecordArray;
@property (nonatomic,assign) int selectIndex;
enum SEARCH_TYPE {
	search_member,
	search_shops
};

- (void) segmentAction:(id)sender;
- (void) HandleSegment:(id)sender;
- (void) deleteRecord:(id)sender;
- (void) hideKeyboard;
@end
