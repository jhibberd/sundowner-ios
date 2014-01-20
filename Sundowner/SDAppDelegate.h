
#import <UIKit/UIKit.h>
#import "SDFacebookSessionManagerDelegate.h"
#import "SDServer.h"
#import "SDServerDelegate.h"
#import "SDLocation.h"

@interface SDAppDelegate : UIResponder
    <UIApplicationDelegate, SDFacebookSessionManagerDelegate, SDServerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, retain) SDLocation *location;
@property (strong, retain) SDServer *server;
@property (strong, nonatomic) NSString *user;
@end
