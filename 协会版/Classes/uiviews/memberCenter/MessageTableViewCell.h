//
//  MessageTableViewCell.h
//  xieHui
//
//  Created by 来 云 on 12-10-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
{
    UIImageView *_cImageView;
	UILabel *_cName;
    UILabel *_cTime;
    UILabel *_cContent;
}
@property (nonatomic, retain) UIImageView *cImageView;
@property (nonatomic, retain) UILabel *cName;
@property (nonatomic, retain) UILabel *cContent;
@property (nonatomic, retain) UILabel *cTime;
@end
