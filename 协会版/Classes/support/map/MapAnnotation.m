//
//  MapAnnotation.m
//  AppStrom
//
//  Created by 掌商 on 11-9-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"


@implementation MapAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id) initWithCoordinate: (CLLocationCoordinate2D) aCoordinate
{
	if (self = [super init]) coordinate = aCoordinate;
	return self;
}

-(void) dealloc
{
	self.title = nil;
	self.subtitle = nil;
	[super dealloc];
}

@end
