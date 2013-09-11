
#import "SDServer.h"
#import "SDServerRequest.h"

@implementation SDServerRequest {
    NSURLRequest *_request;
    ServerCallback _callback;
    NSMutableData *_data;
}

#pragma mark Public

- (id)initWithRequest:(NSURLRequest *)request callback:(ServerCallback)callback
{
    self = [super init];
    if (self) {
        _request = request;
        _callback = callback;
    }
    return self;
}

- (void)request
{
    [SDServer setNetworkActivityIndicatorVisible:YES];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:_request
                                                                  delegate:self
                                                          startImmediately:YES];
    if (!connection) {
        [self error];
    }
}

#pragma mark Private

- (void)error
{
    [SDServer setNetworkActivityIndicatorVisible:NO];
    [[[UIAlertView alloc] initWithTitle:@"Sundowner"
                                message:@"Failed to connect to server"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if ([((NSHTTPURLResponse *)response) statusCode] != 200) {
        [self error];
        [connection cancel];
        return;
    }
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    [self error];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    // if the Waitress API returned data, assume it to be JSON and decode it
    NSDictionary *response = nil;
    if ([_data length]) {
        NSError *error = nil;
        response = [NSJSONSerialization JSONObjectWithData:_data
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
        if (error) {
            [self error];
            return;
        }
    }
    
    [SDServer setNetworkActivityIndicatorVisible:NO];
    if (_callback)
        _callback(response);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil; // don't cache anything
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    return request; // allow redirection
}

@end
