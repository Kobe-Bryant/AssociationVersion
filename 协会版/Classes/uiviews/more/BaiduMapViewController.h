//
//  BaiduMapViewController.h
//  xieHui
//
//  Created by 来 云 on 12-11-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
//#import "BMKSearch.h"
#import "PopoverView.h"

@interface BaiduMapViewController : UIViewController<UIActionSheetDelegate,PopoverViewDelegate,UITableViewDataSource,UITableViewDelegate,BMKMapViewDelegate,BMKRouteSearchDelegate>
{
    BMKMapView *_mapView;
//    BMKSearch *_search;
    
    double _latitude;
    double _longitude;
    
    BOOL _isChange;
}

@property (retain, nonatomic) BMKMapView *mapView;
//@property (retain, nonatomic) BMKSearch *search;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, assign) BOOL isChange;

// 上个页面传进来
@property (nonatomic, retain) NSString *addrStr;
@property (nonatomic, retain) NSString *viewtitle;
@property (nonatomic, retain) NSString *phone;

@end


