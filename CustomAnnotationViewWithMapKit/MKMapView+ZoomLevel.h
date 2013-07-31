//
//  MKMapView+MKMapView_ZoomLevel_h.h
//  FieldForceManagement
//
//  Created by WEIYE LIANG on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Constants.h"

typedef  void (^GeoCoderCompletionBlock)(NSString *address, CLLocation *location);

@interface MKMapView (MKMapView_ZoomLevel_h)

- (void)zoomToUserLocation:(CLLocation *)location;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel
				   animated:(BOOL)animated;

+ (void)geocodeAddressString:(NSString *)address GeoCoderCompletionBlock:(GeoCoderCompletionBlock)block;
+ (void)reverseGeocodeLocation:(CLLocation *)location GeoCoderCompletionBlock:(GeoCoderCompletionBlock)block;

@end
