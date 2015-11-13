//
//  BuyCell.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BuyCell : UITableViewCell {

	UILabel *_cTitle; 
	UILabel *_cContact;
    UILabel *_cContent;
	UIImageView *_recommendImageView;
}
@property (nonatomic, retain) UILabel *cTitle;
@property (nonatomic, retain) UILabel *cContact;
@property (nonatomic, retain) UILabel *cContent;
@property (nonatomic, retain) UIImageView *recommendImageView;
@end
