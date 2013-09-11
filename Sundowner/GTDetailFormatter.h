
#import <Foundation/Foundation.h>

@interface GTDetailFormatter : NSObject
- (NSString *)formatDetailForDistance:(double)distance
                            timestamp:(double)timestamp
                             username:(NSString *)username;
@end
