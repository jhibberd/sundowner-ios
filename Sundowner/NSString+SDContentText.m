
#import "NSString+SDContentText.h"

@implementation NSString (SDContentText)

- (NSDictionary *)parseAsContentText
{
    NSObject *url = [NSNull null];
    NSMutableString *mutableText = [[NSMutableString alloc] initWithString:self];
    
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    // if multiple URLs were found in the text just extract the first
    if ([matches count] > 0) {
        NSTextCheckingResult *match = [matches firstObject];
        url = [[match URL] description];
        [mutableText deleteCharactersInRange:[match range]];
    }
    
    // trim any whitespace characters from the end of the text (which might have been caused by extracting
    // the URL
    NSString *trimmedText = [mutableText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    mutableText = [[NSMutableString alloc] initWithString:trimmedText];
    
    return @{@"text": mutableText, @"url": url};
}

@end
