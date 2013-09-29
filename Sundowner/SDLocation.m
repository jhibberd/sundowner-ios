
#import <CoreLocation/CoreLocation.h>
#import "SDLocation.h"

NSString *const kSDLocationDidChangeNotification = @"kSDLocationDidChangeNotification";
NSString *const kSDLocationAvailableNotification = @"kSDLocationAvailableNotification";
NSString *const kSDLocationUnavailableNotification = @"kSDLocationUnavailableNotification";
static NSTimeInterval const kSDMinSecondsBetweenLocationUpdates = 20;

typedef enum {
    SDLocationServicesAvailabilityUnknown = 0,
    SDLocationServicesAvailable,
    SDLocationServicesUnavailable
} SDLocationServicesAvailabilityType;

@implementation SDLocation {
    CLLocationManager *_locationManager;
    NSDate *_startTime;
    NSDate *_lastLocationNotificationTime;
    NSTimer *_pendingLocationUpdateTimer;
    CLLocation *_currentLocation;
    SDLocationServicesAvailabilityType _locationServicesAvailability;
}

# pragma mark Public

- (id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationServicesAvailability = SDLocationServicesAvailabilityUnknown;
    }
    return self;
}

- (void)start
{
    _startTime = [NSDate date];
    _lastLocationNotificationTime = nil;
    _pendingLocationUpdateTimer = nil;
    _currentLocation = nil;
    [_locationManager startUpdatingLocation];
}

- (void)stop
{
    [_locationManager stopUpdatingLocation];
    [_pendingLocationUpdateTimer invalidate];
    _startTime = nil;
    _lastLocationNotificationTime = nil;
    _pendingLocationUpdateTimer = nil;
    _currentLocation = nil;
}

- (CLLocation *)getCurrentLocation
{
    return _currentLocation;
}

- (void)flushLocationIfAvailable
{
    if (_currentLocation) {
        [self postLocationUpdateNotification];
    }
}

# pragma mark Location Update Buffer

- (void)newValidLocationReceived:(CLLocation *)location
{
    if (_locationServicesAvailability != SDLocationServicesAvailable) {
         _locationServicesAvailability = SDLocationServicesAvailable;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSDLocationAvailableNotification
                                                            object:self
                                                          userInfo:nil];
    }
    
    NSLog(@"Location update");
    _currentLocation = location;
    
    // stop any pending location update timer that may be waiting to call this method
    [_pendingLocationUpdateTimer invalidate];
    
    // enough time has passed since the last location update so dispatch the notification
    if (_lastLocationNotificationTime == nil ||
        (-[_lastLocationNotificationTime timeIntervalSinceNow]) >= kSDMinSecondsBetweenLocationUpdates) {
        [self postLocationUpdateNotification];
        
    // not enough time has passed since the last location update so create a timer to wait
    } else {
        NSTimeInterval wait = kSDMinSecondsBetweenLocationUpdates - (-[_lastLocationNotificationTime timeIntervalSinceNow]);
        _pendingLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:wait
                                                                       target:self
                                                                     selector:@selector(pendingLocationUpdateTimerTick:)
                                                                     userInfo:nil
                                                                      repeats:NO];
    }
}

- (void)pendingLocationUpdateTimerTick:(NSTimer *)timer
{
    [self postLocationUpdateNotification];
}

- (void)postLocationUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDLocationDidChangeNotification
                                                        object:self
                                                      userInfo:@{@"location": _currentLocation}];
    _lastLocationNotificationTime = [NSDate date];
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        
        // ignore cached locations by discarding locations whose timestamp precedes the time that
        // the CLLocationManager started listening
        if ([location.timestamp earlierDate:_startTime] == location.timestamp) {
            continue;
        }
        
        // ignore locations with an invalid accuracy
        if (location.horizontalAccuracy < 0) {
            continue;
        }
        
        [self newValidLocationReceived:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    switch (error.code) {
            
        case kCLErrorLocationUnknown:
            // according to Apple documentation the service will continue to attempt to retrieve
            // the user's location
            NSLog(@"kCLErrorLocationUnknown");
            break;
            
        case kCLErrorDenied:
            // The user has denied the application use of the location service. The availability of
            // location services will be checked by each UIViewController during viewWillAppear and
            // appropriate action will be taken there is the services are unavailable.
            NSLog(@"kCLErrorDenied");
            [self stop];
            if (_locationServicesAvailability != SDLocationServicesUnavailable) {
                _locationServicesAvailability = SDLocationServicesUnavailable;
                [[NSNotificationCenter defaultCenter] postNotificationName:kSDLocationUnavailableNotification
                                                                    object:self
                                                                  userInfo:nil];
            }
            break;
            
        default:
            break;
    }
}

@end
