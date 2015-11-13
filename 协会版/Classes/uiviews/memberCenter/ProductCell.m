//
//  ProductCell.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductCell.h"
#define kImageViewX  5
#define kSpace  5

@implementation ProductCell
@synthesize pImageView = _pImageView;
@synthesize pTitle  = _pTitle;
@synthesize pContent = _pContent;
@synthesize pMoney = _pMoney;
@synthesize pLevel = _pLevel;
@synthesize isImageDownLoad;
@synthesize recommendImageView = _recommendImageView;
@synthesize levelView;
@synthesize moneyView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIImageView *newsBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX,kSpace,66 , 66)];
		UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:
							  [[NSBundle mainBundle] pathForResource:@"产品列表图背景" ofType:@"png"]];
		newsBackImageView.image = backImage;
		[backImage release];
		[self.contentView addSubview:newsBackImageView];
		
		UIImage *defaultImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"默认图产品列表图" ofType:@"png"]];
		_pImageView = [[UIImageView alloc] init];
		[_pImageView setFrame:CGRectMake(2, 2, 62, 62)];
		[_pImageView setImage:defaultImage];
		[newsBackImageView addSubview:_pImageView];
		
        _pTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + kImageViewX, kSpace, 190, 20)];
		_pTitle.text = @"";
		_pTitle.font = [UIFont systemFontOfSize:16];
        _pTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
		_pTitle.textAlignment = UITextAlignmentLeft;
		_pTitle.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_pTitle];
		
		_pContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + kImageViewX, CGRectGetMaxY(_pTitle.frame), 190, 20)];
		_pContent.text = @"";
		_pContent.font = [UIFont systemFontOfSize:12.0f];
        _pContent.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_pContent.textAlignment = UITextAlignmentLeft;
		_pContent.backgroundColor = [UIColor clearColor];
        _pContent.numberOfLines = 3;
		[self.contentView addSubview:_pContent];
		
		UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-mini-价格" ofType:@"png"]];
		moneyView = [[UIImageView alloc] initWithImage:image1];
		moneyView.frame = CGRectMake(CGRectGetMaxX(newsBackImageView.frame) + kImageViewX, CGRectGetMaxY(newsBackImageView.frame) - image1.size.height - 5.0f, image1.size.width, image1.size.height);
		[self.contentView addSubview:moneyView];
		[image1 release];
		
		_pMoney = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moneyView.frame) + kImageViewX, moneyView.frame.origin.y - 2 , 50, 20)];
		_pMoney.text = @"";
		_pMoney.font = [UIFont systemFontOfSize:12];
        _pMoney.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_pMoney.textAlignment = UITextAlignmentLeft;
		_pMoney.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_pMoney];
		
		UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-mini-收藏" ofType:@"png"]];
        levelView = [[UIImageView alloc] initWithImage:image2];
		levelView.frame = CGRectMake(CGRectGetMaxX(_pMoney.frame) + kImageViewX, CGRectGetMaxY(newsBackImageView.frame) - image2.size.height - 5.0f, image2.size.width, image2.size.height);
		[self.contentView addSubview:levelView];
		[image2 release];
		
		_pLevel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(levelView.frame) + kImageViewX, moneyView.frame.origin.y - 2, 50, 20)];
		_pLevel.text = @"";
		_pLevel.font = [UIFont systemFontOfSize:12];
        _pLevel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_pLevel.textAlignment = UITextAlignmentLeft;
		_pLevel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_pLevel];
		
		UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
		UIImageView *separatorImageView = [[UIImageView alloc] init];
		[separatorImageView setFrame:CGRectMake(0, CGRectGetMaxY(newsBackImageView.frame) + kImageViewX, 320, separatorImage.size.height)];
		[separatorImageView setImage:separatorImage];
		[self.contentView addSubview:separatorImageView];
		[separatorImageView release];
		
		UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
		UIImageView *arrowImageView = [[UIImageView alloc] init];
		[arrowImageView setFrame:CGRectMake(320 - kImageViewX - arrowImage.size.width, kImageViewX + (newsBackImageView.frame.size.height - arrowImage.size.height) * 0.5f, arrowImage.size.width, arrowImage.size.height)];
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
	[_pImageView release];
	[_pTitle release];
	[_pContent release];
	[_pMoney release];
	[_pLevel release];
	[_recommendImageView release];
    [moneyView release];
    [levelView release];
	_pImageView = nil;
	_pTitle = nil;
	_pContent = nil;
	_pMoney = nil;
	_pLevel = nil;
	_recommendImageView = nil;
    moneyView = nil;
    levelView = nil;
    [super dealloc];
}


@end
