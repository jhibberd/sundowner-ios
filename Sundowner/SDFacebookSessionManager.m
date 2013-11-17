
#import "SDFacebookSessionManager.h"

@implementation SDFacebookSessionManager {
    id<SDFacebookSessionManagerDelegate> _delegate;
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

+ (void)handleApplicationDidBecomeActive
{
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

+ (void)closeSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (id)initWithDelegate:(id<SDFacebookSessionManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        _delegate = delegate;
        self.loginView = [[FBLoginView alloc] init];
        self.loginView.delegate = self;
        
        // temporary hack to what looks like a Facebook bug
        // http://stackoverflow.com/questions/19126703/the-parameter-custom-events-or-custom-events-file-is-required-for-the-custo
        [FBAppEvents setFlushBehavior:FBAppEventsFlushBehaviorExplicitOnly];
    }
    return self;
}

# pragma mark FBLoginViewDelegate

// don't need to implement loginViewShowingLoggedInUser: because loginViewFetchedUserInfo:user is always
// called afterwards

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // we have an active Facebook session (which includes a valid access token)
    [_delegate onFacebookSessionOpen:user.name];
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [_delegate onFacebookSessionClosed];
}

@end
