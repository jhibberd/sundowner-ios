
#import <UIKit/UIKit.h>
#import "SDServer.h"
#import "SDLocation.h"

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, retain) SDLocation *location;
@property (strong, retain) SDServer *server;
@end
