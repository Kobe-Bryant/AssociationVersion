//
//  ProductCell.h
//  Profession
//
//  Created by 云 来 on 12-8-20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductCell : UITableViewCell 
{

	UIImageView *_pImageView;     //图片
    UILabel *_pTitle;   
    UILabel *_pContent; 
	UILabel *_pMoney;
	UILabel *_pLevel;
    BOOL isImageDownLoad;
	UIImageView *_recommendImageView;
    UIImageView *moneyView;
    UIImageView *levelView;
}
@property (nonatomic, retain) UIImageView *pImageView;
@property (nonatomic, retain) UILabel *pTitle;
@property (nonatomic, retain) UILabel *pContent;
@property (nonatomic, retain) UILabel *pMoney;
@property (nonatomic, retain) UILabel *pLevel;
@property (nonatomic, assign) BOOL isImageDownLoad;
@property (nonatomic, retain) UIImageView *recommendImageView;
@property (nonatomic, retain) UIImageView *moneyView;
@property (nonatomic, retain) UIImageView *levelView;

@end
