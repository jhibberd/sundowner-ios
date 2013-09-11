
#import <CoreLocation/CoreLocation.h>
#import "SDBestLocation.h"
#import "SDBestLocationDelegate.h"

@implementation SDBestLocation {
    CLLocationManager *_locationManager;
    CLLocation *_bestLocation;
    NSDate *_startTime;
    id <SDBestLocationDelegate> _delegate;
}

- (id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)startUpdatingLocation:(id <SDBestLocationDelegate>)delegate
{
    _startTime = [NSDate date];
    _bestLocation = nil;
    _delegate = delegate;
    [_locationManager startUpdatingLocation];
}

- (CLLocation *)stopUpdatingLocationAndReturnBest
{
    [_locationManager stopUpdatingLocation];
    _delegate = nil;
    _startTime = nil;
    if (_bestLocation == nil) {
        // during the allotted time a location couldn't be established
        [_delegate failedToGetBestLocation];
    }
    
    return _bestLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        
        // ignore locations created before we started updating locations
        if ([location.timestamp earlierDate:_startTime] == location.timestamp) {
            continue;
        }
        
        // ignore locations with an invalid accuracy
        if (location.horizontalAccuracy < 0) {
            continue;
        }
        
        // keep the location with the best accuracy
        if (_bestLocation == nil || location.horizontalAccuracy < _bestLocation.horizontalAccuracy) {
            _bestLocation = location;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_delegate failedToGetBestLocation];
}

@end
