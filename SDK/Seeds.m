//
//

#pragma mark - Directives

#ifndef SEEDS_DEBUG
#define SEEDS_DEBUG 0
#endif

#ifndef SEEDS_IGNORE_INVALID_CERTIFICATES
#define SEEDS_IGNORE_INVALID_CERTIFICATES 0
#endif

#if SEEDS_DEBUG
#   define SEEDS_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define SEEDS_LOG(...)
#endif


#ifndef SEEDS_TARGET_WATCHKIT
#define SEEDS_DEFAULT_UPDATE_INTERVAL 60.0
#define SEEDS_EVENT_SEND_THRESHOLD 10
#else
#define SEEDS_DEFAULT_UPDATE_INTERVAL 10.0
#define SEEDS_EVENT_SEND_THRESHOLD 3
#import <WatchKit/WatchKit.h>
#endif

#define SEEDS_DEFAULT_UPDATE_INTERVAL 60.0

#define SEEDS_DEFAULT_URL @"https://dash.playseeds.com"

#import <Foundation/Foundation.h>
#import "Seeds.h"
#import "Seeds_Private.h"
#import "SeedsEventQueue.h"
#import "SeedsDeviceInfo.h"
#import "SeedsConnectionQueue.h"
#import "SeedsInterstitialAds.h"
#import "Seeds_OpenUDID.h"
#import "SeedsUserDetails.h"
#import "SeedsDB.h"
#import "SeedsUrlFormatter.h"
#import "NSString+MobFox.h"
#import "SeedsInAppMessageDelegate.h"

#import <objc/runtime.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

#include <sys/types.h>
#include <sys/sysctl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>

typedef void (^ SeedsInAppPurchaseCountCallback)(NSString* errorMessage, int purchasesCount);
typedef void (^ SeedsInAppMessageShowCountCallback)(NSString* errorMessage, int showCount);
typedef void (^ SeedsGenericUserBehaviorQueryCallback)(NSString* errorMessage, id result);

@implementation Seeds {
    double unsentSessionLength;
    NSTimer *timer;
    time_t startTime;
    double lastTime;
    BOOL isSuspended;
    SeedsEventQueue *eventQueue;
    NSDictionary *crashCustom;
    NSMutableDictionary *_messageInfos;
}

@synthesize inAppMessageDelegate;

+ (instancetype)sharedInstance
{
    static Seeds *s_sharedSeeds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{s_sharedSeeds = self.new;});
    return s_sharedSeeds;
}

- (instancetype)init
{
    if (self = [super init])
    {
        timer = nil;
        startTime = time(NULL);
        isSuspended = NO;
        unsentSessionLength = 0;
        eventQueue = [[SeedsEventQueue alloc] init];
        crashCustom = nil;
        
        
        _messageInfos = [NSMutableDictionary new];
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackgroundCallBack:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForegroundCallBack:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminateCallBack:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
#endif
        
        self.deviceId = nil;
        self.adClicked = NO;
    }
    return self;
}

//////////////////////

+ (void)initWithAppKey:(NSString *)appKey {
    [[Seeds sharedInstance] start:appKey withHost:SEEDS_DEFAULT_URL];
}

+ (SeedsInterstitials *)interstitials {
    static SeedsInterstitials *sharedObject = nil;
    static dispatch_once_t onceToken;
    Seeds *seedsInstance = [Seeds sharedInstance];
    dispatch_once(&onceToken, ^{
        sharedObject = [SeedsInterstitials new];
        seedsInstance.inAppMessageDelegate = (SeedsInterstitials <SeedsInAppMessageDelegate> *)sharedObject;
    });
    return sharedObject;
}

+ (SeedsEvents *)events {
    static SeedsEvents *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [SeedsEvents new];
    });
    return sharedObject;
}

//////////////////////

- (void)start:(NSString *)appKey withHost:(NSString *)appHost
{
    [self start:appKey withHost:appHost andDeviceId:nil];
}

- (void)start:(NSString *)appKey withHost:(NSString *)appHost andDeviceId:(NSString *)deviceId
{
    NSString *validUrl = @".+(?:\\.playseeds\\.com)$";
    NSPredicate *isValidUrl = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validUrl];

    if (appKey == nil || appKey.length < 20) {
        [NSException raise:@"A valid app key is required" format:@"App key of %@ is invalid", appKey];
    }
    
    if (![isValidUrl evaluateWithObject:appHost]) {
        [NSException raise:@"A valid server url is required" format:@"Url of %@ is invalid. Did you mean: http://dash.playseeds.com ", appHost];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:SEEDS_DEFAULT_UPDATE_INTERVAL
                                             target:self
                                           selector:@selector(onTimer:)
                                           userInfo:nil
                                            repeats:YES];
    lastTime = CFAbsoluteTimeGetCurrent();
    self.deviceId = deviceId ? deviceId : [Seeds_OpenUDID value];
    
    [[SeedsConnectionQueue sharedInstance] setAppKey:appKey];
    [[SeedsConnectionQueue sharedInstance] setAppHost:appHost];
    [[SeedsConnectionQueue sharedInstance] beginSession];
    
    [[SeedsInterstitialAds sharedInstance] setAppKey:appKey];
    [[SeedsInterstitialAds sharedInstance] setAppHost:appHost];
}

- (NSString *)getAppKey {
    return [[SeedsConnectionQueue sharedInstance] appKey];
}

- (NSString *)getAppHost {
    return [[SeedsConnectionQueue sharedInstance] appHost];
}

- (BOOL)isStarted
{
    return (timer != nil);
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
- (void)startWithMessagingUsing:(NSString *)appKey withHost:(NSString *)appHost andOptions:(NSDictionary *)options
{
    [self start:appKey withHost:appHost];
    
    NSDictionary *notification = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        SEEDS_LOG(@"Got notification on app launch: %@", notification);
        //        [self handleRemoteNotification:notification displayingMessage:NO];
    }
}

- (void)startWithTestMessagingUsing:(NSString *)appKey withHost:(NSString *)appHost andOptions:(NSDictionary *)options
{
    [self start:appKey withHost:appHost];
    [[SeedsConnectionQueue sharedInstance] setStartedWithTest:YES];
    
    NSDictionary *notification = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        SEEDS_LOG(@"Got notification on app launch: %@", notification);
        [self handleRemoteNotification:notification displayingMessage:NO];
    }
    
    [self withAppStoreId:^(NSString *appId) {
        NSLog(@"ID: %@", appId);
    }];
}

- (NSMutableSet *) seedsNotificationCategories {
    return [self seedsNotificationCategoriesWithActionTitles:@[@"Cancel", @"Open", @"Update", @"Review"]];
}

- (NSMutableSet *) seedsNotificationCategoriesWithActionTitles:(NSArray *)actions {
    UIMutableUserNotificationCategory *url = [UIMutableUserNotificationCategory new],
    *upd = [UIMutableUserNotificationCategory new],
    *rev = [UIMutableUserNotificationCategory new];
    
    url.identifier = @"[CLY]_url";
    upd.identifier = @"[CLY]_update";
    rev.identifier = @"[CLY]_review";
    
    UIMutableUserNotificationAction *cancel = [UIMutableUserNotificationAction new],
    *open = [UIMutableUserNotificationAction new],
    *update = [UIMutableUserNotificationAction new],
    *review = [UIMutableUserNotificationAction new];
    
    cancel.identifier = @"[CLY]_cancel";
    open.identifier   = @"[CLY]_open";
    update.identifier = @"[CLY]_update";
    review.identifier = @"[CLY]_review";
    
    cancel.title = actions[0];
    open.title   = actions[1];
    update.title = actions[2];
    review.title = actions[3];
    
    cancel.activationMode = UIUserNotificationActivationModeBackground;
    open.activationMode   = UIUserNotificationActivationModeForeground;
    update.activationMode = UIUserNotificationActivationModeForeground;
    review.activationMode = UIUserNotificationActivationModeForeground;
    
    cancel.destructive = NO;
    open.destructive   = NO;
    update.destructive = NO;
    review.destructive = NO;
    
    
    [url setActions:@[cancel, open] forContext:UIUserNotificationActionContextMinimal];
    [url setActions:@[cancel, open] forContext:UIUserNotificationActionContextDefault];
    
    [upd setActions:@[cancel, update] forContext:UIUserNotificationActionContextMinimal];
    [upd setActions:@[cancel, update] forContext:UIUserNotificationActionContextDefault];
    
    [rev setActions:@[cancel, review] forContext:UIUserNotificationActionContextMinimal];
    [rev setActions:@[cancel, review] forContext:UIUserNotificationActionContextDefault];
    
    NSMutableSet *set = [NSMutableSet setWithObjects:url, upd, rev, nil];
    
    return set;
}
#endif

- (void)recordEvent:(NSString *)key count:(int)count
{
    [[Seeds sharedInstance] recordEvent:key segmentation:nil count:count sum:0];
}

- (void)recordEvent:(NSString *)key count:(int)count sum:(double)sum
{
    [[Seeds sharedInstance] recordEvent:key segmentation:nil count:count sum:sum];
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count
{
    
    [[Seeds sharedInstance] recordEvent:key segmentation:segmentation count:count sum:0];
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum
{
    if (key == nil || key.length == 0) {
        // throw exception
        [NSException raise:@"A valid Seeds event ID is required" format:@"ID of %@ is invalid", key];
    }
    
    if (count < 1) {
        // throw exception
        [NSException raise:@"Seeds event count must be greater than zero" format:@"Count of %d is invalid", count];
    }
        
    [eventQueue recordEvent:key segmentation:segmentation count:count sum:sum];
    
    if (eventQueue.count >= SEEDS_EVENT_SEND_THRESHOLD)
        [[SeedsConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)recordUserDetails:(NSDictionary *)userDetails
{
    NSLog(@"%s",__FUNCTION__);
    [SeedsUserDetails.sharedUserDetails deserialize:userDetails];
    [SeedsConnectionQueue.sharedInstance sendUserDetails];
}

- (void)recordGenericIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId isSeedsEvent:(BOOL)isSeedsEvent
{
    NSMutableDictionary *segmentation = [[NSMutableDictionary alloc] init];

    if (isSeedsEvent) {
        [segmentation setObject:@"Seeds" forKey:@"IAP type"];
    } else {
        [segmentation setObject:@"Non-Seeds" forKey:@"IAP type"];
    }

    if (transactionId) {
        [segmentation setObject:transactionId forKey:@"transaction_id"];
    }
    
    [segmentation setObject:key forKey:@"item"];
    
    [self recordEvent:[@"IAP:" stringByAppendingString:key] segmentation:segmentation count:1 sum:price];
}

- (void)recordIAPEvent:(NSString *)key price:(double)price
{
    [self recordGenericIAPEvent:key price:price transactionId:nil isSeedsEvent:NO];
}

- (void)recordIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId
{
    [self recordGenericIAPEvent:key price:price transactionId:transactionId isSeedsEvent:NO];
}

- (void)recordSeedsIAPEvent:(NSString *)key price:(double)price
{
    [self recordGenericIAPEvent:key price:price transactionId:nil isSeedsEvent:YES];
}

- (void)recordSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId
{
    [self recordGenericIAPEvent:key price:price transactionId:transactionId isSeedsEvent:YES];
}

- (void)requestInAppMessage:(NSString*)messageId
{
    [[SeedsInterstitialAds sharedInstance] requestInAppMessage:messageId withManualLocalizedPrice:NULL];
}

- (void)requestInAppMessage:(NSString *)messageId withManualLocalizedPrice:(NSString*)price
{
    [[SeedsInterstitialAds sharedInstance] requestInAppMessage:messageId withManualLocalizedPrice:price];
}

- (BOOL)isInAppMessageLoaded:(NSString*)messageId
{
    return [[SeedsInterstitialAds sharedInstance] isInAppMessageLoaded:messageId];
}

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext;
{
    [[SeedsInterstitialAds sharedInstance] showInAppMessage:messageId in:viewController withContext:messageContext];
}

- (void)setLocation:(double)latitude longitude:(double)longitude
{
    SeedsConnectionQueue.sharedInstance.locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
}

- (void)requestInAppPurchaseCount:(SeedsInAppPurchaseCountCallback)callback of:(NSString*)key
{
    NSString* endpoint = [self.getAppHost stringByAppendingString:@"/o/app-user/query-iap-purchase-count"];
    NSString* parameters = [NSString stringWithFormat:@"app_key=%@&device_id=%@",
                            [self.getAppKey stringByUrlEncoding],
                            [self.deviceId stringByUrlEncoding]];
    if (key != nil) {
        parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"&iap_key=%@", [key stringByUrlEncoding]]];
    } else {
        endpoint = [endpoint stringByAppendingString:@"/total"];
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", endpoint, parameters]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod: @"GET"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                               NSError* error = nil;
                               NSDictionary* jsonReply = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:0
                                                                                           error:&error];
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               if (httpResponse.statusCode != 200 || !jsonReply || error) {
                                   SEEDS_LOG(@"requestInAppPurchaseCount error: %@", error);
                                   if (callback)
                                       callback(@"status code not 200 or JSON is invalid", -1);
                                   return;
                               }

                               if (callback)
                                   callback(nil, [[jsonReply valueForKey:@"result"] intValue]);
    }];
}

- (void)requestTotalInAppPurchaseCount:(SeedsInAppPurchaseCountCallback)callback
{
    [self requestInAppPurchaseCount:callback of:nil];
}

- (void)requestTotalInAppMessageShowCount:(SeedsInAppMessageShowCountCallback)callback
{
    [self requestInAppMessageShowCount:callback of:nil];
}

- (void)requestInAppMessageShowCount:(SeedsInAppMessageShowCountCallback)callback of:(NSString*)messageId
{
    NSString* endpoint = [self.getAppHost stringByAppendingString:@"/o/app-user/query-interstitial-shown-count"];
    NSString* parameters = [NSString stringWithFormat:@"app_key=%@&device_id=%@",
                            [self.getAppKey stringByUrlEncoding],
                            [self.deviceId stringByUrlEncoding]];
    if (messageId != nil) {
        parameters = [parameters stringByAppendingString:[NSString stringWithFormat:@"&interstitial_id=%@", [messageId stringByUrlEncoding]]];
    } else {
        endpoint = [endpoint stringByAppendingString:@"/total"];
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", endpoint, parameters]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod: @"GET"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                               NSError* error = nil;
                               NSDictionary* jsonReply = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:0
                                                                                           error:&error];

                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               if (httpResponse.statusCode != 200 || !jsonReply || error) {
                                   SEEDS_LOG(@"requestInAppMessageShowCount error: %@", error);

                                   if (callback)
                                       callback(@"status code not 200 or JSON is invalid", -1);

                                   return;
                               }

                               if (callback)
                                   callback(nil, [[jsonReply valueForKey:@"result"] intValue]);
                           }];
}

- (void)requestGenericUserBehaviorQuery:(SeedsGenericUserBehaviorQueryCallback)callback of:(NSString*)queryPath
{
    NSString* endpoint = [self.getAppHost stringByAppendingString:[@"/o/app-user/" stringByAppendingString: queryPath]];
    NSString* parameters = [NSString stringWithFormat:@"app_key=%@&device_id=%@",
                                                      [self.getAppKey stringByUrlEncoding],
                                                      [self.deviceId stringByUrlEncoding]];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", endpoint, parameters]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod: @"GET"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                               NSError* error = nil;
                               NSDictionary* jsonReply = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:0
                                                                                           error:&error];

                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               if (httpResponse.statusCode != 200 || !jsonReply || error) {
                                   SEEDS_LOG(@"requestGenericUserBehaviorQuery error: %@", error);

                                   if (callback)
                                       callback(@"status code not 200 or JSON is invalid", nil);

                                   return;
                               }

                               if (callback)
                                   callback(nil, [jsonReply valueForKey:@"result"]);
                           }];
}

- (void)onTimer:(NSTimer *)timer
{
    if (isSuspended == YES)
        return;
    
    double currTime = CFAbsoluteTimeGetCurrent();
    unsentSessionLength += currTime - lastTime;
    lastTime = currTime;
    
    int duration = unsentSessionLength;
    [[SeedsConnectionQueue sharedInstance] updateSessionWithDuration:duration];
    unsentSessionLength -= duration;
    
    if (eventQueue.count > 0)
        [[SeedsConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
}

- (void)suspend
{
    isSuspended = YES;
    
    if (eventQueue.count > 0)
        [[SeedsConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
    
    double currTime = CFAbsoluteTimeGetCurrent();
    unsentSessionLength += currTime - lastTime;
    
    int duration = unsentSessionLength;
    [[SeedsConnectionQueue sharedInstance] endSessionWithDuration:duration];
    unsentSessionLength -= duration;
}

- (void)resume
{
    lastTime = CFAbsoluteTimeGetCurrent();
    
    [[SeedsConnectionQueue sharedInstance] beginSession];
    
    isSuspended = NO;
}

- (void)exit
{
}

- (void)dealloc
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void)didEnterBackgroundCallBack:(NSNotification *)notification
{
    SEEDS_LOG(@"App didEnterBackground");
    [self suspend];
}

- (void)willEnterForegroundCallBack:(NSNotification *)notification
{
    SEEDS_LOG(@"App willEnterForeground");
    [self resume];
}

- (void)willTerminateCallBack:(NSNotification *)notification
{
    SEEDS_LOG(@"App willTerminate");
    [[SeedsDB sharedInstance] saveContext];
    [self exit];
}


#pragma mark - Seeds Messaging
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)

#define kPushToMessage      1
#define kPushToOpenLink     2
#define kPushToUpdate       3
#define kPushToReview       4
#define kPushEventKeyOpen   @"[CLY]_push_open"
#define kPushEventKeyAction @"[CLY]_push_action"
#define kAppIdPropertyKey   @"[CLY]_app_id"
#define kCountlyAppId       @"695261996"

- (BOOL) handleRemoteNotification:(NSDictionary *)info withButtonTitles:(NSArray *)titles {
    return [self handleRemoteNotification:info displayingMessage:YES withButtonTitles:titles];
}

- (BOOL) handleRemoteNotification:(NSDictionary *)info {
    return [self handleRemoteNotification:info displayingMessage:YES];
}

- (BOOL) handleRemoteNotification:(NSDictionary *)info displayingMessage:(BOOL)displayMessage {
    return [self handleRemoteNotification:info displayingMessage:displayMessage
                         withButtonTitles:@[@"Cancel", @"Open", @"Update", @"Review"]];
}

- (BOOL) handleRemoteNotification:(NSDictionary *)info displayingMessage:(BOOL)displayMessage withButtonTitles:(NSArray *)titles {
    SEEDS_LOG(@"Handling remote notification (display? %d): %@", displayMessage, info);
    
    NSDictionary *aps = info[@"aps"];
    NSDictionary *countly = info[@"c"];
    
    if (countly[@"i"]) {
        SEEDS_LOG(@"Message id: %@", countly[@"i"]);
        
        [self recordPushOpenForSeedsDictionary:countly];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        NSString *message = [aps objectForKey:@"alert"];
        
        int type = 0;
        NSString *action = nil;
        
        if ([aps objectForKey:@"content-available"]) {
            return NO;
        } else if (countly[@"l"]) {
            type = kPushToOpenLink;
            action = titles[1];
        } else if (countly[@"r"] != nil) {
            type = kPushToReview;
            action = titles[3];
        } else if (countly[@"u"] != nil) {
            type = kPushToUpdate;
            action = titles[2];
        } else if (displayMessage) {
            type = kPushToMessage;
            action = nil;
        }
        
        if (type && [message length]) {
            UIAlertView *alert;
            if (action) {
                alert = [[UIAlertView alloc] initWithTitle:appName message:message delegate:self
                                         cancelButtonTitle:titles[0] otherButtonTitles:action, nil];
            } else {
                alert = [[UIAlertView alloc] initWithTitle:appName message:message delegate:self
                                         cancelButtonTitle:titles[0] otherButtonTitles:nil];
            }
            alert.tag = type;
            
            _messageInfos[alert.description] = info;
            
            [alert show];
            return YES;
        }
    }
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *info = [_messageInfos[alertView.description] copy];
    [_messageInfos removeObjectForKey:alertView.description];
    
    if (alertView.tag == kPushToMessage) {
        // do nothing
    } else if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == kPushToOpenLink) {
            [self recordPushActionForSeedsDictionary:info[@"c"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:info[@"c"][@"l"]]];
        } else if (alertView.tag == kPushToUpdate) {
            if ([info[@"c"][@"u"] length]) {
                [self openUpdate:info[@"c"][@"u"] forInfo:info];
            } else {
                [self withAppStoreId:^(NSString *appStoreId) {
                    [self openUpdate:appStoreId forInfo:info];
                }];
            }
        } else if (alertView.tag == kPushToReview) {
            if ([info[@"c"][@"r"] length]) {
                [self openReview:info[@"c"][@"r"] forInfo:info];
            } else {
                [self withAppStoreId:^(NSString *appStoreId) {
                    [self openReview:appStoreId forInfo:info];
                }];
            }
        }
    }
}

- (void) withAppStoreId:(void (^)(NSString *))block{
    NSString *appStoreId = [[NSUserDefaults standardUserDefaults] stringForKey:kAppIdPropertyKey];
    if (appStoreId) {
        block(appStoreId);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *appStoreId = nil;
            NSString *bundle = [SeedsDeviceInfo bundleId];
            NSString *appStoreCountry = [(NSLocale *)[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
            if ([appStoreCountry isEqualToString:@"150"]) {
                appStoreCountry = @"eu";
            } else if ([[appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length]) {
                appStoreCountry = @"us";
            }
            
            NSString *iTunesServiceURL = [NSString stringWithFormat:@"http://itunes.apple.com/%@/lookup", appStoreCountry];
            iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?bundleId=%@", bundle];
            
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iTunesServiceURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (data && statusCode == 200) {
                
                id json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
                
                if (!error && [json isKindOfClass:[NSDictionary class]]) {
                    NSString *bundleID = json[@"bundleId"];
                    if (bundleID && [bundleID isEqualToString:bundle]) {
                        appStoreId = [json[@"trackId"] stringValue];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setObject:appStoreId forKey:kAppIdPropertyKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                block(appStoreId);
            });
        });
    }
    
}

- (void) openUpdate:(NSString *)appId forInfo:(NSDictionary *)info {
    if (!appId) appId = kCountlyAppId;
    
    NSString *urlFormat = nil;
#if TARGET_OS_IPHONE
    urlFormat = @"itms-apps://itunes.apple.com/app/id%@";
#else
    urlFormat = @"macappstore://itunes.apple.com/app/id%@";
#endif
    
    [self recordPushActionForSeedsDictionary:info[@"c"]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, appId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) openReview:(NSString *)appId forInfo:(NSDictionary *)info{
    if (!appId) appId = kCountlyAppId;
    
    NSString *urlFormat = nil;
#if TARGET_OS_IPHONE
    float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iOSVersion >= 7.0f && iOSVersion < 7.1f) {
        urlFormat = @"itms-apps://itunes.apple.com/app/id%@";
    } else {
        urlFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
#else
    urlFormat = @"macappstore://itunes.apple.com/app/id%@";
#endif
    
    [self recordPushActionForSeedsDictionary:info[@"c"]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, appId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)recordPushOpenForSeedsDictionary:(NSDictionary *)c {
    [self recordEvent:kPushEventKeyOpen segmentation:@{@"i": c[@"i"]} count:1];
}

- (void)recordPushActionForSeedsDictionary:(NSDictionary *)c {
    [self recordEvent:kPushEventKeyAction segmentation:@{@"i": c[@"i"]} count:1];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                       ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                       ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                       ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [[SeedsConnectionQueue sharedInstance] tokenSession:token];
}

- (void)didFailToRegisterForRemoteNotifications {
    [[SeedsConnectionQueue sharedInstance] tokenSession:nil];
}
#endif


#pragma mark - Seeds CrashReporting
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)

#define kSeedsCrashUserInfoKey @"[SDS]_stack_trace"

- (void)startCrashReporting
{
    NSSetUncaughtExceptionHandler(&SeedsUncaughtExceptionHandler);
    signal(SIGABRT, SeedsSignalHandler);
    signal(SIGILL, SeedsSignalHandler);
    signal(SIGSEGV, SeedsSignalHandler);
    signal(SIGFPE, SeedsSignalHandler);
    signal(SIGBUS, SeedsSignalHandler);
    signal(SIGPIPE, SeedsSignalHandler);
}

- (void)startCrashReportingWithSegments:(NSDictionary *)segments
{
    crashCustom = segments;
    [self startCrashReporting];
}

- (void)recordHandledException:(NSException *)exception
{
    SeedsExceptionHandler(exception, true);
}

- (void)crashTest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(thisIsTheUnrecognizedSelectorCausingTheCrash)];
#pragma clang diagnostic pop
}

- (void)crashTest2
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSArray* anArray = @[@"one",@"two",@"three"];
#pragma clang diagnostic pop
}

- (void)crashTest3
{
    int *nullPointer = NULL;
    *nullPointer = 2015;
}

- (void)crashTest4
{
    CGRect aRect = (CGRect){0.0/0.0, 0.0, 100.0, 100.0};
    UIView *crashView = UIView.new;
    crashView.frame = aRect;
}

void SeedsUncaughtExceptionHandler(NSException *exception)
{
    SeedsExceptionHandler(exception, false);
}

void SeedsExceptionHandler(NSException *exception, bool nonfatal)
{
    NSMutableDictionary* crashReport = NSMutableDictionary.dictionary;
    
    crashReport[@"_os"] = SeedsDeviceInfo.osName;
    crashReport[@"_os_version"] = SeedsDeviceInfo.osVersion;
    crashReport[@"_device"] = SeedsDeviceInfo.device;
    crashReport[@"_resolution"] = SeedsDeviceInfo.resolution;
    crashReport[@"_app_version"] = SeedsDeviceInfo.appVersion;
    crashReport[@"_name"] = exception.debugDescription;
    crashReport[@"_nonfatal"] = @(nonfatal);
    
    
    crashReport[@"_ram_current"] = @((Seeds.sharedInstance.totalRAM-Seeds.sharedInstance.freeRAM)/1048576);
    crashReport[@"_ram_total"] = @(Seeds.sharedInstance.totalRAM/1048576);
    crashReport[@"_disk_current"] = @((Seeds.sharedInstance.totalDisk-Seeds.sharedInstance.freeDisk)/1048576);
    crashReport[@"_disk_total"] = @(Seeds.sharedInstance.totalDisk/1048576);
    
    
    crashReport[@"_bat"] = @(Seeds.sharedInstance.batteryLevel);
    crashReport[@"_orientation"] = Seeds.sharedInstance.orientation;
    crashReport[@"_online"] = @((Seeds.sharedInstance.connectionType)? 1 : 0 );
    crashReport[@"_opengl"] = @(Seeds.sharedInstance.OpenGLESversion);
    crashReport[@"_root"] = @(Seeds.sharedInstance.isJailbroken);
    crashReport[@"_background"] = @(Seeds.sharedInstance.isInBackground);
    crashReport[@"_run"] = @(Seeds.sharedInstance.timeSinceLaunch);
    
    if(Seeds.sharedInstance->crashCustom)
        crashReport[@"_custom"] = Seeds.sharedInstance->crashCustom;
    
    if(SeedsCustomCrashLogs)
        crashReport[@"_logs"] = [SeedsCustomCrashLogs componentsJoinedByString:@"\n"];
    
    NSArray* stackArray = exception.userInfo[kSeedsCrashUserInfoKey];
    if(!stackArray) stackArray = exception.callStackSymbols;
    
    NSMutableString* stackString = NSMutableString.string;
    for (NSString* line in stackArray)
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+\\s" options:0 error:nil];
        NSString *cleanLine = [regex stringByReplacingMatchesInString:line options:0 range:(NSRange){0,line.length} withTemplate:@"  "];
        [stackString appendString:cleanLine];
        [stackString appendString:@"\n"];
    }
    
    crashReport[@"_error"] = stackString;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/i", SeedsConnectionQueue.sharedInstance.appHost];
    
    NSString *queryString = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&crash=%@",
                             SeedsConnectionQueue.sharedInstance.appKey,
                             Seeds.sharedInstance.deviceId,
                             time(NULL),
                             SeedsURLEscapedString(SeedsJSONFromObject(crashReport))];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    SEEDS_LOG(@"CrashReporting URL: %@", urlString);
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* recvData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error || !recvData)
    {
        SEEDS_LOG(@"CrashReporting failed, report stored to try again later");
        [SeedsConnectionQueue.sharedInstance storeCrashReportToTryLater:SeedsURLEscapedString(SeedsJSONFromObject(crashReport))];
    }
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

void SeedsSignalHandler(int signalCode)
{
    void* callstack[128];
    NSInteger frames = backtrace(callstack, 128);
    char **lines = backtrace_symbols(callstack, (int)frames);
    
    const NSInteger startOffset = 1;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (NSInteger i = startOffset; i < frames; i++)
        [backtrace addObject:[NSString stringWithUTF8String:lines[i]]];
    
    free(lines);
    
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithObject:@(signalCode) forKey:@"signal_code"];
    [userInfo setObject:backtrace forKey:kSeedsCrashUserInfoKey];
    NSString *reason = [NSString stringWithFormat:@"App terminated by SIG%@",[NSString stringWithUTF8String:sys_signame[signalCode]].uppercaseString];
    
    NSException *e = [NSException exceptionWithName:@"Fatal Signal" reason:reason userInfo:userInfo];
    
    SeedsUncaughtExceptionHandler(e);
}

static NSMutableArray *SeedsCustomCrashLogs = nil;

void SCL(const char* function, NSUInteger line, NSString* message)
{
    static NSDateFormatter* df = nil;
    
    if( SeedsCustomCrashLogs == nil )
    {
        SeedsCustomCrashLogs = NSMutableArray.new;
        df = NSDateFormatter.new;
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    
    NSString* f = [[NSString.alloc initWithUTF8String:function] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-[]"]];
    NSString* log = [NSString stringWithFormat:@"[%@] <%@ %li> %@",[df stringFromDate:NSDate.date],f,(unsigned long)line,message];
    [SeedsCustomCrashLogs addObject:log];
}

- (unsigned long long)freeRAM
{
    vm_statistics_data_t vms;
    mach_msg_type_number_t ic = HOST_VM_INFO_COUNT;
    kern_return_t kr = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vms, &ic);
    if(kr != KERN_SUCCESS)
        return -1;
    
    return vm_page_size * (vms.free_count);
}

- (unsigned long long)totalRAM
{
    return NSProcessInfo.processInfo.physicalMemory;
}

- (unsigned long long)freeDisk
{
    return [[NSFileManager.defaultManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil][NSFileSystemFreeSize] longLongValue];
}

- (unsigned long long)totalDisk
{
    return [[NSFileManager.defaultManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil][NSFileSystemSize] longLongValue];
}

- (NSInteger)batteryLevel
{
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    return abs((int)(UIDevice.currentDevice.batteryLevel*100));
}

- (NSString*)orientation
{
    NSArray *orientations = @[@"Unknown", @"Portrait", @"PortraitUpsideDown", @"LandscapeLeft", @"LandscapeRight", @"FaceUp", @"FaceDown"];
    return orientations[UIDevice.currentDevice.orientation];
}

- (NSUInteger)connectionType
{
    typedef enum:NSInteger {CLYConnectionNone, CLYConnectionCellNetwork, CLYConnectionWiFi} CLYConnectionType;
    CLYConnectionType connType = CLYConnectionNone;
    
    @try
    {
        struct ifaddrs *interfaces, *i;
        
        if (!getifaddrs(&interfaces))
        {
            i = interfaces;
            
            while(i != NULL)
            {
                if(i->ifa_addr->sa_family == AF_INET)
                {
                    if([[NSString stringWithUTF8String:i->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        connType = CLYConnectionCellNetwork;
                    }
                    else if([[NSString stringWithUTF8String:i->ifa_name] isEqualToString:@"en0"])
                    {
                        connType = CLYConnectionWiFi;
                        break;
                    }
                }
                
                i = i->ifa_next;
            }
        }
        
        freeifaddrs(interfaces);
    }
    @catch (NSException *exception)
    {
        
    }
    
    return connType;
}

- (float)OpenGLESversion
{
    EAGLContext *aContext;
    
    aContext = [EAGLContext.alloc initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(aContext)
        return 3.0;
    
    aContext = [EAGLContext.alloc initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(aContext)
        return 2.0;
    
    return 1.0;
}

- (long)timeSinceLaunch
{
    return time(NULL)-startTime;
}

- (BOOL)isJailbroken
{
    FILE *f = fopen("/bin/bash", "r");
    BOOL isJailbroken = (f != NULL);
    fclose(f);
    return isJailbroken;
}

- (BOOL)isInBackground
{
    return UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
}

#endif

#pragma mark - Seeds Background Fetch Session Ending
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)

- (void)endBackgroundSessionWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    if (eventQueue.count > 0)
    {
        NSString *eventsQueryString = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&events=%@",
                                       SeedsConnectionQueue.sharedInstance.appKey,
                                       self.deviceId,
                                       time(NULL),
                                       [eventQueue events]];
        
        [SeedsDB.sharedInstance addToQueue:eventsQueryString];
    }
    
    double currTime = CFAbsoluteTimeGetCurrent();
    unsentSessionLength += currTime - lastTime;
    int duration = unsentSessionLength;
    
    NSString *endSessionQueryString = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&end_session=1&session_duration=%d",
                                       SeedsConnectionQueue.sharedInstance.appKey,
                                       self.deviceId,
                                       time(NULL),
                                       duration];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/i?%@", SeedsConnectionQueue.sharedInstance.appHost, endSessionQueryString];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if(connectionError)
         {
             completionHandler(UIBackgroundFetchResultFailed);
         }
         else
         {
             SEEDS_LOG(@"Background session end successful");
             unsentSessionLength -= duration;
             completionHandler(UIBackgroundFetchResultNewData);
         }
     }];
}
#endif



@end
