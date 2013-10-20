
#import "SDAppDelegate.h"
#import "SDFacebookSessionManager.h"
#import "SDServer.h"
#import "SDSessionClosedViewController.h"
#import "SDSessionOpeningViewController.h"
#import "SDLocation.h"
#import "UIColor+SDColor.h"
#import "UIImage+GTImage.h"

@implementation SDAppDelegate {
    SDFacebookSessionManager *_fbSessionManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.location = [[SDLocation alloc] init];
    self.server = [[SDServer alloc] init];
    _fbSessionManager = [[SDFacebookSessionManager alloc] initWithDelegate:self];
    
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // handle the callback from the Facebook app that performs the authentication
    return [SDFacebookSessionManager handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.location start];
    [SDFacebookSessionManager handleApplicationDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.location stop];
}

# pragma mark SDFacebookSessionManagerDelegate

- (void)onFacebookSessionOpen
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"SessionOpenViewController"];
    self.window.rootViewController = nc;
}

- (void)onFacebookSessionOpening
{
    self.window.rootViewController = [[SDSessionOpeningViewController alloc] init];
}

- (void)onFacebookSessionClosed
{
    self.window.rootViewController = [[SDSessionClosedViewController alloc] initWithFBLoginView:_fbSessionManager.loginView];
}

@end
