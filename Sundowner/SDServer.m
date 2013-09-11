
#import <CoreLocation/CoreLocation.h>
#import "SDServer.h"
#import "SDServerRequest.h"

#define PORT 8050

@implementation SDServer {
    NSString *_venueId;
    NSString *_deviceId;
}

# pragma mark - Class

// manage whether the network activity indicator on the device is shown
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    static NSInteger callsToSetVisible = 0;
    if (setVisible)
        ++callsToSetVisible;
    else
        --callsToSetVisible;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(callsToSetVisible > 0)];
}

# pragma mark - Public

- (void)getObjectsForLocation:(CLLocationCoordinate2D)coordinate callback:(ServerCallback)callback
{
    // define url request
    NSString *url = [NSString stringWithFormat:@"http://%@:%d?longitude=%f&latitude=%f",
                     [self getHost], PORT, coordinate.longitude, coordinate.latitude];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    // issue request to server
    SDServerRequest *serverRequest = [[SDServerRequest alloc] initWithRequest:urlRequest callback:callback];
    [serverRequest request];
}

- (void)setContent:(NSString *)content
           withURL:(NSString *)url
        atLocation:(CLLocation *)location
            byUser:(NSString *)username
          callback:(ServerCallback)callback
{    
    // define request body
    CLLocationDegrees longitude =   location.coordinate.longitude;
    CLLocationDegrees latitude =    location.coordinate.latitude;
    CLLocationAccuracy accuracy =   location.horizontalAccuracy;
    NSMutableDictionary *data = [@{
                                 @"longitude":    [NSNumber numberWithDouble:longitude],
                                 @"latitude":     [NSNumber numberWithDouble:latitude],
                                 @"accuracy":     [NSNumber numberWithDouble:accuracy],
                                 @"username":     username,
                                 @"title":        content}
                                 mutableCopy];
    if (url != nil) {
        [data setObject:url forKey:@"url"];
    }
    NSError *serializationError = nil;
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&serializationError];
    if (!serializedData || serializationError) {
        NSLog(@"Failed to serialize data object.");
        return;
    }
    NSString *encodedData = [[NSString alloc] initWithData:serializedData encoding:NSUTF8StringEncoding];
    if (!encodedData) {
        NSLog(@"Failed to encode serialized data.");
        return;
    }
    
    // define url request
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d", [self getHost], PORT];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d", [encodedData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[encodedData dataUsingEncoding:NSUTF8StringEncoding]];
    
    // issue request to server
    SDServerRequest *serverRequest = [[SDServerRequest alloc] initWithRequest:request callback:callback];
    [serverRequest request];
}

# pragma mark - Private

- (NSString *)getHost
{
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    return [defaults stringForKey:@"host"];
}

@end
