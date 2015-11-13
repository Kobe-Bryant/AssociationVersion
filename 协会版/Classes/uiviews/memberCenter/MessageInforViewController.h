//
//  MessageInforViewController.h
//  xieHui
//
//  Created by 来 云 on 12-10-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardDetailViewController.h"
@interface MessageInforViewController : UIViewController <cardDetailDelegate>
{
    NSString *catId;
    cardDetailViewController *cardDetail;
}
@property (nonatomic, retain) NSString *catId;
@property (nonatomic, retain) cardDetailViewController *cardDetail;
@end
