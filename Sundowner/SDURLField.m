
#import "SDContentCell.h"
#import "SDURLField.h"
#import "UIColor+SDColor.h"

static NSString *kGTInfoText = @"To link this message to a webpage, copy a URL into your pasteboard, then come back.";
static CGFloat kGTURLPaddingTop = 15;
static CGFloat kGTMaxVisibleURLLength = 70;

typedef NS_ENUM(NSInteger, GTState) {
    GTUninitialized,
    GTStateLinked,
    GTStateLinkable,
    GTStateUnlinked
};

@implementation SDURLField {
    UILabel *_label;
    NSString *_candidateURL;
    GTState _state;
    CGFloat _width;
    id <SDURLFieldDelegate> _delegate;
}

# pragma mark Public

- (id)initWithWidth:(CGFloat)width delegate:(id <SDURLFieldDelegate>)delegate
{
    self = [super init];
    if (self) {
        
        _width = width;
        _delegate = delegate;
        
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:GTNormalFontSize];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        // setup initial unlinked state
        _state = GTUninitialized;
        _candidateURL = nil;
        self.url = nil;
        [self addTarget:self action:@selector(buttonWasClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)refreshStateUsingPasteboard
{
    NSString *pasteboardURL = [self getURLFromPasteboard];

    // determine the state that the control should be in
    GTState correctState;
    if (_url == nil) {
        if (pasteboardURL == nil) {
            correctState = GTStateUnlinked;
        } else {
            correctState = GTStateLinkable;
        }
    } else {
        correctState = GTStateLinked;
    }
    
    BOOL candidateURLHasChanged = ![_candidateURL isEqualToString:pasteboardURL];
    _candidateURL = pasteboardURL;
    
    // Compare it with the current state to see if a state change needs to take place. If
    // the state is GTStateLinkable but a different candidate URL has been received then
    // initiate a change to a new GTStateLinkable.    
    BOOL needsUpdating = NO;
    if (_state == correctState) {
        if (_state == GTStateLinkable && candidateURLHasChanged) {
            needsUpdating = YES;
        }
    } else {
        needsUpdating = YES;
    }
    if (!needsUpdating) {
        return;
    }
    
    // change to the correct state
    switch (correctState) {
        case GTStateLinked:
            [self setupStateLinked];
            break;
        case GTStateLinkable:
            [self setupStateLinkable];
            break;
        case GTStateUnlinked:
            [self setupStateUnlinked];
            break;
        case GTUninitialized:
            NSAssert(NO, @"Should always have an initialised state at this point");
    }
}

# pragma mark Private

- (NSString *)getURLFromPasteboard
{
    NSString *url = [UIPasteboard generalPasteboard].string;
    if (url == nil) {
        return nil;
    }
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        return url;
    } else {
        return nil;
    }
}

- (void)buttonWasClicked:(UIButton *)sender
{
    // link to a URL
    if (_state == GTStateLinked) {
        _url = nil;
        if (_candidateURL == nil) {
            [self setupStateUnlinked];
        } else {
            [self setupStateLinkable];
        }
    
    // unlink from a URL
    } else if (_state == GTStateLinkable) {
        _url = _candidateURL;
        [self setupStateLinked];
    }
}

- (void)setupStateLinked
{
    _state = GTStateLinked;

    NSString *stringLine1 = [NSString stringWithFormat:@"Linked to %@", [self cropURL:_url]];
    NSString *stringLine2 = @"Unlink";
    NSString *string = [NSString stringWithFormat:@"%@\n%@", stringLine1, stringLine2];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor lightGrayColor]
                       range:NSMakeRange(0, [stringLine1 length])];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor linkColor]
                       range:NSMakeRange([stringLine1 length]+1, [stringLine2 length])];
    [self setLabelText:attrString];
}

- (void)setupStateLinkable
{    
    _state = GTStateLinkable;
    
    NSString *string = [NSString stringWithFormat:@"Link to %@", [self cropURL:_candidateURL]];
    NSDictionary *attr = @{NSForegroundColorAttributeName: [UIColor linkColor]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attr];
    [self setLabelText:attrString];
}

- (void)setupStateUnlinked
{
    _state = GTStateUnlinked;
    
    NSDictionary *attr = @{NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:kGTInfoText attributes:attr];
    [self setLabelText:attrString];
}

- (void)setLabelText:(NSAttributedString *)text
{
    // When the text contains a URL we need to use NSLineBreakByCharWrapping otherwise the measuring of text
    // doesn't work. The rest of the time use NSLineBreakByWordWrapping for more natural wrapping.
    NSLineBreakMode lineBreakMode = _state == GTStateUnlinked ? NSLineBreakByWordWrapping : NSLineBreakByCharWrapping;
    
    CGSize constraint = CGSizeMake(_width, INT_MAX);
    CGSize size = [text.string sizeWithFont:[UIFont systemFontOfSize:GTNormalFontSize]
                          constrainedToSize:constraint
                              lineBreakMode:lineBreakMode];
    CGFloat textHeight = size.height;
        
    self.frame = CGRectMake(0, 0, _width, textHeight + kGTURLPaddingTop);
    _label.lineBreakMode = lineBreakMode;
    _label.frame = CGRectMake(0, kGTURLPaddingTop, _width, textHeight);
    _label.attributedText = text;
    
    // notify the delegate that this control's frame has changed so that the delegate can resize
    // itself accordingly
    [_delegate urlFieldDidResize];
}

- (NSString *)cropURL:(NSString *)url
{
    // http://stackoverflow.com/questions/2952298/how-can-i-truncate-an-nsstring-to-a-set-length
    NSRange range = {0, MIN([url length], kGTMaxVisibleURLLength)};
    range = [url rangeOfComposedCharacterSequencesForRange:range];
    NSString *cropped = [url substringWithRange:range];
    if ([cropped isEqualToString:url]) {
        return url;
    } else {
        return [NSString stringWithFormat:@"%@...", cropped];
    }
}

@end
