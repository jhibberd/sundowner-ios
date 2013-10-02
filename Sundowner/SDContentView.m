
#import "SDContentView.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"

CGFloat const kSDContentViewPadding = 10;

@implementation SDContentView {
    UILabel *_textLabel;
    UILabel *_authorLabel;
    NSMutableAttributedString *_text;
}

// A UITableViewController needs to know in advance (of autolayout) the heights of all visible cells.
// This method (tied somewhat to the autolayout constraints algorithm) will calculate the height consumed
// by each piece of content once it has been layed out using the autolayout algorithm.
+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width
{
    NSString *titleText = content[@"text"];
    NSString *authorText = [NSString stringWithFormat:@"by %@", content[@"username"]];
    CGSize constraint = CGSizeMake(width - (kSDContentViewPadding *2), MAXFLOAT);
    CGSize titleSize = [titleText sizeWithFont:[UIFont titleFont] constrainedToSize:constraint];
    CGSize authorSize = [authorText sizeWithFont:[UIFont normalFont] constrainedToSize:constraint];
    return titleSize.height + authorSize.height + (kSDContentViewPadding *2);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0;
        
        // disable older layout mechanism otherwise auto layout doesn't work
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont titleFont];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.textColor = [UIColor lightGrayColor];
        _authorLabel.font = [UIFont normalFont];
        _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _authorLabel.numberOfLines = 0;
        [self addSubview:_authorLabel];
        
        // define layout constraints
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(self, _textLabel, _authorLabel);
        NSArray *constaintFormats = @[
            [NSString stringWithFormat:@"V:|-%f-[_textLabel]-0-[_authorLabel]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"|-%f-[_textLabel]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"|-%f-[_authorLabel]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"[self(%f)]", self.frame.size.width]
            ];
        for (NSString *constaintFormat in constaintFormats) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constaintFormat
                                                                         options:0
                                                                         metrics:nil
                                                                           views:variableBindings]];
        }
        
        // ensure height of UILabel grows to fit the text with autolayout
        // http://stackoverflow.com/questions/16009405/uilabel-sizetofit-doesnt-work-with-autolayout-ios6
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.preferredMaxLayoutWidth = self.frame.size.width - (kSDContentViewPadding *2);
        [_textLabel setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisVertical];
        [_textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                               forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}
 
- (void)setContent:(NSDictionary *)content
{
    _text = [[NSMutableAttributedString alloc] initWithString:content[@"text"]];
    _textLabel.attributedText = _text;
    _textLabel.textColor = content[@"url"] == [NSNull null] ? [UIColor textColor] : [UIColor linkColor];
    _authorLabel.text = [NSString stringWithFormat:@"by %@", content[@"username"]];
}

- (void)beginVoteDownAnimation
{
    // sadly neither strikethrough nor text color are animatable properties
    [_text addAttribute:NSStrikethroughStyleAttributeName
                  value:@(NSUnderlineStyleSingle)
                  range:NSMakeRange(0, [_text length])];
    _textLabel.attributedText = _text;
    _textLabel.textColor = [UIColor backgroundTextColor];

    // visually restore the text label following a short delay
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(strikethroughTextWaitComplete:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)strikethroughTextWaitComplete:(NSTimer *)timer
{
    [_text addAttribute:NSStrikethroughStyleAttributeName
                  value:@(NSUnderlineStyleNone)
                  range:NSMakeRange(0, [_text length])];
    _textLabel.attributedText = _text;
    _textLabel.textColor = [UIColor textColor];
}

@end
