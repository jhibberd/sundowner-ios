
#import "SDServer.h"
#import "SDServerRequest.h"
#import "SDToast.h"

@implementation SDServerRequest {
    NSURLRequest *_request;
    ServerCallback _successCallback;
    ServerCallback _failureCallback;
    NSMutableData *_data;
    NSHTTPURLResponse *_response;
}

#pragma mark Public

- (id)initWithRequest:(NSURLRequest *)request
            onSuccess:(ServerCallback)successCallback
            onFailure:(ServerCallback)failureCallback
{
    self = [super init];
    if (self) {
        _request = request;
        _successCallback = successCallback;
        _failureCallback = failureCallback;
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
        [self requestFailedWithResponse:nil];
    }
}

#pragma mark Private

- (void)requestFailedWithResponse:(NSDictionary *)payload
{
    [SDServer setNetworkActivityIndicatorVisible:NO];
    [SDToast toast:@"SERVER_ERROR"];
    if (_failureCallback) {
        _failureCallback(payload);
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init];
    _response = (NSHTTPURLResponse *)response;
    if (!_response) {
        // not sure why the response wouldn't be of type NSHTTPURLResponse but it could
        // happen, and it should be treated as an error
        [self requestFailedWithResponse:nil];
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    [self requestFailedWithResponse:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [SDServer setNetworkActivityIndicatorVisible:NO];
    
    // the API should always respond with data
    if ([_data length] == 0) {
        [self requestFailedWithResponse:nil];
        return;
    }
    
    // the API should always return data in JSON format
    NSError *error = nil;
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:_data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    if (error) {
        [self requestFailedWithResponse:nil];
        return;
    }
    
    // check the response HTTP status code
    NSInteger statusCode = _response.statusCode;
    if (statusCode < 200 || statusCode >= 400) {
        [self requestFailedWithResponse:payload];
        return;
    }
    
    if (_successCallback) {
        _successCallback(payload);
    }
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
