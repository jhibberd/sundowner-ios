
#import "SDContentView.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"
#import "UILabel+SDLabel.h"

CGFloat const kSDContentViewPadding = 10;
CGFloat const kSDURLIndicatorTabSize = 25.0f;

@implementation SDContentView {
    UILabel *_textLabel;
    UILabel *_authorLabel;
    BOOL _hasURL;
    NSMutableAttributedString *_text;
}

// A UITableViewController needs to know in advance (of autolayout) the heights of all visible cells.
// This method (tied somewhat to the autolayout constraints algorithm) will calculate the height consumed
// by each piece of content once it has been layed out using the autolayout algorithm.
+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width
{
    // content to display
    NSString *titleText = content[@"text"];
    NSString *authorText = content[@"username"];
    
    CGSize constraint = CGSizeMake(width - (kSDContentViewPadding *2), MAXFLOAT);
    CGFloat result = (kSDContentViewPadding *2);
    
    // content always visible:
    CGSize titleSize = [titleText sizeWithFont:[UIFont titleFont] constrainedToSize:constraint];
    result += titleSize.height;
    
    // optional content:
    // a username is hidden for content authored by someone other than a Facebook friend
    if (authorText != nil) {
        CGSize authorSize = [authorText sizeWithFont:[UIFont normalFont] constrainedToSize:constraint];
        result += authorSize.height;
    }
    
    return result;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        
        // disable older layout mechanism otherwise auto layout doesn't work
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor textColor];
        _textLabel.font = [UIFont titleFont];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.numberOfLines = 0;
        CGFloat width = self.frame.size.width - (kSDContentViewPadding *2);
        [_textLabel autoGrowHeightCompatForWidth:width];
        [self addSubview:_textLabel];
        
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.textColor = [UIColor subtextColor];
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
        
    }
    return self;
}

- (void)setContent:(NSDictionary *)content
{
    _text = [[NSMutableAttributedString alloc] initWithString:content[@"text"]];
    _textLabel.attributedText = _text;
    NSString *username = content[@"username"];
    _hasURL = [content objectForKey:@"url"] != nil;
    if (username == nil) {
        _authorLabel.hidden = YES;
    } else {
        _authorLabel.hidden = NO;
        _authorLabel.text = username;
    }
}

- (void)beginVoteDownAnimation
{
    // sadly neither strikethrough nor text color are animatable properties
    [_text addAttribute:NSStrikethroughStyleAttributeName
                  value:@(NSUnderlineStyleSingle)
                  range:NSMakeRange(0, [_text length])];
    _textLabel.attributedText = _text;
    _textLabel.textColor = [UIColor subtextColor];

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

// if the tag links to a URL draw a tab in the top-right corner of the tag as a visual indication
- (void)drawRect:(CGRect)rect
{
    if (!_hasURL) {
        return;
    }
    static CGMutablePathRef path;
    if (path == NULL) {
        CGFloat x = [self bounds].size.width - kSDURLIndicatorTabSize;
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, x, 0);
        CGPathAddLineToPoint(path, NULL, x + kSDURLIndicatorTabSize, 0);
        CGPathAddLineToPoint(path, NULL, x + kSDURLIndicatorTabSize, kSDURLIndicatorTabSize);
        CGPathAddLineToPoint(path, NULL, x, 0);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor urlIndicatorColor].CGColor);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
}

@end
