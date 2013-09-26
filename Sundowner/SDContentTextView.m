
#import "NSString+SDContentText.h"
#import "SDContentTextView.h"

@implementation SDContentTextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // prevent text change if either the text (without any embedded URL) and the URL on its own exceed limits
    // http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers
    const int kMaxTextLength = 256;
    const int kMaxURLLength = 2048;
    NSString *newText = [self.text stringByReplacingCharactersInRange:range withString:text];
    NSDictionary *parsedNewText = [newText parseAsContentText];
    BOOL textIsOK = [parsedNewText[@"text"] length] <= kMaxTextLength;
    BOOL urlIsOK = parsedNewText[@"url"] == [NSNull null] || [parsedNewText[@"url"] length] <= kMaxURLLength;
    return textIsOK && urlIsOK;
}

@end
