//
//  MButton.m
//  shopping
//
//  Created by lai yun on 12-12-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "activityView.h"

@implementation activityView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event])
    {
        if ([delegate respondsToSelector:@selector(hitTest:withEvent:)])
        {
            return [delegate hitTest:point withEvent:event];
        }
        return nil;
    }
    
    return nil;
}

@end
