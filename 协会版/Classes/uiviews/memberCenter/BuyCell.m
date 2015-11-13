//
//  BuyCell.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BuyCell.h"
#define kImageViewX  5
#define kSpace  5

@implementation BuyCell
@synthesize cTitle = _cTitle;
@synthesize cContent = _cContent;
@synthesize recommendImageView = _recommendImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cTitle = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewX * 2, kSpace, 290, 20)];
		_cTitle.text = @"";
		_cTitle.font = [UIFont systemFontOfSize:16.0f];
		_cTitle.textAlignment = UITextAlignmentLeft;
		_cTitle.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cTitle];
		
		_cContent = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewX * 2, kSpace * 5, 290, 40)];
		_cContent.text = @"";
        _cContent.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_cContent.font = [UIFont systemFontOfSize:12.0f];
        _cContent.numberOfLines = 0; 
		_cContent.textAlignment = UITextAlignmentLeft;
		_cContent.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cContent];
		
		UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
		UIImageView *separatorImageView = [[UIImageView alloc] init];
		[separatorImageView setFrame:CGRectMake(0, 70, 320, separatorImage.size.height)];
		[separatorImageView setImage:separatorImage];
		[self.contentView addSubview:separatorImageView];
		[separatorImageView release];
		[separatorImage release];
		
		UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
		UIImageView *arrowImageView = [[UIImageView alloc] init];
		[arrowImageView setFrame:CGRectMake(300, 30, 16, 11)];
		[arrowImageView setImage:arrowImage];
		[self.contentView addSubview:arrowImageView];
		[arrowImageView release];
		[arrowImage release];
		
		_recommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 285.0f, 0.0f, 30.0f , 30.0f)];
		UIImage *recommendImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"推荐" ofType:@"png"]];
		_recommendImageView.image = recommendImage;
		[recommendImage release];
		[self.contentView addSubview:_recommendImageView];
		_recommendImageView.hidden = YES;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[_cTitle release];
	[_recommendImageView release];
	_cTitle = nil;
	_cContent = nil;
	_recommendImageView = nil;
    [super dealloc];
}


@end
