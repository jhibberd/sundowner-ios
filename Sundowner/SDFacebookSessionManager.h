
#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>
#import "SDFacebookSessionManagerDelegate.h"

// abstract complexities of managing an authenticated Facebook session
@interface SDFacebookSessionManager : NSObject <FBLoginViewDelegate>
+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)handleApplicationDidBecomeActive;
+ (void)closeSession;
@property (nonatomic, strong) FBLoginView *loginView;
- (id)initWithDelegate:(id<SDFacebookSessionManagerDelegate>)delegate;
@end
