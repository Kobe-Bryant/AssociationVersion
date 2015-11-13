//
//  InformationCell.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InformationCell.h"
#define kImageViewX  5
#define kSpace  5

@implementation InformationCell
@synthesize cImageView = _cImageView;
@synthesize cTitle = _cTitle;
@synthesize cContent = _cContent;
@synthesize cTime = _cTime;
@synthesize recommendImageView1 = _recommendImageView1;
@synthesize recommendImageView2 = _recommendImageView2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIImageView *newsBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX,kSpace,80 , 60)];
		UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:
							  [[NSBundle mainBundle] pathForResource:@"资讯列表图片背景" ofType:@"png"]];
		newsBackImageView.image = backImage;
		[backImage release];
		[self.contentView addSubview:newsBackImageView];
		
		UIImage *defaultImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认图资讯列表" ofType:@"png"]];
        _cImageView = [[UIImageView alloc] init];
		[_cImageView setFrame:CGRectMake(2, 2, 76, 56)];
		[_cImageView setImage:defaultImage];
		[newsBackImageView addSubview:_cImageView];
		
        _cTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + kImageViewX, kSpace, 190, 20)];
		_cTitle.text = @"";
		_cTitle.font = [UIFont systemFontOfSize:16.0f];
		_cTitle.textAlignment = UITextAlignmentLeft;
		_cTitle.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cTitle];
		
		_cContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + kImageViewX, CGRectGetMaxY(_cTitle.frame)+5, 190, 35)];
		_cContent.text = @"";
		_cContent.font = [UIFont systemFontOfSize:12.0f];
        _cContent.textColor = [UIColor grayColor];
		_cContent.textAlignment = UITextAlignmentLeft;
		_cContent.backgroundColor = [UIColor clearColor];
        _cContent.numberOfLines = 2;
        _cContent.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:_cContent];
		
        //		_cTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + 10, CGRectGetMaxY(_cContent.frame), 190, 20)];
        //		_cTime.text = @"";
        //		_cTime.font = [UIFont systemFontOfSize:12.0f];
        //		_cTime.textAlignment = UITextAlignmentLeft;
        //		_cTime.backgroundColor = [UIColor clearColor];
        //		[self.contentView addSubview:_cTime];
        
		UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
		UIImageView *separatorImageView = [[UIImageView alloc] init];
		[separatorImageView setFrame:CGRectMake(0, 70, 320, separatorImage.size.height)];
		[separatorImageView setImage:separatorImage];
		[self.contentView addSubview:separatorImageView];
		[separatorImageView release];
		[separatorImage release];
        
		UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
		UIImageView *arrowImageView = [[UIImageView alloc] init];
		[arrowImageView setFrame:CGRectMake(320 - kImageViewX - arrowImage.size.width, kImageViewX + (newsBackImageView.frame.size.height - arrowImage.size.height) * 0.5f, arrowImage.size.width, arrowImage.size.height)];
		[arrowImageView setImage:arrowImage];
		[self.contentView addSubview:arrowImageView];
		[arrowImageView release];
		[arrowImage release];
		
		_recommendImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
		UIImage *recommendImage1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"头条" ofType:@"png"]];
		_recommendImageView1.image = recommendImage1;
		[recommendImage1 release];
		[self.contentView addSubview:_recommendImageView1];
		_recommendImageView1.hidden = YES;
		
		_recommendImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
		UIImage *recommendImage2 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
		_recommendImageView2.image = recommendImage2;
		[recommendImage2 release];
		[self.contentView addSubview:_recommendImageView2];
		_recommendImageView2.hidden = YES;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[_cImageView release];
	[_cTitle release];
	[_cContent release];
	[_cTime release];
	[_recommendImageView1 release];
	[_recommendImageView2 release];
	_cImageView = nil;
	_cTitle = nil;
	_cContent = nil;
	_cTime = nil;
	_recommendImageView1 = nil;
	_recommendImageView2 = nil;
    [super dealloc];
}


@end
