//
//  SeedsConnectionQueue.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#   define SEEDS_LOG(...)
#define COUNTLY_SDK_VERSION "15.06.01"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SeedsConnectionQueue.h"
#import "SeedsUserDetails.h"
#import "SeedsDB.h"
#import "SeedsUrlFormatter.h"
#import "SeedsDeviceInfo.h"
#import "Seeds.h"
#import "Seeds_Private.h"

@implementation SeedsConnectionQueue : NSObject

+ (instancetype)sharedInstance
{
    static SeedsConnectionQueue *s_sharedSeedsConnectionQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{s_sharedSeedsConnectionQueue = self.new;});
    return s_sharedSeedsConnectionQueue;
}

- (void) tick
{
    NSArray* dataQueue = [[[SeedsDB sharedInstance] getQueue] copy];
    
    if (self.connection != nil || [dataQueue count] == 0)
        return;
    
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
    if (self.bgTask != UIBackgroundTaskInvalid)
        return;
    
    UIApplication *app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
#endif
    
    NSString *data = [dataQueue[0] valueForKey:@"post"];
    NSString *urlString = [NSString stringWithFormat:@"%@/i?%@", self.appHost, data];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    if([data rangeOfString:@"&crash="].location != NSNotFound)
    {
        urlString = [NSString stringWithFormat:@"%@/i", self.appHost];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    }
    
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
    NSString* picturePath = [SeedsUserDetails.sharedUserDetails extractPicturePathFromURLString:urlString];
    if(picturePath && ![picturePath isEqualToString:@""])
    {
        SEEDS_LOG(@"picturePath: %@", picturePath);
        
        NSArray* allowedFileTypes = @[@"gif",@"png",@"jpg",@"jpeg"];
        NSString* fileExt = picturePath.pathExtension.lowercaseString;
        NSInteger fileExtIndex = [allowedFileTypes indexOfObject:fileExt];
        
        if(fileExtIndex != NSNotFound)
        {
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturePath]];
            if (fileExtIndex == 1) imageData = UIImagePNGRepresentation([UIImage imageWithData:imageData]); //NOTE: for png upload fix. (png file data read directly from disk fails on upload)
            if (fileExtIndex == 2) fileExtIndex = 3; //NOTE: for mime type jpg -> jpeg
            
            if (imageData)
            {
                SEEDS_LOG(@"local image retrieved from picturePath");
                
                NSString *boundary = @"c1c673d52fea01a50318d915b6966d5e";
                
                [request setHTTPMethod:@"POST"];
                NSString *contentType = [@"multipart/form-data; boundary=" stringByAppendingString:boundary];
                [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                
                NSMutableData *body = NSMutableData.data;
                [body appendStringUTF8:[NSString stringWithFormat:@"--%@\r\n", boundary]];
                [body appendStringUTF8:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pictureFile\"; filename=\"%@\"\r\n",picturePath.lastPathComponent]];
                [body appendStringUTF8:[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n", allowedFileTypes[fileExtIndex]]];
                [body appendData:imageData];
                [body appendStringUTF8:[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary]];
                [request setHTTPBody:body];
            }
        }
    }
#endif
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    SEEDS_LOG(@"Request Started \n %@", urlString);
}

- (void)beginSession
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&sdk_version="COUNTLY_SDK_VERSION"&begin_session=1&metrics=%@",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      [SeedsDeviceInfo metrics]];
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)tokenSession:(NSString *)token
{
    // Test modes: 0 = production mode, 1 = development build, 2 = Ad Hoc build
    int testMode;
#ifndef __OPTIMIZE__
    testMode = 1;
#else
    testMode = self.startedWithTest ? 2 : 0;
#endif
    
    SEEDS_LOG(@"Sending APN token in mode %d", testMode);
    
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&sdk_version="COUNTLY_SDK_VERSION"&token_session=1&ios_token=%@&test_mode=%d",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      [token length] ? token : @"",
                      testMode];
    
    // Not right now to prevent race with begin_session=1 when adding new user
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SeedsDB sharedInstance] addToQueue:data];
        [self tick];
    });
}

- (void)updateSessionWithDuration:(int)duration
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&session_duration=%d",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      duration];
    
    if (self.locationString)
    {
        data = [data stringByAppendingFormat:@"&location=%@",self.locationString];
        self.locationString = nil;
    }
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)endSessionWithDuration:(int)duration
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&end_session=1&session_duration=%d",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      duration];
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)sendUserDetails
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&sdk_version="COUNTLY_SDK_VERSION"&user_details=%@",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      [[SeedsUserDetails sharedUserDetails] serialize]];
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)storeCrashReportToTryLater:(NSString *)report
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&sdk_version="COUNTLY_SDK_VERSION"&crash=%@",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      report];
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)recordEvents:(NSString *)events
{
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&events=%@",
                      self.appKey,
                      Seeds.sharedInstance.deviceId,
                      time(NULL),
                      events];
    
    [[SeedsDB sharedInstance] addToQueue:data];
    
    [self tick];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSArray* dataQueue = [[[SeedsDB sharedInstance] getQueue] copy];
    
    SEEDS_LOG(@"Request Completed\n");
    
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
    UIApplication *app = [UIApplication sharedApplication];
    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
#endif
    
    self.connection = nil;
    
    [[SeedsDB sharedInstance] removeFromQueue:dataQueue[0]];
    
    [self tick];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)err
{
#if SEEDS_DEBUG
    NSArray* dataQueue = [[[SeedsDB sharedInstance] getQueue] copy];
    SEEDS_LOG(@"Request Failed \n %@: %@", [dataQueue[0] description], [err description]);
#endif
    
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
    UIApplication *app = [UIApplication sharedApplication];
    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
#endif
    
    self.connection = nil;
}

#if SEEDS_IGNORE_INVALID_CERTIFICATES
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}
#endif

- (void)dealloc
{
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
    }
    self.appKey = nil;
    self.appHost = nil;
}

@end

