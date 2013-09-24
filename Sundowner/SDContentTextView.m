
#import "NSString+SDContentText.h"
#import "SDContentTextView.h"

@implementation SDContentTextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // prevent text change if it exceeds text limit (embedded URL doesn't count towards length)
    const int kMaxTextLength = 256;
    NSString *newText = [self.text stringByReplacingCharactersInRange:range withString:text];
    NSDictionary *parsedNewText = [newText parseAsContentText];
    return [parsedNewText[@"text"] length] <= kMaxTextLength;
}

@end
