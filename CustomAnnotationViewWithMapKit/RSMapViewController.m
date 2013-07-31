//
//  RSMapViewController.m
//  CustomAnnotationViewWithMapKit
//
//  Created by David Liang on 7/30/13.
//  Copyright (c) 2013 David Liang. All rights reserved.
//

#import "RSMapViewController.h"

@interface RSMapViewController ()
{
	RSLocationManager *manager;
}
@end

@implementation RSMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[MKMapView geocodeAddressString:@"3 Corporate Park, Irvine, CA" GeoCoderCompletionBlock:^(NSString *address, CLLocation *location) {
		NSLog(@"%f %f", location.coordinate.latitude, location.coordinate.longitude);
	}];
	manager = [RSLocationManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.mapView setShowsUserLocation:YES];
	
	[manager startLocationTracking];
	[manager locateMeWithBlock:^(CLLocation *location) {
		[self.mapView zoomToUserLocation:location];
	}];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[manager stopLocationTracking];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapView Delegate
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isEqual:[MKUserLocation class]]) {
		return nil;
	}
	return nil;
}
 */

- (IBAction)findMyLocation:(id)sender {
	[self.mapView zoomToUserLocation:manager.userLocation];
}
@end
