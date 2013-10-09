
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef void(^ServerCallback)(NSDictionary *response);

typedef enum {
    SDVoteDown = 0,
    SDVoteUp,
} SDVote;

@interface SDServer : NSObject
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;
- (void)getContentNearby:(CLLocationCoordinate2D)coordinate
               onSuccess:(ServerCallback)successCallback;
- (void)setContent:(NSString *)content
               url:(NSString *)url
          location:(CLLocation *)location
              user:(NSString *)userId
         onSuccess:(ServerCallback)successCallback
         onFailure:(ServerCallback)failureCallback;
- (void)vote:(SDVote)vote
     content:(NSString *)contentId
        user:(NSString *)userId;
@end
