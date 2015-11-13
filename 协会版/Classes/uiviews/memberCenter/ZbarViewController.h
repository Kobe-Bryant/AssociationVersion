//
//  ZbarViewController.h
//  xieHui
//
//  Created by 来 云 on 12-11-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface ZbarViewController : UIViewController <ZBarReaderDelegate>
{
    UIImageView *memberHeaderView;
    UIImageView *zbarImageView;
}
@property (nonatomic, retain) UIImageView *memberHeaderView;

//保存二维码
-(void)saveCode;

@end
