
#import <CoreLocation/CoreLocation.h>
#import "SDLocation.h"

@implementation SDLocation {
    GTLocationAction _action;
    CLLocationManager *_locationManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)getCurrentLocationThen:(GTLocationAction)action
{
    _action = action;
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation]; // to preserve battery
    CLLocation* currentLocation = [locations lastObject];
    _action(currentLocation);
}

@end
