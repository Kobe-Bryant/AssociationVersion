//
//  ShopsCell.m
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopsCell.h"

#define kImageViewX  5
#define kSpace  5

@implementation ShopsCell
@synthesize cImageView = _cImageView;
@synthesize cName = _cName;
@synthesize cTel = _cTel;
@synthesize cAddress = _cAddress;
@synthesize cAttestationImageView = _cAttestationImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
		_cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageViewX , kSpace , 75, 75)];
//        _cImageView.layer.masksToBounds = YES;
//        _cImageView.layer.cornerRadius = 10;
		[self.contentView addSubview:_cImageView];
		
        _cName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, kSpace, 200, 30)];
		_cName.text = @"";
		_cName.font = [UIFont systemFontOfSize:18.0f];
		_cName.textAlignment = UITextAlignmentLeft;
		_cName.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cName];
		
		_cTel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, CGRectGetMaxY(_cName.frame), 200, 20)];
		_cTel.text = @"";
		_cTel.font = [UIFont systemFontOfSize:14.0f];
        _cTel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_cTel.textAlignment = UITextAlignmentLeft;
		_cTel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cTel];
		
		_cAddress = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, CGRectGetMaxY(_cTel.frame), 200, 20)];
		_cAddress.text = @"";
		_cAddress.font = [UIFont systemFontOfSize:12.0f];
        _cAddress.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
		_cAddress.textAlignment = UITextAlignmentLeft;
		_cAddress.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_cAddress];
		
		UIImage *separatorImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"线" ofType:@"png"]];
		UIImageView *separatorImageView = [[UIImageView alloc] init];
		[separatorImageView setFrame:CGRectMake(0, 85, 320, separatorImage.size.height)];
		[separatorImageView setImage:separatorImage];
		[self.contentView addSubview:separatorImageView];
		[separatorImageView release];
		[separatorImage release];
		
		UIImage *arrowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_arrow" ofType:@"png"]];
		UIImageView *arrowImageView = [[UIImageView alloc] init];
		[arrowImageView setFrame:CGRectMake(320 - kImageViewX - arrowImage.size.width, kImageViewX + (_cImageView.frame.size.height - arrowImage.size.height) * 0.5f, arrowImage.size.width, arrowImage.size.height)];
		[arrowImageView setImage:arrowImage];
		[self.contentView addSubview:arrowImageView];
		[arrowImageView release];
		[arrowImage release];
		
		_cAttestationImageView = [[UIImageView alloc] initWithFrame:CGRectMake( kImageViewX - 1.0f, kImageViewX + 10.0f, 34.0f , 34.0f)];
		UIImage *attestationImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺认证标识" ofType:@"png"]];
		_cAttestationImageView.image = attestationImage;
		_cAttestationImageView.hidden = YES;
		[self.contentView addSubview:_cAttestationImageView];
		[attestationImage release];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[_cImageView release];
	[_cName release];
	[_cTel release];
	[_cAddress release];
	[_cAttestationImageView release];
	
	_cImageView = nil;
	_cName = nil;
	_cTel = nil;
	_cAddress = nil;
	_cAttestationImageView = nil;
    [super dealloc];
}


@end
