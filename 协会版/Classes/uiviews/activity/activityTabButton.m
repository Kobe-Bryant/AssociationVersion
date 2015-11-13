//
//  MButton.m
//  shopping
//
//  Created by lai yun on 12-12-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "activityTabButton.h"

@implementation activityTabButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.frame.size.width/2 - 15.0f, 0.0f, 30.0f, 30.0f);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0.0f , 28.0f , self.frame.size.width, 12.0f);
}


//- (CGRect)backgroundRectForBounds:(CGRect)bounds
//{
//    return self.frame;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
