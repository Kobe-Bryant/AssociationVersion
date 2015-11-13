//
//  MButton.h
//  shopping
//
//  Created by lai yun on 12-12-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol activityViewDelegate
@optional
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event ;
@end

@interface activityView : UIView
{
    NSObject<activityViewDelegate> *delegate;
}

@property (nonatomic, assign) NSObject<activityViewDelegate> *delegate;

@end
