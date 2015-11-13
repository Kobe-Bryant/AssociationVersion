//
//  CustomAnnotation.h
//  xieHui
//
//  Created by Dream on 15/1/6.
//
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"


@interface CustomAnnotation : NSObject<BMKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)title andSubtitle:(NSString *)subTitle;

+ (CustomAnnotation *)coordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)title andSubtitle:(NSString *)subTitle;

@end
