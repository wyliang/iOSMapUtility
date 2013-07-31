//
//  RSLocationManager.h
//  CustomAnnotationViewWithMapKit
//
//  Created by David Liang on 7/31/13.
//  Copyright (c) 2013 David Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^UserLocationBlock)(CLLocation *location);

@interface RSLocationManager : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *manager;
	NSMutableArray *userLocationBlocks;
}
+ (RSLocationManager *)sharedInstance;

- (void)startLocationTracking;
- (void)stopLocationTracking;

- (void)locateMeWithBlock:(UserLocationBlock)block;

@property (nonatomic, strong) CLLocation *userLocation;

@end
