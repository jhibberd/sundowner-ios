
#import <Foundation/Foundation.h>
#import "SDServer.h"
#import "SDServerDelegate.h"

@interface SDServerRequest : NSObject <NSURLConnectionDelegate>
- (id)initWithRequest:(NSURLRequest *)request
            onSuccess:(ServerCallback)successCallback
            onFailure:(ServerCallback)failureCallback
             delegate:(id<SDServerDelegate>)delegate;
- (void)request;
@end

