//
//  recommendCellViewController.m
//  recommendCell
//
//  Created by siphp on 13-01-05.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "activityCellViewController.h"
#import "myImageView.h"

#define MARGIN_TOP 10.0f
#define MARGIN_LEFT 10.0f

@implementation activityCellViewController

@synthesize picView = _picView;
@synthesize titleLabel = _titleLabel;
@synthesize companyLabel = _companyLabel;
@synthesize timeLabel = _timeLabel;
@synthesize addressLabel = _addressLabel;
@synthesize interestLabel = _interestLabel;
@synthesize statusLabel = _statusLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)CellIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:CellIdentifier];
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake( MARGIN_LEFT , 0.0f , 300.0f , 180.0f)];
        cellContentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:cellContentView];
        [cellContentView release];
        
        //标题
        UILabel *tempTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake( MARGIN_LEFT , 0.0f , cellContentView.frame.size.width - (MARGIN_LEFT*2), 45.0f)];
        tempTitleLabel.backgroundColor = [UIColor clearColor];
        tempTitleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        tempTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        tempTitleLabel.numberOfLines = 2;
        tempTitleLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
        tempTitleLabel.text = @"";
        self.titleLabel = tempTitleLabel;
        [cellContentView addSubview:self.titleLabel];
        [tempTitleLabel release];
        
        //线
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(self.titleLabel.frame) , cellContentView.frame.size.width, 1.0f)];
        lineView1.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
        [cellContentView addSubview:lineView1];
        [lineView1 release];
        
        //图片
        myImageView *tempPicView = [[myImageView alloc] initWithFrame:CGRectMake( MARGIN_LEFT , CGRectGetMaxY(lineView1.frame) + 10.0f , 100.0f, 75.0f)];
        self.picView = tempPicView;
        self.picView.backgroundColor = [UIColor clearColor];
        [cellContentView addSubview:self.picView];
        [tempPicView release];
        
        //发起单位
        UIImageView *companyImageView = [[UIImageView alloc]initWithFrame:CGRectMake( CGRectGetMaxX(self.picView.frame) + 5.0 , CGRectGetMaxY(lineView1.frame) + 12.0f , 16.0f, 16.0f)];
        UIImage *companyImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_发起单位" ofType:@"png"]];
        companyImageView.image = companyImage;
        [companyImage release];
        [cellContentView addSubview:companyImageView];
        [companyImageView release];
        
        UILabel *tempCompanyLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(companyImageView.frame) + 4.0f, CGRectGetMaxY(self.titleLabel.frame) + 10.0f, 160.0f, 25.0f)];
        tempCompanyLabel.backgroundColor = [UIColor clearColor];
        tempCompanyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        tempCompanyLabel.font = [UIFont systemFontOfSize:12];
        tempCompanyLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        tempCompanyLabel.text = @"";
        tempCompanyLabel.textAlignment = UITextAlignmentLeft;
        tempCompanyLabel.numberOfLines = 1;
        self.companyLabel = tempCompanyLabel;
        [cellContentView addSubview:self.companyLabel];
        [tempCompanyLabel release];

        //时间
        UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake( CGRectGetMaxX(self.picView.frame) + 5.0 , CGRectGetMaxY(self.companyLabel.frame) + 3.0f , 16.0f, 16.0f)];
        UIImage *timeImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_日期" ofType:@"png"]];
        timeImageView.image = timeImage;
        [timeImage release];
        [cellContentView addSubview:timeImageView];
        [timeImageView release];
        
        UILabel *tempTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(timeImageView.frame) + 4.0f, CGRectGetMaxY(self.companyLabel.frame), 160.0f, 25.0f)];
        tempTimeLabel.backgroundColor = [UIColor clearColor];
        tempTimeLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        tempTimeLabel.font = [UIFont systemFontOfSize:12];
        tempTimeLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        tempTimeLabel.text = @"";
        tempTimeLabel.textAlignment = UITextAlignmentLeft;
        tempTimeLabel.numberOfLines = 1;
        self.timeLabel = tempTimeLabel;
        [cellContentView addSubview:self.timeLabel];
        [tempTimeLabel release];
        
        //地址
        UIImageView *addressImageView = [[UIImageView alloc]initWithFrame:CGRectMake( CGRectGetMaxX(self.picView.frame) + 5.0 , CGRectGetMaxY(self.timeLabel.frame) + 3.0f , 16.0f, 16.0f)];
        UIImage *addressImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_活动列表_地址" ofType:@"png"]];
        addressImageView.image = addressImage;
        [addressImage release];
        [cellContentView addSubview:addressImageView];
        [addressImageView release];
        
        UILabel *tempAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(addressImageView.frame) + 4.0f, CGRectGetMaxY(self.timeLabel.frame), 160.f, 40.f)];
        tempAddressLabel.backgroundColor = [UIColor clearColor];
        tempAddressLabel.lineBreakMode = UILineBreakModeWordWrap; // | UILineBreakModeTailTruncation
        tempAddressLabel.font = [UIFont systemFontOfSize:12];
        tempAddressLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        tempAddressLabel.text = @"";
        tempAddressLabel.textAlignment = UITextAlignmentLeft;
        tempAddressLabel.numberOfLines = 0;
        self.addressLabel = tempAddressLabel;
        [cellContentView addSubview:self.addressLabel];
        [tempAddressLabel release];
        
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , cellContentView.frame.size.height - 31.0f , cellContentView.frame.size.width, 1.0f)];
        lineView2.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
        [cellContentView addSubview:lineView2];
        [lineView2 release];
        
        UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake( cellContentView.frame.size.width / 2 , cellContentView.frame.size.height - 31.0f , 1.0f , 30.0f)];
        lineView3.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
        [cellContentView addSubview:lineView3];
        [lineView3 release];
        
        UILabel *tempInterestLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(lineView2.frame), cellContentView.frame.size.width / 2 , 30.0f)];
        tempInterestLabel.backgroundColor = [UIColor clearColor];
        tempInterestLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        tempInterestLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
        tempInterestLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        tempInterestLabel.text = @"";
        tempInterestLabel.textAlignment = UITextAlignmentCenter;
        tempInterestLabel.numberOfLines = 1;
        self.interestLabel = tempInterestLabel;
        [cellContentView addSubview:self.interestLabel];
        [tempInterestLabel release];
        
        UILabel *tempStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(lineView3.frame) , CGRectGetMaxY(lineView2.frame), cellContentView.frame.size.width / 2 , 30.0f)];
        tempStatusLabel.backgroundColor = [UIColor clearColor];
        tempStatusLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        tempStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
        tempStatusLabel.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
        tempStatusLabel.text = @"";
        tempStatusLabel.textAlignment = UITextAlignmentCenter;
        tempStatusLabel.numberOfLines = 1;
        self.statusLabel = tempStatusLabel;
        [cellContentView addSubview:self.statusLabel];
        [tempStatusLabel release];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    _picView = nil;
    _titleLabel = nil;
    _companyLabel = nil;
    _timeLabel = nil;
    _addressLabel = nil;
    _interestLabel = nil;
    _statusLabel = nil;
    [super dealloc];
}


@end
