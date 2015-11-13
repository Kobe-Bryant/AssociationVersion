//
//  contactsBookCatViewController.m
//  xieHui
//
//  Created by lai yun on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "contactsBookCatViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "contactsBookViewController.h"

@implementation contactsBookCatViewController

@synthesize myTableView;
@synthesize catItems;
@synthesize spinner;
@synthesize titleString;

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
	
//	self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]];
    
    self.title = self.titleString == nil ? @"分 类" : self.titleString;
	
//	//商铺数据初始化
//	NSMutableArray *tempCatArray = [[NSMutableArray alloc] init];
//	self.catItems = tempCatArray;
//	[tempCatArray release];
    
    if (self.catItems == nil)
    {
        //添加loading图标
        UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, (self.view.frame.size.height - 44.0f) / 2.0)];
        self.spinner = tempSpinner;
        
        UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
        loadingLabel.font = [UIFont systemFontOfSize:14];
        loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
        loadingLabel.text = LOADING_TIPS;
        loadingLabel.textAlignment = UITextAlignmentCenter;
        loadingLabel.backgroundColor = [UIColor clearColor];
        [self.spinner addSubview:loadingLabel];
        [self.view addSubview:self.spinner];
        [self.spinner startAnimating];
        [tempSpinner release];
        
        //网络请求
        [self accessItemService];
    }
    else
    {
        //添加表视图
        [self addTableView];
    }
}

//添加数据表视图
-(void)addTableView;
{
	//[self.myTableView removeFromSuperview];
	
	//初始化tableView
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 320.0f , self.view.frame.size.height)];
	[tempTableView setDelegate:self];
	[tempTableView setDataSource:self];
	self.myTableView = tempTableView;
	[tempTableView release];
	self.myTableView.backgroundColor = [UIColor colorWithRed:TAB_COLOR_RED green:TAB_COLOR_GREEN blue:TAB_COLOR_BLUE alpha:1.0];
	[self.view addSubview:myTableView];
	[self.view sendSubviewToBack:self.myTableView];
	[self.myTableView reloadData];
    
}

//网络获取数据
-(void)accessItemService
{
	NSString *reqUrl = @"mailcats.do?param=%@";
	
	NSDictionary *jsontestDic = [NSDictionary dictionaryWithObjectsAndKeys:
								 [Common getSecureString],@"keyvalue",
								 [Common getVersion:OPERAT_CONTACTS_BOOK_CAT_REFRESH],@"ver",
								 [NSNumber numberWithInt: SITE_ID],@"site_id",nil];
	
	[[DataManager sharedManager] accessService:jsontestDic 
									   command:OPERAT_CONTACTS_BOOK_CAT_REFRESH 
								  accessAdress:reqUrl
									  delegate:self 
									 withParam:nil];
}

//更新分类操作
-(void)updateCat
{
	//移出loading
    [self.spinner removeFromSuperview];
    
    //更新数据
    self.catItems = [DBOperate queryData:T_CONTACTS_BOOK_CAT
                                    theColumn:@"parent_id" theColumnValue:@"0" orderBy:@"sort_order" orderType:@"asc" withAll:NO];

    //添加表视图
    [self addTableView];
    
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver;
{
	[self performSelectorOnMainThread:@selector(updateCat) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.catItems count] == 0)
    {
        return 1;
    }
    else
    {
        return [self.catItems count];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
	
	NSMutableArray *items = self.catItems;
	int countItems =  [self.catItems count];
	
	if (items != nil && countItems > 0)
    {
        //记录
        CellIdentifier = @"listCell";
    }
    else
    {
        //没有记录
        CellIdentifier = @"noneCell";
    }
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		self.myTableView.separatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//cell.backgroundView = 
		//cell.selectedBackgroundView = 
		
        if (items != nil && countItems > 0)
        {
            self.myTableView.separatorColor = [UIColor clearColor];
            UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 0.0f , cell.frame.size.height - 2.0f, cell.frame.size.width, 2.0f)];
            UIImage * lineImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
            lineImageView.image = lineImg;
            [lineImg release];
            [cell.contentView addSubview:lineImageView];
            [lineImageView release];
            
            UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(300, 16, 16, 11)];
            UIImage *rimg;
            rimg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"右箭头" ofType:@"png"]];
            rightImage.image = rimg;
            [rimg release];
            [cell.contentView addSubview:rightImage];
            [rightImage release];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.tag = 100;
            nameLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            nameLabel.font = [UIFont systemFontOfSize:16];
            nameLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
            [cell.contentView addSubview:nameLabel];
            [nameLabel release];
            
            cell.backgroundColor = [UIColor clearColor];
            
        }
        else
        {
            UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 6, 300, 30)];
            noneLabel.tag = 201;
            [noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
            noneLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
            noneLabel.text = @"没找到分类信息！";			
            noneLabel.textAlignment = UITextAlignmentCenter;
            noneLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:noneLabel];
            [noneLabel release];
        }
		
	}
	
	if ([indexPath row] != countItems && countItems != 0){
		
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:100];
		
		NSArray *catArray = [items objectAtIndex:[indexPath row]];
		
        [nameLabel setFrame:CGRectMake(12 , 12 , cell.frame.size.width - 20, 20)];
		
		nameLabel.text = [catArray objectAtIndex:shop_cat_name];

	}
	
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (self.catItems != nil && [self.catItems count] > 0)
	{
        NSArray *catArray = [self.catItems objectAtIndex:[indexPath row]];
        NSString *catId = [catArray objectAtIndex:c_b_cat_id];
        
        //更新数据
        NSMutableArray *subCatArray = [DBOperate queryData:T_CONTACTS_BOOK_CAT
                                   theColumn:@"parent_id" theColumnValue:catId orderBy:@"sort_order" orderType:@"asc" withAll:NO];
        
        //如果存在二级分类 则显示二级分类列表
        if ([subCatArray count] > 0)
        {
            contactsBookCatViewController *contactsBookCat = [[contactsBookCatViewController alloc] init];
            contactsBookCat.catItems = subCatArray;
            contactsBookCat.titleString = [catArray objectAtIndex:c_b_cat_name];
            [self.navigationController pushViewController:contactsBookCat animated:YES];
            [contactsBookCat release];
        }
        else
        {
            //设置返回本类按钮
            UIBarButtonItem * tempButtonItem = [[ UIBarButtonItem alloc] init]; 
            tempButtonItem.title = @"返回";
            self.navigationItem.backBarButtonItem = tempButtonItem ; 
            [tempButtonItem release];

           
            contactsBookViewController *contactsBook = [[contactsBookViewController alloc] init];			
            contactsBook.catId = catId;
            [self.navigationController pushViewController:contactsBook animated:YES];
            [contactsBook release];
        }
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.catItems = nil;
	self.spinner = nil;
}


- (void)dealloc {
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.catItems = nil;
	self.spinner = nil;
    [super dealloc];
}


@end