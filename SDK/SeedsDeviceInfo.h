#pragma mark - SeedsDeviceInfo

@interface SeedsDeviceInfo : NSObject

+ (NSString *)device;
+ (NSString *)osName;
+ (NSString *)osVersion;
+ (NSString *)carrier;
+ (NSString *)resolution;
+ (NSString *)locale;
+ (NSString *)appVersion;

+ (NSString *)metrics;

+ (NSString *)bundleId;

@end