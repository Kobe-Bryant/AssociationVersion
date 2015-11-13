//
//  ShopsCell.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ShopsCell : UITableViewCell {
	UIImageView *_cImageView;
	UILabel *_cName;
	UILabel *_cTel;
	UILabel *_cAddress;
	UIImageView *_cAttestationImageView;

}
@property (nonatomic, retain) UIImageView *cImageView;
@property (nonatomic, retain) UILabel *cName;
@property (nonatomic, retain) UILabel *cTel;
@property (nonatomic, retain) UILabel *cAddress;
@property (nonatomic, retain) UIImageView *cAttestationImageView;
@end
