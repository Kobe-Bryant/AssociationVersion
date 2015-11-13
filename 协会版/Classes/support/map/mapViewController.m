//
//  mapViewController.m
//  AppStrom
//
//  Created by 掌商 on 11-9-1.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "mapViewController.h"
#import "callSystemApp.h"
#import "Common.h"
#import "alertView.h"
@implementation mapViewController
//@synthesize locManager;
@synthesize current;
@synthesize addressDelegate;
@synthesize mymapType;
@synthesize strAddress;
@synthesize pointAnnotationForRemove;
@synthesize mapView;
@synthesize searchFiled;
@synthesize curAddress;
@synthesize daddrLocation;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"地理位置";
	if (mymapType == EDITE_MAP_TYPE) {
	
		UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
		lpress.allowableMovement = 10.0;
		[mapView addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
		[lpress release];
		
	}
	if (mymapType == SHOW_MAP_TYPE) {
		UIBarButtonItem *mrightbto = [[UIBarButtonItem alloc]
									  initWithTitle:@"地图导航"
									  style:UIBarButtonItemStyleBordered
									  target:self
									  action:@selector(handleSystemMap:)];
		self.navigationItem.rightBarButtonItem = mrightbto;
		[mrightbto release];
	}

}
-(void)handleSystemMap:(id)sender{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:
												 [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
												  myLocation.latitude,myLocation.longitude ,daddrLocation.latitude,daddrLocation.longitude]]];
}
-(NSString*)coordToString:(CLLocationCoordinate2D)coord{
	NSString *key = @"ABQIAAAAi0wvL4p1DYOdJ0iL-v2_sxR-h6gSv-DalIHlg2rPU6QFhO9KcRRTQ8IhBeqcKLxlL3lMxiK9r4f7Ug";
	NSString *urlStr = [NSString stringWithFormat:@"http://ditu.google.cn/maps/geo?output=csv&key=%@&q=%lf,%lf&hl=zh-CN",key,coord.latitude,coord.longitude];
	NSURL *url = [NSURL URLWithString:urlStr];
    NSString *retstr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray *resultArray = [retstr componentsSeparatedByString:@","];
	NSString *address = [resultArray objectAtIndex:2];
	address = [[[NSMutableString stringWithFormat:@"%@",address]stringByReplacingOccurrencesOfString:@"\"" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	NSRange range1 = [address rangeOfString:@" "];
	if (range1.location != NSNotFound) {
	
		address = [address substringToIndex:range1.location];
	}		
	NSLog(@"address，coord change to String %@",address);
	return address;
}
-(CLLocationCoordinate2D)stringToCoord:(NSString*)address1{
	NSString *address =[address1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 查詢經緯度
    NSString *output = @"csv";
    NSString *key = @"ABQIAAAAi0wvL4p1DYOdJ0iL-v2_sxR-h6gSv-DalIHlg2rPU6QFhO9KcRRTQ8IhBeqcKLxlL3lMxiK9r4f7Ug";
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=%@&key=%@",address,output,key];
	NSURL *url = [NSURL URLWithString:urlStr];
    NSString *retstr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray *resultArray = [retstr componentsSeparatedByString:@","];
	
	double latitude = [[resultArray objectAtIndex:2] doubleValue];
    double longitude = [[resultArray objectAtIndex:3] doubleValue];
	NSLog(@"lati %f long %f",latitude,longitude);
	CLLocationCoordinate2D coord;
	coord.latitude = latitude;
	coord.longitude = longitude;
	return coord;
	
}
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer{
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
		return;
	}
	
	//坐标转换
	CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
	CLLocationCoordinate2D touchMapCoordinate =
	[mapView convertPoint:touchPoint toCoordinateFromView:mapView];
#ifdef IOS4
	MapAnnotation*pointAnnotation1=nil;
	pointAnnotation1 = [[MapAnnotation alloc] init];
	pointAnnotation1.coordinate = touchMapCoordinate;
#endif
	NSString *address = [self coordToString:touchMapCoordinate];
	curAddress = address;
	NSString *coordinateString = [NSString stringWithFormat:@"%f,%f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
	if (addressDelegate != nil) {
		[addressDelegate getMarkAddress:address];
		[addressDelegate getMarkCoordinate:coordinateString];
	}
#ifdef IOS4
	pointAnnotation1.title =address;
	if (pointAnnotationForRemove != nil) {
		[mapView removeAnnotation:pointAnnotationForRemove];
	}
	[mapView addAnnotation:pointAnnotation1];
	self.pointAnnotationForRemove = pointAnnotation1;
	[pointAnnotation1 release];
#endif
}
-(void)loadAddressBackgroud2:(NSString*)address{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CLLocationCoordinate2D coord = [self stringToCoord:address];
	mapView.region = MKCoordinateRegionMakeWithDistance(coord, 500, 500);
	mapView.zoomEnabled = YES;
	[pool release];
}
-(IBAction)HandleSearch:(id)sender{
	NSString *searchContent = searchFiled.text;
	[searchFiled resignFirstResponder];
	if (searchContent.length > 0) {
		[self performSelectorInBackground:@selector(loadAddressBackgroud2:) withObject:searchContent];

	}
	
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	NSString *address = textField.text;
	[textField resignFirstResponder];
	if (address.length > 0) {
		[self performSelectorInBackground:@selector(loadAddressBackgroud2:) withObject:address];
	}
	return YES;
	
}
-(void)locateAddrBackground:(NSString*)addre{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CLLocationCoordinate2D coord = [self stringToCoord:addre];
	if((coord.latitude < -0.000001 && coord.latitude > 0.000001) && (coord.longitude < -0.000001 && coord.longitude > 0.000001)){
		//如果地图服务没打开或者查google的经纬度为0，0，默认用深圳经纬度
		coord.latitude = 113.8556;
		coord.longitude = 22.6211;
	}
	self.daddrLocation = coord;
	mapView.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.02f, 0.02f));
	mapView.zoomEnabled = YES;
#ifdef IOS4
	MapAnnotation*pointAnnotation1=nil;
	pointAnnotation1 = [[MapAnnotation alloc] init];
	pointAnnotation1.coordinate = coord;
#endif
	NSString *address = [self coordToString:coord];
	address = [[[NSMutableString stringWithFormat:@"%@",address]stringByReplacingOccurrencesOfString:@"\"" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	self.current = address;
	if (addressDelegate != nil) {
		[addressDelegate getMarkAddress:address];
	}
#ifdef IOS4
	pointAnnotation1.title =address;
	if (pointAnnotationForRemove != nil) {
		[mapView removeAnnotation:pointAnnotationForRemove];
	}
	[mapView addAnnotation:pointAnnotation1];
	self.pointAnnotationForRemove = pointAnnotation1;
	[pointAnnotation1 release];
#endif	
	[pool release];
}
-(void)LocateAddress:(NSString*)addre{
	self.strAddress = addre;
	self.curAddress = addre;
	if (addre.length < 1) {
		[self findme];
	}
	else {
		[self performSelectorInBackground:@selector(locateAddrBackground:) withObject:addre];
	}

}
- (void)LocateAddrByCoord : (NSString*)coordString{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CLLocationCoordinate2D coord;
	NSArray *resultArray = [coordString componentsSeparatedByString:@","];
	
	float latitude = [[resultArray objectAtIndex:0] floatValue];
    float longitude = [[resultArray objectAtIndex:1] floatValue];
	if ( latitude >  longitude) {
		float temp;
		temp = longitude;
		longitude = latitude;
		latitude  = temp;
	}
	coord.latitude = latitude;
	coord.longitude = longitude ;
	self.daddrLocation = coord;
	mapView.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.02f, 0.02f));
	mapView.zoomEnabled = YES;
#ifdef IOS4
	MapAnnotation*pointAnnotation1=nil;
	pointAnnotation1 = [[MapAnnotation alloc] init];
	pointAnnotation1.coordinate = coord;
#endif
	NSString *address = [self coordToString:coord];
	address = [[[NSMutableString stringWithFormat:@"%@",address]stringByReplacingOccurrencesOfString:@"\"" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	self.curAddress = address;
	NSLog(@"address %@",address);
	if (addressDelegate != nil) {
		[addressDelegate getMarkAddress:address];
	}
#ifdef IOS4
	pointAnnotation1.title =address;
	if (pointAnnotationForRemove != nil) {
		[mapView removeAnnotation:pointAnnotationForRemove];
	}
	[mapView addAnnotation:pointAnnotation1];
	self.pointAnnotationForRemove = pointAnnotation1;
	[pointAnnotation1 release];
#endif	
	[pool release];
}

- (void) findme
{
//	CLLocationManager *locM = [[CLLocationManager alloc]init];
//	self.locManager = locM;
//	[locM release];
	if(locManager == nil){
		locManager = [[CLLocationManager alloc] init];
	}
	if (!locManager.locationServicesEnabled)
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else 
	{
		locManager.desiredAccuracy = kCLLocationAccuracyBest;
		locManager.delegate = self;
		[locManager startUpdatingLocation];
	}
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//self.locManager.delegate = nil;
	//[self.locManager stopUpdatingLocation];
	self.current = newLocation;
	if(mymapType == SHOW_MAP_TYPE && strAddress.length > 0){
		[callSystemApp locationManagerUpdateToLocation:strAddress fromLocation:current];
	}
	mapView.region = MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(0.02f, 0.02f));
	NSString *address = [self coordToString:newLocation.coordinate];
	address = [[[NSMutableString stringWithFormat:@"%@",address]stringByReplacingOccurrencesOfString:@"\"" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	self.curAddress = address;
	NSString *coordinateString = [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
	if (addressDelegate != nil) {
		[addressDelegate getMarkAddress:address];
		[addressDelegate getMarkCoordinate:coordinateString];
	}
	
	mapView.zoomEnabled = YES;
	MapAnnotation *annotation;
	annotation = [[MapAnnotation alloc] init];
	annotation.coordinate = newLocation.coordinate;
	//annotation = [[MKPointAnnotation alloc] initWithCoordinate:newLocation.coordinate];
	annotation.title = address;
	if (pointAnnotationForRemove != nil) {
		[mapView removeAnnotation:pointAnnotationForRemove];
	}
	[mapView addAnnotation:annotation];
	self.pointAnnotationForRemove = annotation;
	[annotation release];
	[manager stopUpdatingLocation]; 
	manager.delegate = nil;
	
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{		
	
		[manager stopUpdatingLocation]; 
		manager.delegate = nil; 
		[manager release]; 
	manager = nil;
}
-(void)showDetails:(id)sender{
	NSLog(@"show add detail");
	[alertView showAlert:self.curAddress];
	
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
 	static NSString* BridgeAnnotationIdentifier = @"bridgeAnnotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[mapView dequeueReusableAnnotationViewWithIdentifier:BridgeAnnotationIdentifier];
	if (!pinView)
	{
		// if an existing pin view was not available, create one
		MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:BridgeAnnotationIdentifier] autorelease];
		customPinView.pinColor = MKPinAnnotationColorPurple;
		customPinView.animatesDrop = YES;
		customPinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		customPinView.rightCalloutAccessoryView = rightButton;
		return customPinView;
	}
	else
	{
		pinView.annotation = annotation;
	}
	return pinView;
}	

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //self.locManager = nil;
	self.mapView = nil;
	self.searchFiled = nil;
	self.curAddress = nil;
}


- (void)dealloc {
	//NSLog(@"locManager %d",[locManager retainCount]);
	/*self.locManager.delegate = nil;
	[self.locManager stopUpdatingLocation];*/
	[locManager stopUpdatingLocation];
    locManager.delegate = nil;
   // [locManager release], 
	//locManager = nil;
	
	self.current = nil;
	self.strAddress=nil;
	//self.locManager = nil;
	self.pointAnnotationForRemove = nil;
	self.mapView = nil;
	self.searchFiled = nil;
    [super dealloc];
}

@end
