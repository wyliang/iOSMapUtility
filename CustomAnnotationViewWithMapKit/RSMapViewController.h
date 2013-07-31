//
//  RSMapViewController.h
//  CustomAnnotationViewWithMapKit
//
//  Created by David Liang on 7/30/13.
//  Copyright (c) 2013 David Liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "RSLocationManager.h"

@interface RSMapViewController: UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
- (IBAction)findMyLocation:(id)sender;

@end
