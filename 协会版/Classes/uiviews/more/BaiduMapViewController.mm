//
//  BaiduMapViewController.m
//  xieHui
//
//  Created by 来 云 on 12-11-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaiduMapViewController.h"
#import "Common.h"
#import "callSystemApp.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ProfessionAppDelegate.h"
#import "CustomAnnotation.h"

typedef enum {
    MapNavEnumIOSSystem,
    MapNavEnumGoogleMaps,
    MapNavEnumIOSAmap,
    MapNavEnumBaiduMaps,
    MapNavEnumMax
} MapNavEnum;

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

#define NSNumericSearch 6.0

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface RouteAnnotation : NSObject <BMKAnnotation>
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘
    int _degree;
    NSString *_title;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (retain, nonatomic) NSString *title;

@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@synthesize coordinate = _coordinate;
@synthesize title = _title;

@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    CGSize rotatedSize = self.size;
    rotatedSize.width *= 2;
    rotatedSize.height *= 2;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface BaiduMapViewController ()<BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>
{
    CLLocationCoordinate2D _currCoordinate;
    CLLocationCoordinate2D _Coordinate;
    
    BOOL searchFlag;
    int mapNumber;
    
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoSearch;
    BMKRouteSearch       *_search;
    
    BMKPointAnnotation *point;
}

@property (retain, nonatomic) PopoverView *popView;
@property (retain, nonatomic) NSString *addstring;
@property (retain, nonatomic) NSString *city;
@property (retain, nonatomic) NSString *endcity;
@property (retain, nonatomic) NSString *addr;

@property (retain, nonatomic) BMKAnnotationView *annotationView;
// 线
@property (retain, nonatomic) BMKPolyline *bmkLine;
// 画线视图
@property (retain, nonatomic) BMKPolylineView *routeLineView;

// 弹窗
- (void)sheet;

@end

@implementation BaiduMapViewController
@synthesize mapView = _mapView;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize isChange = _isChange;
//@synthesize search = _search;

@synthesize addrStr;
@synthesize viewtitle;
@synthesize phone;
@synthesize city;
@synthesize endcity;
@synthesize addr;

@synthesize annotationView;
@synthesize bmkLine;
@synthesize routeLineView;

@synthesize popView;
@synthesize addstring;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;

    _geoSearch = [[BMKGeoCodeSearch alloc] init];

    [self.view addSubview:_mapView];
    
    NSLog(@"self.addrStr = %@",self.addrStr);
    
    BMKReverseGeoCodeOption* revgeoOption = [[BMKReverseGeoCodeOption alloc] init];
    revgeoOption.reverseGeoPoint = _Coordinate;
    
    BMKGeoCodeSearchOption *geoOption = [[BMKGeoCodeSearchOption alloc]init];
    geoOption.address = self.addrStr;
    
    _Coordinate = (CLLocationCoordinate2D){self.latitude,self.longitude};
    if ((self.longitude == 0 || self.latitude == 0) && self.addrStr.length != 0) {
//        [_search geocode:self.addrStr withCity:nil];
        
        [_geoSearch geoCode:geoOption];
    } else if (self.addrStr.length == 0 && (self.longitude != 0 || self.latitude != 0)) {
        searchFlag = NO;
//        [_search reverseGeocode:_Coordinate];
        [_geoSearch reverseGeoCode:revgeoOption];

    } else {
        [self addPointAnnotation:self.addrStr];
    }
    
    [revgeoOption release];
    [geoOption release];
    
    ProfessionAppDelegate *app = (ProfessionAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.addr = app.addressCity;
    self.city = app.city;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mapView.delegate = self;
    _geoSearch.delegate = self;
    [_locService startUserLocationService];
    NSLog(@"viewWillAppear......");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_locService stopUserLocationService];
    _mapView.delegate = nil;
    _geoSearch.delegate = nil;
    NSLog(@"viewWillDisappear....");
}

- (void)addPointAnnotation:(NSString *)str
{
    self.addstring = str;
    point = [[BMKPointAnnotation alloc]init];
    point.coordinate = _Coordinate;
    point.title = str;
    [_mapView addAnnotation:point];
    
}

// 将百度地图的坐标转为地球坐标
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta) + 0.0006;
    *gg_lat = z * sin(theta) - 0.0005;
}

// 坐标转换
- (void)coordiateconvert
{
    double x_mars, y_mars, x_wgs, y_wgs;
    
    // baidu
	x_mars = _Coordinate.longitude;
	y_mars = _Coordinate.latitude;
    
    bd_decrypt(x_mars, y_mars, &x_wgs, &y_wgs);
    printf("Transform success, (%f,%f)-->(%f,%f)\n",x_mars,y_mars,x_wgs,y_wgs);
    
    _Coordinate.latitude = y_wgs;
    _Coordinate.longitude = x_wgs;
}

// 百度地图跳转
- (void)baiduMapsToJump
{
    // 应用客户端
    NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%@&destination=%@&mode=driving&region=%@",[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.addstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"baiduMapsToJump stringURL = %@",stringURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

// 高德地图跳转
- (void)iosaMapToJump
{
    [self coordiateconvert];
    
    NSDictionary *infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString *appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    if (appName.length == 0) {
        appName = [infoDict objectForKey:@"CFBundleName"];
    }
    
    NSString *stringURL = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=xiehuiTempleate&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=2",[appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],_Coordinate.latitude,_Coordinate.longitude];
    NSLog(@"iosaMapToJump stringURL = %@",stringURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

// 谷歌地图跳转
- (void)googleMapsToJump
{
    [self coordiateconvert];
    NSString *data = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f(%@)&center=%f,%f&directionsmode=&zoom=17",_Coordinate.latitude,_Coordinate.longitude,[self.addrStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],_Coordinate.latitude,_Coordinate.longitude];
    NSLog(@"googleMapsToJump data = %@",data);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data]];
}

// ios自带的地图跳转
- (void)iosMapSystemToJump
{
    [self coordiateconvert];
    //调用自带地图（定位）
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    //显示目的地坐标。画路线
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[[MKPlacemark alloc] initWithCoordinate:_Coordinate addressDictionary:nil] autorelease]];
    toLocation.name = self.addstring;
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:
                                  [NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                             forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    
    [toLocation release];
}

- (void)searchPolyline
{
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    
    for (int i = 0; i < array.count; i++) {
        if (annotationView.annotation != [array objectAtIndex:i]) {
            [_mapView removeAnnotation:[array objectAtIndex:i]];
        }
    }
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    [routeLineView release], routeLineView = nil;
    
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = _currCoordinate;
    start.name = self.city;
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.pt = _Coordinate;
    end.name = self.endcity;
    
    BMKDrivingRoutePlanOption* drivingPlan = [[BMKDrivingRoutePlanOption alloc] init];
    drivingPlan.from = start;
    drivingPlan.to = end;
    
    BOOL flag1 = [_search drivingSearch:drivingPlan];
    if (!flag1) {
        NSLog(@"search failed");
    }
    
//    BOOL flag1 = [_search drivingSearch:start.name startNode:start endCity:end.name endNode:end];
//    if (!flag1) {
//        NSLog(@"search failed");
//    }
    
    
    [start release];
    [end release];
    [drivingPlan release];
}

- (void)sheet
{
    [popView dismiss];
    
    mapNumber = 0;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]
        || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]
        || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            [sheet addButtonWithTitle:@"使用苹果自带地图导航"];
            mapNumber += 1;
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            [sheet addButtonWithTitle:@"使用Google Maps导航"];
            mapNumber += 1;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            [sheet addButtonWithTitle:@"使用高德地图导航"];
            mapNumber += 1;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            [sheet addButtonWithTitle:@"使用百度地图导航"];
            mapNumber += 1;
        }
        [sheet addButtonWithTitle:@"取消"];
        mapNumber += 1;
        sheet.cancelButtonIndex = sheet.numberOfButtons-1;
        [sheet showInView:self.view];
    } else {
        if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            [self iosMapSystemToJump];
        } else {
            [self searchPolyline];
        }
    }
    
    NSLog(@"mapNumber = %d",mapNumber);
}
// 导航按钮
- (void)buttonclick:(id)sender
{
    NSLog(@"buttonclick.....");
    [self sheet];
}

#pragma mark - BMK Map View Delegate
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id)overlay
{
    if(overlay == bmkLine) {
        if(nil == routeLineView) {
            routeLineView = [[BMKPolylineView alloc] initWithPolyline:bmkLine];
            routeLineView.strokeColor = [UIColor colorWithRed:72.f/255.f green:153.f/255.f blue:216.f/255.f alpha:1.f];
            routeLineView.lineWidth = 5;
        }
        return routeLineView;
    }
    return nil;
}

#pragma mark - BMKSearchDelegate
//- (void)onGetAddrResult:(BMKAddrInfo *)result errorCode:(int)error
//{
//    if (searchFlag) {
//        searchFlag = NO;
//        self.city = result.addressComponent.city;
//        self.addr = result.strAddr;
//        NSLog(@"city.. = %@",self.city);
//        NSLog(@"addr.. = %@",self.addr);
//    } else {
//        _Coordinate = result.geoPt;
//        self.endcity = result.addressComponent.city;
//        [self addPointAnnotation:result.strAddr];
//    }
//}
//

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
//    if (searchFlag) {
//        searchFlag = NO;
//        self.city = result.addressComponent.city;
//        self.addr = result.strAddr;
//        NSLog(@"city.. = %@",self.city);
//        NSLog(@"addr.. = %@",self.addr);
//    } else {
//        _Coordinate = result.geoPt;
//        self.endcity = result.addressComponent.city;
//        [self addPointAnnotation:result.strAddr];
//    }
}

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error {

    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = plan.steps.count;
        int planPointCounts = 0;
        for (NSUInteger i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                [item release];
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
                [item release];
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            [item release];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
                [item release];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        bmkLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:bmkLine]; // 添加路线overlay
        delete []temppoints;
    }
}


//// 返回驾乘结果
//- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
//{
//	if (error == BMKErrorOk) {
//        
////        NSLog(@"result.plans = %d",result.plans.count);
//        
//		BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
//        
////        NSLog(@"plan.routes = %d",plan.routes.count);
//        
////        BMKRoute* routeplan = (BMKRoute*)[plan.routes objectAtIndex:0];
//        
////        NSLog(@"routeplan.steps = %d",routeplan.steps.count);
////        
////        NSLog(@"pointsCount = %d",routeplan.pointsCount);
//
//		int index = 0;
//		int size = [plan.routes count];
//		for (int i = 0; i < 1; i++) {
//			BMKRoute* route = [plan.routes objectAtIndex:i];
//			for (int j = 0; j < route.pointsCount; j++) {
//				int len = [route getPointsNum:j];
//				index += len;
//			}
//		}
////        NSLog(@"index = %d",index);
//        
//		BMKMapPoint* points = new BMKMapPoint[index];
//		index = 0;
//		
//		for (int i = 0; i < 1; i++) {
//			BMKRoute* route = [plan.routes objectAtIndex:i];
//			for (int j = 0; j < route.pointsCount; j++) {
//				int len = [route getPointsNum:j];
//				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
//				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
//				index += len;
//			}
//			size = route.steps.count;
//			for (int j = 0; j < size; j++) {
//				BMKStep* step = [route.steps objectAtIndex:j];
//				RouteAnnotation *item = [[RouteAnnotation alloc]init];
//				item.coordinate = step.pt;
//				item.title = step.content;
//				item.degree = step.degree * 30;
//				item.type = 4;
//				[_mapView addAnnotation:item];
//				[item release];
//			}
//			
//		}
//        
//        //CLLocationCoordinate2D *coord = (CLLocationCoordinate2D*)malloc(sizeof(routeplan.points[0]));
//        self.bmkLine = [BMKPolyline polylineWithPoints:points count:index];
//        [_mapView setVisibleMapRect:[bmkLine boundingMapRect]];
//		[_mapView addOverlay:bmkLine];
//		delete []points;
//        
//        [_mapView setShowsUserLocation:YES];
//	}
//}

// 选中后视图
- (void)annotationViewBMK:(BMKAnnotationView *)view
{
    [_mapView deselectAnnotation:point animated:NO];
    //将地图的经纬度坐标转换成所在视图的坐标
    CGPoint viewpoint = [_mapView convertCoordinate:view.annotation.coordinate toPointToView:self.view];
    
    CGPoint poppoint = CGPointMake(0.f, 0.f);
    
    if ([UIScreen mainScreen].applicationFrame.size.height > 500) {
        poppoint = CGPointMake(viewpoint.x, viewpoint.y);
    } else {
        poppoint = CGPointMake(viewpoint.x, viewpoint.y-40);
    }
    
    CGFloat totalHeight = 0.f;
    CGFloat totalwidth = 280.f;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, totalwidth, totalHeight)];
    UILabel *shopname = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0.f, totalwidth-20.f, 30.f)];
    shopname.font = [UIFont systemFontOfSize:14];
    shopname.backgroundColor = [UIColor clearColor];
    shopname.text = @"活动地址";
    [containerView addSubview:shopname];
    [shopname release];
    
    totalHeight += 30.f;
    
    // 地址及电话
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, totalHeight, totalwidth, 100) style:UITableViewStyleGrouped];
    tableview.backgroundColor = [UIColor clearColor];
    tableview.scrollEnabled = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundView = nil;
    [containerView addSubview:tableview];
    [tableview release];
    
    if (IOS_VERSION >= 7.0) {
        tableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableview.bounds.size.width, 10.f)];
    }
    
    totalHeight += 100.f + 10.f;
    
    // 导航
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"圆角矩形中.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(10.f, totalHeight, totalwidth-20.f, 40.f)];
    [button setTitle:@"开始导航" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    [containerView addSubview:button];
    
    totalHeight += 40.f;
    
    containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, totalHeight+10.f);
    
    self.popView = [PopoverView showPopoverAtPoint:poppoint inView:self.view withTitle:nil withContentView:[containerView autorelease] delegate:self];
}

#pragma mark - BMKMapViewDelegate
//change by devin
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
    [_locService stopUserLocationService];
    [_mapView updateLocationData:userLocation];

    //这里用一个变量判断一下,只在第一次锁定显示区域时 设置一下显示范围 Map Region
    if (!_isChange)
    {
        _currCoordinate = userLocation.location.coordinate;
        
        CustomAnnotation *myAnnotation = [CustomAnnotation coordinate:_currCoordinate andTitle:@"自己的位置" andSubtitle:nil];
        [_mapView addAnnotation:myAnnotation];
        
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.latitude+(userLocation.location.coordinate.latitude-self.latitude)/2, self.longitude+(userLocation.location.coordinate.longitude-self.longitude)/2};
        
//        NSLog(@"self.latitude========== %f",self.latitude);
//        
//        NSLog(@"self.longitude========== %f",self.longitude);
//
//        NSLog(@"userLocation.latitude========== %f",userLocation.location.coordinate.latitude);
//        NSLog(@"userLocation.longitude========== %f",userLocation.location.coordinate.longitude);
        //地图定位到我的位置
        BMKCoordinateRegion region = BMKCoordinateRegionMake(pt, BMKCoordinateSpanMake((userLocation.location.coordinate.latitude-self.latitude)*2, (userLocation.location.coordinate.longitude-self.longitude)*2));
        
        _isChange = YES;
        //执行设定显示范围
        [_mapView setRegion:region animated:NO];
        searchFlag = YES;
        //[_search reverseGeocode:userLocation.location.coordinate];
    }
}

//- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
//{
//    //这里用一个变量判断一下,只在第一次锁定显示区域时 设置一下显示范围 Map Region
//    if (!_isChange)
//    {
//        _currCoordinate = userLocation.location.coordinate;
//        
//        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.latitude+(userLocation.location.coordinate.latitude-self.latitude)/2, self.longitude+(userLocation.location.coordinate.longitude-self.longitude)/2};
//        //地图定位到我的位置
//        BMKCoordinateRegion region = BMKCoordinateRegionMake(pt, BMKCoordinateSpanMake((userLocation.location.coordinate.latitude-self.latitude)*2, (userLocation.location.coordinate.longitude-self.longitude)*2));
//        
//        _isChange = YES;
//        //执行设定显示范围
//        [_mapView setRegion:region animated:NO];
//        
//        searchFlag = YES;
////        [_search reverseGeocode:userLocation.location.coordinate];        
//    }
//}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *identifier = @"AnnotationPin";
        BMKAnnotationView *annoView = [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annoView) {
            annoView = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annoView.canShowCallout = NO;
        }
        
//        [self performSelector:@selector(annotationViewBMK:) withObject:annotationView afterDelay:0.5];

        return annotationView;
    } else if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        BMKAnnotationView *KYview = [[[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"KYViewID"] autorelease];
        RouteAnnotation *item = annotation;
        
        KYview.image = [[UIImage imageNamed:@"icon_direction.png"] imageRotatedByDegrees:item.degree];
        KYview.canShowCallout = YES;
        
        return KYview;
    } else if([annotation isKindOfClass:[CustomAnnotation class]] ){
        NSLog(@"zzzzzz");
       BMKAnnotationView *cusView = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Custom"] autorelease];
        cusView.canShowCallout = YES;
        cusView.image = [UIImage imageNamed:@"myself_point.png"];
        return annotationView;
    } else {
        return nil;
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[BMKPointAnnotation class]]) {
        [self annotationViewBMK:view];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((mapNumber-1) == buttonIndex) {
        return;
    }
    switch (buttonIndex) {
        case MapNavEnumIOSSystem: {
            if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                [self iosMapSystemToJump];
                break;
            } 
        }
        case MapNavEnumGoogleMaps: {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
                [self googleMapsToJump];
                return;
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
                [self iosaMapToJump];
                return;
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
                [self baiduMapsToJump];
            }
        }
            break;
        case MapNavEnumIOSAmap: {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
                [self iosaMapToJump];
                return;
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
                [self baiduMapsToJump];
            }
        }
            break;
        case MapNavEnumBaiduMaps: {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
                [self baiduMapsToJump];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - PopoverViewDelegate Methods

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {

    [popoverView showImage:[UIImage imageNamed:@"success"] withMessage:@"ok"];

    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView {
    [annotationView setSelected:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"strcell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:str];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.font = [UIFont systemFontOfSize:12.f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //ios7新特性,解决分割线短一点
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"店铺位置"ofType:@"png"]];
        cell.textLabel.text = self.addstring;
    } else {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"商铺电话"ofType:@"png"]];
        cell.textLabel.text = self.phone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [callSystemApp makeCall:cell.textLabel.text];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [point release];
    [_geoSearch release];
    [_locService release];
    [_mapView release];
    [addstring release];
    [popView release];
    [phone release];
    [viewtitle release];
    [addrStr release];
    [city release];
    [addr release];
    [endcity release];
    [routeLineView release];
    [bmkLine release];
	[super dealloc];
}

@end
