//
//  HaveAppDownloadViewController.h
//  xieHui
//
//  Created by LuoHui on 13-4-23.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IconDownLoader.h"
@interface HaveAppDownloadViewController : UIViewController <IconDownloaderDelegate>
{
    UIImageView *logoView;
    UILabel *appNameLabel;
    NSString *logoImageUrl;
    NSString *appName;
    NSString *appUrl;
    
    IconDownLoader *iconDownLoad;
	NSMutableDictionary *imageDownloadsInProgress;
	NSMutableArray *imageDownloadsInWaiting;
    
    CGFloat picWidth;
    CGFloat picHeight;
}
@property (nonatomic, retain) NSString *logoImageUrl;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *appUrl;
@property (nonatomic, retain) IconDownLoader *iconDownLoad;
@property(nonatomic, retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@end
