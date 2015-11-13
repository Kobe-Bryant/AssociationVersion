//
//  showPushAlert.h
//  AppStrom
//
//  Created by 掌商 on 11-9-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface showPushAlert : NSObject{
	NSString *pushurl;
	NSString *pushTitle;
	UINavigationController *theSuperViewController;
	UIAlertView *alertV;
    int pushType;
    int pushInfoId;
}
@property(nonatomic,retain)UIAlertView *alertV;
@property(nonatomic,retain)UINavigationController *theSuperViewController;
@property(nonatomic,retain)NSString *pushurl;
@property(nonatomic,retain)NSString *pushTitle;
@property(nonatomic,assign)int pushType;
@property(nonatomic,assign)int pushInfoId;
-(void)showAlert;
-(id)initWithContent:(NSString*)content onViewController:(UINavigationController*)theViewController;
-(id)initWithDic:(NSDictionary*)userInfo onViewController:(UINavigationController*)theViewController;
-(id)initWithTitle:(NSString*)title url:(NSString*)purl onViewController:(UINavigationController*)theViewController;
@end
