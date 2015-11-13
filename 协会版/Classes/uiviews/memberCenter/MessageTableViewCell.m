//
//  MessageTableViewCell.m
//  xieHui
//
//  Created by 来 云 on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#define kImageViewX  10
#define kSpace  5

@implementation MessageTableViewCell
@synthesize cImageView = _cImageView;
@synthesize cName = _cName;
@synthesize cTime = _cTime;
@synthesize cContent = _cContent;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX , kSpace , 50, 50)];
		[self.contentView addSubview:_cImageView];
        
        _cImageView.layer.masksToBounds = YES;
        _cImageView.layer.cornerRadius = 6;
        
        //        UIImageView *shopBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake( kImageViewX  ,kSpace ,50 , 50)];
        //		UIImage *backImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"头像遮罩" ofType:@"png"]];
        //		shopBGImageView.image = backImage;
        //		[backImage release];
        //		[self.contentView addSubview:shopBGImageView];
        //		[shopBGImageView release];
		
        _cName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, kSpace, 150, 25)];
		_cName.text = @"";
		_cName.font = [UIFont systemFontOfSize:18.0f];
		_cName.textAlignment = UITextAlignmentLeft;
		_cName.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cName];
        
        _cTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cName.frame) - 5, kSpace, 120, 20)];
		_cTime.text = @"";
        _cTime.textColor = [UIColor grayColor];
		_cTime.font = [UIFont systemFontOfSize:12.0f];
		_cTime.textAlignment = UITextAlignmentLeft;
		_cTime.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cTime];
        
        _cContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, CGRectGetMaxY(_cName.frame), 240, 20)];
		_cContent.text = @"";
        _cContent.textColor = [UIColor grayColor];
        _cContent.numberOfLines = 2;
		_cContent.font = [UIFont systemFontOfSize:14.0f];
		_cContent.textAlignment = UITextAlignmentLeft;
		_cContent.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cContent];
        
        UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
		UIImageView *separatorImageView = [[UIImageView alloc] init];
		[separatorImageView setFrame:CGRectMake(0, CGRectGetMaxY(_cImageView.frame) + 4, 320, separatorImage.size.height)];
		[separatorImageView setImage:separatorImage];
		[self.contentView addSubview:separatorImageView];
		[separatorImageView release];
		[separatorImage release];		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [_cImageView release];
    [_cName release];
    [_cTime release];
    [_cContent release];
    [super dealloc];
}
@end
