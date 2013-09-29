
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

extern NSString *const kSDLocationDidChangeNotification;
extern NSString *const kSDLocationAvailableNotification;
extern NSString *const kSDLocationUnavailableNotification;

@interface SDLocation : NSObject <CLLocationManagerDelegate>
- (void)start;
- (CLLocation *)getCurrentLocation;
- (void)flushLocationIfAvailable;
- (void)stop;
@end
