
#import <QuartzCore/QuartzCore.h>
#import "GTDetailFormatter.h"
#import "SDObjectCell.h"
#import "UIColor+SDColor.h"

CGFloat const GTTitleFontSize =         22;
CGFloat const GTNormalFontSize =        14;

CGFloat const GTPaddingTopInner =       10;
CGFloat const GTPaddingBottomInner =    10;
CGFloat const GTPaddingLeftInner =      10;
CGFloat const GTPaddingRightInner =     10;
CGFloat const GTPaddingTopOuter =       10;
CGFloat const GTPaddingBottomOuter =    0;
CGFloat const GTPaddingLeftOuter =      10;
CGFloat const GTPaddingRightOuter =     10;

@implementation SDObjectCell {
    NSDictionary *_object;
    UIView *_card;
}

+ (CGFloat)estimateHeightForObject:(NSDictionary *)object constrainedByWidth:(CGFloat)width
{
    // padding is defined internally within this class so should be applied here
    width -= (GTPaddingLeftInner + GTPaddingRightInner + GTPaddingLeftOuter + GTPaddingRightOuter);
    NSString *titleText = object[@"title"];
    NSString *authorText = [self constructAuthorString:object];
    CGFloat titleHeight = [self estimateHeightForTitle:titleText constrainedByWidth:width];
    CGFloat authorHeight = [self estimateHeightForAuthor:authorText constrainedByWidth:width];
    return GTPaddingTopOuter + GTPaddingTopInner + titleHeight + authorHeight + GTPaddingBottomInner + GTPaddingBottomOuter;
}

+ (CGFloat)estimateHeightForTitle:(NSString *)titleText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX); // effectively unbounded height
    CGSize size = [titleText sizeWithFont:[UIFont systemFontOfSize:GTTitleFontSize] constrainedToSize:constraint];
    return size.height;
}

+ (CGFloat)estimateHeightForAuthor:(NSString *)authorText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX);
    CGSize size = [authorText sizeWithFont:[UIFont systemFontOfSize:GTNormalFontSize] constrainedToSize:constraint];
    return size.height;
}

+ (NSString *)constructAuthorString:(NSDictionary *)object
{
    return [NSString stringWithFormat:@"by %@", object[@"username"]];
    
    // TODO once we have this in version control delete what follows
    
    double distance = ((NSNumber *)object[@"distance"]).doubleValue;
    double timestamp = ((NSNumber *)object[@"created"]).doubleValue;
    NSString *username = object[@"username"];
    
    // cache formatter for efficiency
    static GTDetailFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[GTDetailFormatter alloc] init];
    }
    
    return [formatter formatDetailForDistance:distance timestamp:timestamp username:username];
}

- (void)setObject:(NSDictionary *)object
{
    _object = object;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSString *titleText = _object[@"title"];
    BOOL hasURL = _object[@"url"] != nil;
    NSString *authorText = [[self class] constructAuthorString:_object];
    CGFloat widthConstraint = self.frame.size.width -
    (GTPaddingLeftInner + GTPaddingRightInner + GTPaddingLeftOuter + GTPaddingRightOuter);
    
    CGFloat titleHeight = [[self class] estimateHeightForTitle:titleText constrainedByWidth:widthConstraint];
    CGFloat authorHeight = [[self class] estimateHeightForAuthor:authorText constrainedByWidth:widthConstraint];
    
    // cell can't be interacted with if it doesn't have a URL
    [self setUserInteractionEnabled:hasURL];
    
    [_card setFrame:CGRectMake(GTPaddingLeftOuter,
                               GTPaddingTopOuter,
                               widthConstraint + GTPaddingLeftInner + GTPaddingRightInner,
                               titleHeight + authorHeight + GTPaddingTopInner + GTPaddingBottomInner)];
    
    CGFloat yAxisCursor = GTPaddingTopInner;
    
    self.title.text = titleText;
    [self.title setTextColor:(hasURL ? [UIColor linkColor] : [UIColor textColor])];
    [self.title setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, widthConstraint, titleHeight)];
    yAxisCursor += titleHeight;
    
    self.author.text = authorText;
    [self.author setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, widthConstraint, authorHeight)];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _card = [[UIView alloc] init];
        [_card setBackgroundColor:[UIColor whiteColor]];
        [_card.layer setCornerRadius:3.0f];
        [self addSubview:_card];
        
        self.title = [[UILabel alloc] init];
        self.title.font = [UIFont systemFontOfSize:GTTitleFontSize];
        self.title.numberOfLines = 0; // infinite
        [self.title setBackgroundColor:[UIColor clearColor]];
        [_card addSubview:self.title];
        
        self.author = [[UILabel alloc] init];
        self.author.font = [UIFont systemFontOfSize:GTNormalFontSize];
        self.author.textColor = [UIColor lightGrayColor];
        self.author.numberOfLines = 0;
        [self.author setBackgroundColor:[UIColor clearColor]];
        [_card addSubview:self.author];
        
    }
    return self;
}

@end
