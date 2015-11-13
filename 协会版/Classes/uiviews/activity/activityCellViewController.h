//
//  recommendCellViewController.h
//  recommendCell
//
//  Created by siphp on 13-01-05.
//  Copyright 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>

@class myImageView;

@interface activityCellViewController : UITableViewCell 
{
	myImageView *_picView;
    UILabel *_titleLabel;
    UILabel *_companyLabel;
    UILabel *_timeLabel;
    UILabel *_addressLabel;
    UILabel *_interestLabel;
    UILabel *_statusLabel;
}
@property (nonatomic, retain) myImageView *picView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *companyLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *addressLabel;
@property (nonatomic, retain) UILabel *interestLabel;
@property (nonatomic, retain) UILabel *statusLabel;


@end
