
#import <Foundation/Foundation.h>

@protocol SDFacebookSessionManagerDelegate <NSObject>
- (void)onFacebookSessionOpen:(NSString *)user;
- (void)onFacebookSessionOpening;
- (void)onFacebookSessionClosed;
@end
