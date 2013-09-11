
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef void(^GTLocationAction)(CLLocation *currentLocation);

@interface SDLocation : NSObject <CLLocationManagerDelegate>
- (void)getCurrentLocationThen:(GTLocationAction)action;
@end
