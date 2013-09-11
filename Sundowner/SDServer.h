
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef void(^ServerCallback)(NSDictionary *response);

@interface SDServer : NSObject
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;
- (void)getObjectsForLocation:(CLLocationCoordinate2D)coordinate callback:(ServerCallback)callback;
- (void)setContent:(NSString *)content
           withURL:(NSString *)url
        atLocation:(CLLocation *)location
            byUser:(NSString *)username
          callback:(ServerCallback)callback;
@end
