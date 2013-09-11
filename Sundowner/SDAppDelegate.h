
#import <UIKit/UIKit.h>
#import "SDBestLocation.h"
#import "SDLocation.h"
#import "SDServer.h"

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, retain) SDBestLocation *location2;
@property (strong, retain) SDLocation *location;
@property (strong, retain) SDServer *server;
@end
