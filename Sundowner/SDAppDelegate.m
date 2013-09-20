
#import "SDAppDelegate.h"
#import "SDBestLocation.h"
#import "SDLocation.h"
#import "SDServer.h"
#import "UIColor+SDColor.h"
#import "UIImage+GTImage.h"

@implementation SDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.location2 = [[SDBestLocation alloc] init];
    self.location = [[SDLocation alloc] init];
    self.server = [[SDServer alloc] init];
    
    // register settings defaults
    // these don't override values specific by the user and must be set every time the app is launched as
    // they are written to volatile memory.
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPrefs = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
    
    // customize appearance of navigation bar to make it more minimalist and utilitarian
    UIImage *shadowImage = [UIImage imageFromColor:[UIColor backgroundTextColor]];
    UIImage *navigationBackgroundImage = [UIImage imageFromColor:[UIColor backgroundColor]];
    NSDictionary *textAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor backgroundTextColor],
                              UITextAttributeTextColor,
                              [UIColor clearColor],
                              UITextAttributeTextShadowColor ,
                              nil,
                              UITextAttributeTextShadowOffset,
                              nil,
                              UITextAttributeFont,
                              nil];
    id appearance = [UINavigationBar appearance];
    [appearance setBackgroundImage:navigationBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [appearance setShadowImage:shadowImage];
    [appearance setTitleTextAttributes:textAttr];
    
    return YES;
}

@end
