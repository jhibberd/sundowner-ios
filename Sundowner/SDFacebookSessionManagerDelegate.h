
#import <Foundation/Foundation.h>

@protocol SDFacebookSessionManagerDelegate <NSObject>
- (void)onFacebookSessionOpen;
- (void)onFacebookSessionOpening;
- (void)onFacebookSessionClosed;
@end
