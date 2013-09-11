
#import <Foundation/Foundation.h>
#import "SDServer.h"

@interface SDServerRequest : NSObject <NSURLConnectionDelegate>
- (id)initWithRequest:(NSURLRequest *)request callback:(ServerCallback)callback;
- (void)request;
@end

