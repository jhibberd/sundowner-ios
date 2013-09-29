
#import "SDSameLocationContentRefreshTimer.h"

// should be slightly different to location update seconds to avoid double request
static NSTimeInterval const kSDSecondsBeforeRefreshDue = 22;

@implementation SDSameLocationContentRefreshTimer {
    NSTimer *_timer;
}

# pragma mark Public

- (void)start
{
    [self resetCountdown];
}

- (void)stop
{
    [_timer invalidate];
}

- (void)locationDidChange
{
    [self resetCountdown];
}

# pragma mark Private

- (void)resetCountdown
{
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kSDSecondsBeforeRefreshDue
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)tick:(NSTimer *)timer
{
    NSLog(@"Refreshing content because location is still the same");
    [self.delegate shouldRefreshContentAsLocationIsStillSame];
    [self resetCountdown];
}

@end
