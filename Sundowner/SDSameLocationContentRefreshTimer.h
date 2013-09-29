
#import <Foundation/Foundation.h>
#import "SDSameLocationContentRefreshTimerDelegate.h"

@interface SDSameLocationContentRefreshTimer : NSObject
@property (strong, retain) id<SDSameLocationContentRefreshTimerDelegate> delegate;
- (void)start;
- (void)locationDidChange;
- (void)stop;
@end
