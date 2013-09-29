
#import <Foundation/Foundation.h>

@protocol SDSameLocationContentRefreshTimerDelegate <NSObject>
- (void)shouldRefreshContentAsLocationIsStillSame;
@end
