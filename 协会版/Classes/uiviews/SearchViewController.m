//
//  SearchViewController.m
//  Profession
//
//  Created by MC374 on 12-8-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "DBOperate.h"
#import "SearchShopResultViewController.h"
#import "SearchMemberResultViewController.h"
#import "Common.h"

@implementation SearchViewController
@synthesize preSelectBtn;
@synthesize searchRecordArray;
@synthesize selectIndex;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"搜索";
	
	self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏
    UINavigationBar *navBar = [self.navigationController navigationBar];
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        // set globablly for all UINavBars
        UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NAV_BG_PIC ofType:nil]];
        [navBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [img release];
    }
    
    self.navigationController.navigationBar.tintColor = COLOR_BAR_BUTTON;//[UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1];
	
	UIImageView *backiv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,320, 480)];
	UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"背景" ofType:@"png"]];
	backiv.image = img;
	[img release];
    [self.view addSubview:backiv];
	[backiv release];
	
	UIBarButtonItem* barbutton= [[UIBarButtonItem alloc] 
								 initWithTitle:@"取消" 
								 style:UIBarButtonItemStyleDone 
								 target:self action:@selector(returnView)]; 
	[self.navigationItem setRightBarButtonItem:barbutton];   
	[barbutton release]; 
	
    if (IOS_VERSION >= 7.0) {
        [barbutton setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    }
    
	//添加table背景
	UIImageView *tableBackView = [[UIImageView alloc] initWithFrame:
								  CGRectMake(0, 46, 320, 400)];
	tableBackView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:tableBackView];
	[tableBackView release];
	
	//添加两个按钮
	int buttonWidth = 120;
	int buttonHeight = 30;
	int tag = 100;
	int k = 5;
	
	for(int i = 0;i < 2;i++){
		UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
		[button1 setFrame:CGRectMake(40 + i * buttonWidth, 8, buttonWidth, buttonHeight)];
		button1.tag = tag++;
		[button1 addTarget:self action:@selector(HandleSegment:) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *Ltitle = [[UILabel alloc]initWithFrame:CGRectMake(4, 4, buttonWidth-8, buttonHeight-8)];
		Ltitle.font = [UIFont boldSystemFontOfSize:14.0];
		Ltitle.textAlignment = UITextAlignmentCenter;
		Ltitle.tag = k++;
		Ltitle.backgroundColor = [UIColor clearColor];
		Ltitle.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
		if (i == 0) {
			Ltitle.text = SEARCH_MEMBER_NAME;			
		}else {
			Ltitle.text = SEARCH_SHOP_NAME;			
		}
		
		
		[button1 addSubview:Ltitle];
		[Ltitle release];
		
		UIImage *turnbackImg;
		if (i == 0) {
			turnbackImg = [[UIImage alloc]initWithContentsOfFile:
						   [[NSBundle mainBundle] pathForResource:@"搜索_分类_背景左" ofType:@"png"]];
		}else {
			turnbackImg = [[UIImage alloc]initWithContentsOfFile:
						   [[NSBundle mainBundle] pathForResource:@"搜索_分类_背景右" ofType:@"png"]];
		}
		[button1 setImage:turnbackImg forState:UIControlStateNormal];
		[turnbackImg release];
		UIImage *turnbackImg1;
		if (i == 0) {
			turnbackImg1 = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"搜索_分类_选中背景左" ofType:@"png"]];
		}else {
			turnbackImg1 = [[UIImage alloc]initWithContentsOfFile:
							[[NSBundle mainBundle] pathForResource:@"搜索_分类_选中背景右" ofType:@"png"]];
			
		}
		[button1 setImage:turnbackImg1 forState:UIControlStateSelected ];
		[turnbackImg1 release];
		[self.view addSubview:button1];
	}
	
}

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	seachBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 22, 260, 40)];
    seachBar.autocorrectionType = UITextAutocorrectionTypeNo;
    seachBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	seachBar.delegate = self;
	for (UIView *subview in seachBar.subviews) 	{  
		if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
		{  
			[subview removeFromSuperview];  
			break;
		}  
	} 
	//	[seachBar becomeFirstResponder];
    
    //ios7新特性--- 解决UISearchBar的背景色
    if ([seachBar respondsToSelector:@selector(barTintColor)]) {
        [seachBar setBarTintColor:[UIColor clearColor]];
    }
    
	[self.navigationController.view addSubview:seachBar];
		
	self.searchRecordArray = [DBOperate queryData:T_SEARCH_RECORD 
										theColumn:@"type" theColumnValue:[NSString stringWithFormat:@"%d",selectIndex] withAll:NO];
	//添加搜索记录tableview
	recordTableView = [[UITableView alloc] initWithFrame:
					   CGRectMake(0, 46, 320, self.view.frame.size.height-46)];
	recordTableView.scrollEnabled = YES;
	recordTableView.delegate = self;
	recordTableView.dataSource = self;
	[self.view addSubview:recordTableView];
	[self HandleSegment:[self.view viewWithTag:100 + selectIndex]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.preSelectBtn = nil;
	self.searchRecordArray = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[preSelectBtn release],preSelectBtn = nil;
	[searchRecordArray release],searchRecordArray = nil;
	[seachBar release],seachBar = nil;
}

- (void)returnView

{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)segmentAction:(id)sender{
	
}

- (void) HandleSegment:(id)sender{
	if (preSelectBtn != nil) {
		preSelectBtn.selected = NO;
	}
	UILabel *prelabel = (UILabel*)[preSelectBtn viewWithTag:(preSelectBtn.tag - 95)];
	prelabel.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
	UIButton *bto = (UIButton*)sender;
	bto.selected = YES;
	self.preSelectBtn = bto;
	UILabel *label = (UILabel*)[bto viewWithTag:(bto.tag - 95)];
	label.textColor = [UIColor blackColor];
	switch (bto.tag) {
		case 100:
		{
			selectIndex = search_member;
			break;
		}
		case 101:
		{
			selectIndex = search_shops;
			break;	
		}
	}
	self.searchRecordArray = [DBOperate queryData:T_SEARCH_RECORD 
										theColumn:@"type" theColumnValue:[NSString stringWithFormat:@"%d",selectIndex] withAll:NO];
	[recordTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([searchRecordArray count] > 0) {
		return [searchRecordArray count];
	}else {
		return 1;
	}

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
		
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];	
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
		//ios7新特性,解决分割线短一点
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
		if ([searchRecordArray count] > 0) {
			UILabel *record = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 100, 30)];
			record.backgroundColor = [UIColor clearColor];
			record.textAlignment = UITextAlignmentLeft;
			record.tag = 200;
			record.text = @"";
			[cell.contentView addSubview:record];
			[record release];
			
			//添加删除按钮
			UIButton *button1=[UIButton buttonWithType:UIButtonTypeCustom];
			[button1 setFrame:CGRectMake(320-20-20, 10, 20, 20)];
			[button1 addTarget:self action:@selector(deleteRecord:) forControlEvents:UIControlEventTouchUpInside];
			button1.tag = 400 + indexPath.row; 
			
			UIImage *turnbackImg = [[UIImage alloc]initWithContentsOfFile:
									[[NSBundle mainBundle] pathForResource:@"删除" ofType:@"png"]];
			[button1 setImage:turnbackImg forState:UIControlStateNormal];
			[turnbackImg release];
			[cell.contentView addSubview:button1];
		}else {
			UILabel *remindLB = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 30)];
			remindLB.backgroundColor = [UIColor clearColor];
			remindLB.textAlignment = UITextAlignmentCenter;
			remindLB.tag = 201;
			remindLB.text = @"";
			[cell.contentView addSubview:remindLB];
			[remindLB release];
		}
		
	}
	if ([searchRecordArray count] > 0) {
		UILabel *lb = (UILabel*)[cell.contentView viewWithTag:200];
		NSArray *ay = [searchRecordArray objectAtIndex:indexPath.row];
		lb.text = [ay objectAtIndex:searchrecord_content];
	}else {
		UILabel *lb = (UILabel*)[cell.contentView viewWithTag:201];
        lb.font = [UIFont systemFontOfSize:12.0f];
        lb.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
		if (selectIndex == 0) {
			lb.text = @"暂无搜索历史记录";
		}else if (selectIndex == 1) {
			lb.text = @"暂无搜索历史记录";
		}
	}

	return cell;
}	

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (searchRecordArray != nil && [searchRecordArray count] > 0) 
    {
        [seachBar removeFromSuperview];
        NSArray *ay = [searchRecordArray objectAtIndex:indexPath.row];
        
        if (selectIndex == search_shops) {
            SearchShopResultViewController *shopsresult = [[SearchShopResultViewController alloc] init];
            shopsresult.keyString = [ay objectAtIndex:searchrecord_content];
            [self.navigationController pushViewController:shopsresult animated:YES];
            [shopsresult release];
        }else if (selectIndex == search_member) {
            SearchMemberResultViewController *memberResult = [[SearchMemberResultViewController alloc] init];
            memberResult.keyString = [ay objectAtIndex:searchrecord_content];
            [self.navigationController pushViewController:memberResult animated:YES];
            [memberResult release];
        }
    }	
}

//ios7去掉cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self hideKeyboard];
}


-(void)hideKeyboard

{
	[seachBar resignFirstResponder];
//	NSTimeInterval animationDuration = 0.30f;
//	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//	[UIView setAnimationDuration:animationDuration];
//	CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, VIEW_HEIGHT - 20.0f - 44.0f);
//	self.view.frame = rect;
//	[UIView commitAnimations];
}

- (void) deleteRecord:(id)sender{
	UIButton *button = (UIButton*)sender;
	int btag = button.tag - 400;
	NSLog(@"tag:%d",btag);
	
	NSArray *ay = [searchRecordArray objectAtIndex:btag];
	int rid = [[ay objectAtIndex:searchrecord_id] intValue];
	
	[DBOperate deleteData:T_SEARCH_RECORD tableColumn:@"id" 
			  columnValue:[NSString stringWithFormat:@"%d",rid]];
	
	self.searchRecordArray = [DBOperate queryData:T_SEARCH_RECORD 
										theColumn:@"type" theColumnValue:[NSString stringWithFormat:@"%d",selectIndex] withAll:NO];
	[recordTableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//	self.searchRecordArray = [DBOperate queryData:T_SEARCH_RECORD 
//										theColumn:@"content" theColumnValue:searchText withAll:NO];
	
	self.searchRecordArray = [DBOperate queryData:T_SEARCH_RECORD theColumn:@"type" equalValue:[NSString stringWithFormat:@"%d",selectIndex]
										theColumn:@"content" equalValue:searchText];
	[recordTableView reloadData];	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	NSMutableArray *ay = [[NSMutableArray alloc] init];
	NSString *searchkey = searchBar.text;
	[ay addObject:[NSString stringWithFormat:@"%d",selectIndex]];
	[ay addObject:searchkey];
	[DBOperate insertData:ay tableName:T_SEARCH_RECORD];
	[ay release];
	
	[seachBar removeFromSuperview];
	
	if (selectIndex == search_shops) {
		SearchShopResultViewController *shopsresult = [[SearchShopResultViewController alloc] init];
		shopsresult.keyString = searchkey;
		[self.navigationController pushViewController:shopsresult animated:YES];
		[shopsresult release];
	}else if (selectIndex == search_member) {
		SearchMemberResultViewController *memberResult = [[SearchMemberResultViewController alloc] init];
		memberResult.keyString = searchkey;
		[self.navigationController pushViewController:memberResult animated:YES];
		[memberResult release];
	}
	
}

@end
