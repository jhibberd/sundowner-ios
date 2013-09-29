
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

extern NSString *const kSDLocationDidChangeNotification;

@interface SDLocation : NSObject <CLLocationManagerDelegate>
- (void)start;
- (CLLocation *)getCurrentLocation;
- (void)flushLocationIfAvailable;
- (void)stop;
@end
