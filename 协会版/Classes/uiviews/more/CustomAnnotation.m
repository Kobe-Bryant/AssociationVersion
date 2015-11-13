//
//  CustomAnnotation.m
//  xieHui
//
//  Created by Dream on 15/1/6.
//
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate, title, subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)aTitle andSubtitle:(NSString *)subTitle {
    self.coordinate = coord;
    self.title = aTitle;
    self.subtitle = subTitle;
    
    return self;
}

+ (CustomAnnotation *)coordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)Title andSubtitle:(NSString *)subTitle {
   CustomAnnotation *myAnnotation = [[[CustomAnnotation alloc]initWithCoordinate:coord
                                                                andTitle:Title
                                                                andSubtitle:subTitle] autorelease];
    return myAnnotation;
    
}

- (void) dealloc {
    [title release],title = nil;
    [subtitle release],subtitle = nil;
    [super dealloc];
}
@end
