//
//  Helper.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//
#   define SEEDS_LOG(...)

#import <Foundation/Foundation.h>
#import "SeedsUrlFormatter.h"

@implementation SeedsUrlFormatter

NSString* SeedsJSONFromObject(id object)
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (error)
        SEEDS_LOG(@"%@", [error description]);
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

NSString* SeedsURLEscapedString(NSString* string)
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
    return (NSString*)CFBridgingRelease(escaped);
}

NSString* SeedsURLUnescapedString(NSString* string)
{
    NSMutableString *resultString = [NSMutableString stringWithString:string];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSMutableData (AppendStringUTF8)
-(void)appendStringUTF8:(NSString*)string
{
    [self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}
@end
