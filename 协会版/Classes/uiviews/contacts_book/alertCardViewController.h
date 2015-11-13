//
//  alertCardViewController.h
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UATitledModalPanel.h"
#import "cardDetailViewController.h"

@class cardDetailViewController;

@interface alertCardViewController : UATitledModalPanel<cardDetailDelegate>{
    
    NSMutableArray *cardInfo;
    NSString *cUserId;
    cardDetailViewController *cardDetail;
    
    NSString *mobileStr;
}

@property(nonatomic,retain) NSMutableArray *cardInfo;
@property(nonatomic,retain) NSString *cUserId;
@property(nonatomic,retain) cardDetailViewController *cardDetail;
@property (nonatomic, retain) NSString *mobileStr;

- (id)initWithFrame:(CGRect)frame info:(NSMutableArray *)cInfo userID:(NSString *)userId;
- (id)initWithFrame:(CGRect)frame  withContent:(NSString *)str withMobile:(NSString *)mobile;
@end
