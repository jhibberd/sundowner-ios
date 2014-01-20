
#import <CoreLocation/CoreLocation.h>
#import "SDServer.h"
#import "SDServerRequest.h"

static NSString *kSDServerPropertyServerHost = @"ServerHost";

@implementation SDServer {
    NSString *_accessToken;
    id<SDServerDelegate> _delegate;
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

- (id)initWithAccessToken:(NSString *)accessToken delegate:(id<SDServerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _accessToken = accessToken; // Facebook access token
        _delegate = delegate;
    }
    return self;
}

- (void)getContentNearby:(CLLocationCoordinate2D)coordinate
               onSuccess:(ServerCallback)successCallback
{
    NSURLRequest *request = [self createRequestForEndpoint:@"/content?lng=%f&lat=%f&access_token=%@",
                             coordinate.longitude, coordinate.latitude, _accessToken];
    [[[SDServerRequest alloc] initWithRequest:request
                                    onSuccess:successCallback
                                    onFailure:nil
                                     delegate:_delegate] request];
}

- (void)setContent:(NSString *)content
               url:(NSString *)url
          location:(CLLocation *)location
         onSuccess:(ServerCallback)successCallback
        onFailure:(ServerCallback)failureCallback
{    
    CLLocationDegrees longitude =   location.coordinate.longitude;
    CLLocationDegrees latitude =    location.coordinate.latitude;
    CLLocationAccuracy accuracy =   location.horizontalAccuracy;
    NSMutableDictionary *data = [@{
                                 @"lng":            [NSNumber numberWithDouble:longitude],
                                 @"lat":            [NSNumber numberWithDouble:latitude],
                                 @"accuracy":       [NSNumber numberWithDouble:accuracy],
                                 @"access_token":   _accessToken,
                                 @"text":           content}
                                 mutableCopy];
    if (url != nil) {
        [data setObject:url forKey:@"url"];
    }
    NSString *payload = [self jsonEncode:data];
    if (!payload) {
        NSLog(@"failed to json encode payload");
        return;
    }
    
    NSMutableURLRequest *request = [self createRequestForEndpoint:@"/content"];
    [self preparePostRequest:request withPayload:payload];
    
    [[[SDServerRequest alloc] initWithRequest:request
                                    onSuccess:successCallback
                                    onFailure:failureCallback
                                     delegate:_delegate] request];
}

- (void)vote:(SDVote)vote
     content:(NSString *)contentId
{
    NSDictionary *data = @{@"content_id":       contentId,
                           @"access_token":     _accessToken,
                           @"vote":             @(vote)};
    NSString *payload = [self jsonEncode:data];
    if (!payload) {
        NSLog(@"failed to json encode payload");
        return;
    }
    
    NSMutableURLRequest *request = [self createRequestForEndpoint:@"/votes"];
    [self preparePostRequest:request withPayload:payload];
    
    [[[SDServerRequest alloc] initWithRequest:request
                                    onSuccess:nil
                                    onFailure:nil
                                     delegate:_delegate] request];
}

# pragma mark - Private

- (NSMutableURLRequest *)createRequestForEndpoint:(NSString *)format, ...
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *host = [mainBundle objectForInfoDictionaryKey:kSDServerPropertyServerHost];
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://%@", host];
    
    va_list args;
    va_start(args, format);
    NSString *endpoint = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [urlString appendString:endpoint];
    
    return [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
}

- (NSString *)jsonEncode:(NSDictionary *)object
{
    NSError *serializationError = nil;
    NSData *serializedObject = [NSJSONSerialization dataWithJSONObject:object options:0 error:&serializationError];
    if (!serializedObject || serializationError) {
        NSLog(@"failed to serialize data object");
        return nil;
    }
    NSString *encodedObject = [[NSString alloc] initWithData:serializedObject encoding:NSUTF8StringEncoding];
    if (!encodedObject) {
        NSLog(@"failed to encode serialized data");
        return nil;
    }
    return encodedObject;
}

- (void)preparePostRequest:(NSMutableURLRequest *)request withPayload:(NSString *)payload
{
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d", [payload length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
