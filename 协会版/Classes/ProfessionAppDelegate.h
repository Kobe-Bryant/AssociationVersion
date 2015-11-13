//
//  ProfessionAppDelegate.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandOperation.h"
#import "BMapKit.h"
#import "WXApi.h"

@class showPushAlert;

@protocol APPlicationDelegate <NSObject>

- (void) handleCallBack:(NSDictionary*)info;

@end

@interface ProfessionAppDelegate : NSObject <UIApplicationDelegate,CommandOperationDelegate,CLLocationManagerDelegate,WXApiDelegate> {
    UIWindow *window;
	UINavigationController *navController;
    UIButton *loginBtn;
	UIImage *headerImage;
	NSString *myDeviceToken;
    NSString *province;
	NSString *city;
	NSString *LatitudeAndLongitude;
	showPushAlert *pushAlert;
    int lastContactsBooksId;
    int contactsBookVer;
    
    BMKMapManager *_mapManager;
    id<APPlicationDelegate> delegate;
}
@property (nonatomic, retain) UIImage *headerImage;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UIButton *loginBtn;
@property (nonatomic, retain) NSString *myDeviceToken;
@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *LatitudeAndLongitude;
@property (nonatomic, retain) showPushAlert *pushAlert;
@property (nonatomic,assign) id<APPlicationDelegate> delegate;

// dufu add 2013.05.15
@property (nonatomic, retain) NSString *addressCity;

//获取地理位置
- (void)getLocation;

- (void)isAutoLogin;
-(void)showString:(NSDictionary*)userInfo;
@end

