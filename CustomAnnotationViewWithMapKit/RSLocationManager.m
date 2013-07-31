//
//  RSLocationManager.m
//  CustomAnnotationViewWithMapKit
//
//  Created by David Liang on 7/31/13.
//  Copyright (c) 2013 David Liang. All rights reserved.
//

#import "RSLocationManager.h"

static RSLocationManager *manager;

@implementation RSLocationManager

+ (RSLocationManager *)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[RSLocationManager alloc] init];
	});
	return manager;
}

- (id)init {
	if (self = [super init]) {
		userLocationBlocks = [NSMutableArray new];
	}
	return self;
}

- (void)startLocationTracking {
	locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)stopLocationTracking {
	[locationManager stopUpdatingLocation];
}

- (void)locateMeWithBlock:(UserLocationBlock)block {
	[userLocationBlocks addObject:block];
}

#pragma mark - CLLocationManager Delegate
-(void)locationManager:(CLLocationManager *)_manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
	self.userLocation = newLocation;
	for (UserLocationBlock block in userLocationBlocks) {
		block(newLocation);
	}
	[userLocationBlocks removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [locationManager stopUpdatingLocation];
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
														message:[error description]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
        [alert show];
    }
}


@end
