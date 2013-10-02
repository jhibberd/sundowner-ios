
#import <QuartzCore/QuartzCore.h>
#import "SDContentCell.h"
#import "SDContentView.h"
#import "SDLikeView.h"
#import "UIColor+SDColor.h"

CGFloat const kSDContentCellHorizontalPadding =     10;
CGFloat const kSDContentCellVerticalPadding =       5;

// this aspect ratio must be maintained for correct shape proportion (original 110x95)
static NSUInteger const kSDLikeViewWidth =          77;
static NSUInteger const kSDLikeViewHeight =         66.5;

@implementation SDContentCell {
    
    SDContentView *_contentView;
    
    // for managing the horizontal scrolling (voting down) of content
    CGPoint _originalCenter;
    BOOL _voteDownOnDragRelease;
}

+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width
{
    CGFloat contentViewWidth = width - (kSDContentCellHorizontalPadding *2);
    CGFloat contentViewHeight = [SDContentView calculateContentHeight:content constrainedByWidth:contentViewWidth];
    return contentViewHeight + (kSDContentCellVerticalPadding *2);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundColor = [UIColor backgroundColor];
        
        // TODO it would be nice not to have to define the width first and rely on autolayout entirely
        // but it's not easy and so far a solution hasn't been found
        CGFloat width = self.frame.size.width - (kSDContentCellHorizontalPadding *2);
        _contentView = [[SDContentView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_contentView];
        
        NSString *constraintFormat = nil;
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(_contentView);
        constraintFormat = [NSString stringWithFormat:@"V:|-%f-[_contentView]-%f-|",
                            kSDContentCellVerticalPadding, kSDContentCellVerticalPadding];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormat
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:variableBindings]];
        constraintFormat = [NSString stringWithFormat:@"|-%f-[_contentView]-%f-|",
                            kSDContentCellHorizontalPadding, kSDContentCellHorizontalPadding];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormat
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:variableBindings]];
        
        UILongPressGestureRecognizer *longPressGestureRecogniser =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToLongPressGesture:)];
        longPressGestureRecogniser.minimumPressDuration = 1.5;
        [self addGestureRecognizer:longPressGestureRecogniser];
        
        UITapGestureRecognizer *singleTapGestureRecogniser =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSingleTapGesture:)];
        singleTapGestureRecogniser.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecogniser];
        
        UITapGestureRecognizer *doubleTapGestureRecogniser =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToDoubleTapGesture:)];
        doubleTapGestureRecogniser.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecogniser];
        
        // single and double tap gestures are mutually exclusive; the cost of this is a slight delay in
        // responding to single taps
        [singleTapGestureRecogniser requireGestureRecognizerToFail:doubleTapGestureRecogniser];

    }
    return self;
}

- (void)setContent:(NSDictionary *)content
{
    _content = content;
    _contentView.content = content;
}

# pragma mark Handling Gestures

- (void)respondToLongPressGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate contentVotedDown:_content];
        [_contentView beginVoteDownAnimation];
    }
}

- (void)respondToDoubleTapGesture:(UIGestureRecognizer *)recognizer
{    
    // notify the delegate that content has been vote up (so that it can notify the server)
    [self.delegate contentVotedUp:_content];
    
    // add the like view to the content view
    CGRect frame = CGRectMake(0, 0, kSDLikeViewWidth, kSDLikeViewHeight);
    SDLikeView *likeView = [[SDLikeView alloc] initWithFrame:frame];
    likeView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    likeView.alpha = 0;
    likeView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self addSubview:likeView];

    // animate it
    [UIView animateWithDuration:.15 animations:^{
        likeView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        likeView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            likeView.alpha = 0;
        } completion:^(BOOL finished) {
            [likeView removeFromSuperview];
        }];
    }];
}

- (void)respondToSingleTapGesture:(UIGestureRecognizer *)recognizer
{
    if (_content[@"url"] != nil) {
        [self.delegate contentURLRequested:_content];
    }
}

@end
