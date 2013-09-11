
#import "GTDetailFormatter.h"

@implementation GTDetailFormatter

- (NSString *)formatDetailForDistance:(double)distance
                            timestamp:(double)timestamp
                             username:(NSString *)username
{
    NSString *formattedDistance = [self formatDistance:distance];
    NSString *formattedTimestamp = [self formatTimestamp:timestamp];
    return [NSString stringWithFormat:@"%@, %@ by %@", formattedDistance, formattedTimestamp, username];
}

- (NSString *)formatTimestamp:(double)timestamp
{
    /* Testing resource:
     * http://www.4webhelp.net/us/timestamp.php
     */
    static uint const SECONDS_PER_HOUR = 3600;
    static uint const SECONDS_PER_DAY = SECONDS_PER_HOUR * 24;
    static uint const SECONDS_PER_MONTH = SECONDS_PER_DAY * 30; // average days in a month
    
    NSDate *now = [NSDate date];
    NSDate *timestampDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    double delta = [now timeIntervalSince1970] - timestamp;
    
    /* Date format specifiers:
     * http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
     *
     * Strings that aren't supported by the date formatter will have to be translated by another
     * mechanism into the user's locale (eg. "Yesterday").
     */
    NSString *formatString = nil;
    if (delta > SECONDS_PER_MONTH * 11) {
        /* 11 months is used instead of 12 because if something happened 12 months ago it will have
         * happened during the same month as now, which would be confusing.
         */
        formatString = @"d MMMM yyyy"; // 3 August 2011
        
    } else if (delta > SECONDS_PER_MONTH) {
        formatString = @"d MMMM"; // 3 August
        
    } else if (delta > SECONDS_PER_DAY * 6) {
        /* 6 days is used instead of 7 because if something happened 7 days ago it will have happened
         * on the same day of the week as now, which would be confusing.
         */
        formatString = @"d MMMM 'at' H':'mm"; // 3 August at 14:22
        
    } else if (delta >= SECONDS_PER_HOUR * 2) {
        
        // get the weekday for the timestamp and now
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger timestampWeekday = [calendar components:NSWeekdayCalendarUnit fromDate:timestampDate].weekday;
        NSInteger nowWeekday = [calendar components:NSWeekdayCalendarUnit fromDate:now].weekday;

        if (timestampWeekday == nowWeekday) {
            int hours = delta / SECONDS_PER_HOUR;
            formatString = [NSString stringWithFormat:@"'%d hours ago'", hours]; // 4 hours ago
            
        } else if ([self is:timestampWeekday yesterdayOf:nowWeekday]) {
            formatString = @"'yesterday at' H':'mm"; // Yesterday at 14:22
            
        } else {
            formatString = @"eeee 'at' H':'mm"; // Thursday at 14:22
        }
        
    } else if (delta >= SECONDS_PER_HOUR) {
        formatString = @"'1 hour ago'"; // 1 hour ago
        
    } else {
        formatString = @"'moments ago'";
    }
    
    // cache formatter for efficiency
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter stringFromDate:timestampDate];
}

- (BOOL)is:(NSInteger)candidateDay yesterdayOf:(NSInteger)anchorDay
{
    static BOOL init = NO;
    static NSInteger maxWeekday;
    if (!init) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        maxWeekday = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
        init = YES;
    }
    
    if (anchorDay > 1) {
        return candidateDay == anchorDay - 1;
    } else {
        return candidateDay == maxWeekday;
    }
}

- (NSString *)formatDistance:(double)distance
{
    // distance is measured in meters
    if (distance > 100000) {
        return @"far, far away";
    } else if (distance > 10000) {
        return [NSString stringWithFormat:@"%.0f km", distance / 1000];
    } else if (distance > 1000) {
        return [NSString stringWithFormat:@"%.2f km", distance / 1000];
    } else if (distance > 10) {
        return [NSString stringWithFormat:@"%.0f meters", distance];
    } else if (distance > 5) {
        return [NSString stringWithFormat:@"%.2f meters", distance];
    } else {
        return @"here";
    }
}

@end
