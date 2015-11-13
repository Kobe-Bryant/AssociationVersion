//
//  InformationCell.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InformationCell : UITableViewCell {

	UIImageView *_cImageView;     //图片
    UILabel *_cTitle;   
    UILabel *_cContent; 
	UILabel *_cTime;
	UIImageView *_recommendImageView1;
	UIImageView *_recommendImageView2;
}
@property (nonatomic, retain) UIImageView *cImageView;
@property (nonatomic, retain) UILabel *cTitle;
@property (nonatomic, retain) UILabel *cContent;
@property (nonatomic, retain) UILabel *cTime;
@property (nonatomic, retain) UIImageView *recommendImageView1;
@property (nonatomic, retain) UIImageView *recommendImageView2;
@end
