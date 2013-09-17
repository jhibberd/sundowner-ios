
#import <Foundation/Foundation.h>

@protocol SDContentCellDelegate <NSObject>
- (void)contentVotedDown:(NSDictionary *)content;
- (void)contentURLRequested:(NSDictionary *)content;
@end
