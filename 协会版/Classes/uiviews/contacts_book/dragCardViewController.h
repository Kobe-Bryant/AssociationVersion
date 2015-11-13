//
//  dragCardViewController.h
//  myCard
//
//  Created by lai yun on 12-10-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardDetailViewController.h"

@protocol dragCardDelegate
@optional
- (void)feedback;
- (void)favoriteLogin;
- (void)goUrl:(NSString *)url;
@end

@class cardDetailViewController;

@interface dragCardViewController : UIViewController<cardDetailDelegate>{
    
    NSObject<dragCardDelegate> *delegate;
    NSMutableArray *cardInfo;
    NSString *cUserId;
    cardDetailViewController *cardDetail;
    BOOL taped;
    CGPoint pointStart;
    CGFloat upFixHeight;
    CGFloat downFixHeight;
}

@property (nonatomic, assign) NSObject<dragCardDelegate> *delegate;
@property(nonatomic,retain) NSMutableArray *cardInfo;
@property(nonatomic,retain) NSString *cUserId;
@property(nonatomic,retain) cardDetailViewController *cardDetail;

- (id)initWithFrame:(CGRect)frame info:(NSMutableArray *)cInfo userID:(NSString *)userId;

//弹出名片
- (void)showCardView;

//隐藏名片
- (void)hideCardView;

//手势相关函数
- (void)overLayViewChanged:(CGPoint)point;
- (void)overLayViewTouchEnd:(CGPoint)point;
- (void)overLayViewTap;

@end
