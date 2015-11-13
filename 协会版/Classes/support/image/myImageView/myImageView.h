//
//  myImageView.h
//  云来
//
//  Created by 掌商 on 11-7-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"

@protocol myImageViewDelegate;
@interface myImageView : UIImageView {
	id<myImageViewDelegate>		mydelegate;
	int imageId;
	UIActivityIndicatorView *loadingView;
}
@property(nonatomic,assign)id<myImageViewDelegate> mydelegate;
@property(nonatomic,assign)UIActivityIndicatorView *loadingView;
@property int imageId;
-(id)initWithFrame:(CGRect)frame withImageId:(int)imageid;
-(id)initWithImage:(UIImage *)image withImageId:(int)imageid;
-(void)startSpinner;
-(void)stopSpinner;
@end
@protocol myImageViewDelegate

@optional

- (void)imageViewTouchesEnd:(int)picId;
- (void)imageViewDoubleTouchesEnd:(int)picId;

@end