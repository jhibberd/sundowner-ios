
#import <Foundation/Foundation.h>
#import "SDBestLocation.h"

@protocol SDBestLocationDelegate <NSObject>
- (void)locationManagerFailed;
@end
