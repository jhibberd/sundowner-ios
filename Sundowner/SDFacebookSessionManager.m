
#import "SDFacebookSessionManager.h"
#import "SDLocalNativeAccountData.h"
#import "SDServer.h"

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
    [SDLocalNativeAccountData clear];
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
    
    // check that we have a locally stored native user ID
    SDLocalNativeAccountData *account = [SDLocalNativeAccountData load];
    if (account == NULL) {
        
        // No locally stored native user ID (typically because this is the first time that the user has
        // logged into Facebook from this device). Retrieve it from the server using the Facebook access
        // token.
        [_delegate onFacebookSessionOpening];
        NSString *accessToken = FBSession.activeSession.accessTokenData.accessToken;
        SDServer *server = [[SDServer alloc] init];
        [server getUserId:accessToken onSuccess:^(NSDictionary *response) {
            NSLog(@"Retrieved native user ID from server");
            
            // store the native user data locally
            NSDictionary *data = response[@"data"];
            NSString *userId = data[@"id"];
            NSString *userName = data[@"name"];
            SDLocalNativeAccountData *account = [[SDLocalNativeAccountData alloc] init];
            account.userName = userName;
            account.userId = userId;
            [account save];
            
            [_delegate onFacebookSessionOpen];
            
        } onFailure:^(NSDictionary *response) {
            NSLog(@"Failed to get native user ID from the server");
            [_delegate onFacebookSessionClosed];
        }];
        
    } else {
        [_delegate onFacebookSessionOpen];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [_delegate onFacebookSessionClosed];
}

@end
