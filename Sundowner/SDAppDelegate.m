
#import "SDAppDelegate.h"
#import "SDFacebookSessionManager.h"
#import "SDServer.h"
#import "SDSessionClosedViewController.h"
#import "SDSessionOpeningViewController.h"
#import "SDToast.h"
#import "SDLocation.h"
#import "UIColor+SDColor.h"
#import "UIImage+GTImage.h"

@implementation SDAppDelegate {
    SDFacebookSessionManager *_fbSessionManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.location = [[SDLocation alloc] init];
    _fbSessionManager = [[SDFacebookSessionManager alloc] initWithDelegate:self];
    
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

- (void)onFacebookSessionOpen:(NSString *)user
{
    // because all requests to the server must include a valid Facebook access token it doesn't make sense to have
    // an instance of the server class before a valid Facebook session has been created
    self.server = [[SDServer alloc] initWithAccessToken:FBSession.activeSession.accessTokenData.accessToken delegate:self];
    
    self.user = user;
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
    self.server = nil;
    self.user = nil;
}

# pragma mark SDServerDelegate

- (void)serverDetectedBadAccessToken
{
    // The Facebook access token passes to the server was bad so close the Facebook session.
    // This will result in the user being presented with the login screen.
    [SDToast toast:@"BAD_ACCESS_TOKEN"];
    [SDFacebookSessionManager closeSession];
}

@end
