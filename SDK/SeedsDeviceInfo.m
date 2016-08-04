//
//  SeedsDeviceInfo.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#   define SEEDS_LOG(...)

#import <Foundation/Foundation.h>
#import "SeedsDeviceInfo.h"
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "SeedsUrlFormatter.h"

#pragma mark - Helper Functions

@interface SeedsDeviceInfo()
@end

@implementation SeedsDeviceInfo

+ (NSString *)device
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    char *modelKey = "hw.machine";
#else
    char *modelKey = "hw.model";
#endif
    size_t size;
    sysctlbyname(modelKey, NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname(modelKey, model, &size, NULL, 0);
    NSString *modelString = @(model);
    free(model);
    return modelString;
}

+ (NSString *)osName
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    return @"iOS";
#else
    return @"OS X";
#endif
}

+ (NSString *)osVersion
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    return [[UIDevice currentDevice] systemVersion];
#else
    return [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
#endif
}

+ (NSString *)carrier
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    if (NSClassFromString(@"CTTelephonyNetworkInfo"))
    {
        CTTelephonyNetworkInfo *netinfo = [CTTelephonyNetworkInfo new];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        return [carrier carrierName];
    }
#endif
    return nil;
}

+ (NSString *)resolution
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat scale = [UIScreen.mainScreen respondsToSelector:@selector(scale)] ? [UIScreen.mainScreen scale] : 1.f;
    return [NSString stringWithFormat:@"%gx%g", bounds.size.width * scale, bounds.size.height * scale];
#else
    NSRect screenRect = NSScreen.mainScreen.frame;
    CGFloat scale = [NSScreen.mainScreen backingScaleFactor];
    return [NSString stringWithFormat:@"%gx%g", screenRect.size.width * scale, screenRect.size.height * scale];
#endif
}

+ (NSString *)locale
{
    return [[NSLocale currentLocale] localeIdentifier];
}

+ (NSString *)appVersion
{
    NSString *result = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([result length] == 0)
        result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    return result;
}

+ (NSString *)metrics
{
    NSMutableDictionary* metricsDictionary = [NSMutableDictionary dictionary];
    metricsDictionary[@"_device"] = SeedsDeviceInfo.device;
    metricsDictionary[@"_os"] = SeedsDeviceInfo.osName;
    metricsDictionary[@"_os_version"] = SeedsDeviceInfo.osVersion;
    
    NSString *carrier = SeedsDeviceInfo.carrier;
    if (carrier)
        metricsDictionary[@"_carrier"] = carrier;
    
    metricsDictionary[@"_resolution"] = SeedsDeviceInfo.resolution;
    metricsDictionary[@"_locale"] = SeedsDeviceInfo.locale;
    NSString *appVersion = [SeedsDeviceInfo appVersion];
    if (appVersion) {
        metricsDictionary[@"_app_version"] = appVersion;
    }
    NSLog(@"%@", metricsDictionary);
    return SeedsURLEscapedString(SeedsJSONFromObject(metricsDictionary));
}

+ (NSString *)bundleId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
