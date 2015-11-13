//
//  NoAppDownloadViewController.h
//  xieHui
//
//  Created by LuoHui on 13-4-23.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommandOperation.h"
@interface NoAppDownloadViewController : UIViewController <CommandOperationDelegate>
{
    NSString *uId;
}
@property (nonatomic, retain) NSString *uId;
@end
