
#import <Foundation/Foundation.h>
#import "SDServer.h"

@interface SDServerRequest : NSObject <NSURLConnectionDelegate>
- (id)initWithRequest:(NSURLRequest *)request
            onSuccess:(ServerCallback)successCallback
            onFailure:(ServerCallback)failureCallback;
- (void)request;
@end

