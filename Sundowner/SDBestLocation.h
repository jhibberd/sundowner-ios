
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "SDBestLocationDelegate.h"

@interface SDBestLocation : NSObject <CLLocationManagerDelegate>
- (void)startUpdatingLocation:(id <SDBestLocationDelegate>)delegate;
- (CLLocation *)stopUpdatingLocationAndReturnBest;
@end
