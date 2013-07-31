// MKMapView+ZoomLevel.m
#import "MKMapView+ZoomLevel.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
#define METERS_PER_MILE 1609.344

@implementation MKMapView (ZoomLevel)

#pragma mark -
#pragma mark Map conversion methods

+ (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

+ (double)latitudeToPixelSpaceY:(double)latitude
{
	if (latitude == 90.0) {
		return 0;
	} else if (latitude == -90.0) {
		return MERCATOR_OFFSET * 2;
	} else {
		return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
	}
}

+ (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

+ (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [MKMapView longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [MKMapView latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [MKMapView pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [MKMapView pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [MKMapView pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [MKMapView pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

- (NSUInteger) zoomLevel {
    MKCoordinateRegion region = self.region;

    double centerPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude];
    double topLeftPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2];
    
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = self.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log(zoomScale) / log(2);
    double zoomLevel = 20 - zoomExponent;
    
    return zoomLevel;
}


- (void)zoomToUserLocation:(CLLocation *)location {
	CLLocationCoordinate2D zoomLocation;
	if (location) {
		zoomLocation.latitude = location.coordinate.latitude;
		zoomLocation.longitude= location.coordinate.longitude;
	} else {
		zoomLocation.latitude = self.userLocation.coordinate.latitude;
		zoomLocation.longitude= self.userLocation.coordinate.longitude;
	}
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10*METERS_PER_MILE, 10*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self regionThatFits:viewRegion];
    [self setRegion:adjustedRegion animated:YES];
}

+ (void)geocodeAddressString:(NSString *)address GeoCoderCompletionBlock:(GeoCoderCompletionBlock)block {
	CLGeocoder* geocoder = [[CLGeocoder alloc] init];
	[geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
		if ([placemarks count] > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			block(address, placemark.location);
		}
	}];
}

+ (void)reverseGeocodeLocation:(CLLocation *)location GeoCoderCompletionBlock:(GeoCoderCompletionBlock)block {
	CLGeocoder* geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			NSLog(@"%@", error);
			return;
		}
		
		if (placemarks && placemarks.count > 0) {
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			NSArray *addressLines = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
			NSString *address = [addressLines componentsJoinedByString:@", "];
			block(address, location);
		}
	}];
}

@end