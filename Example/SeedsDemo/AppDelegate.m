//
//  AppDelegate.m
//  SeedsDemo
//
//  Created by Igor Dorofix on 6/30/17.
//

#import "AppDelegate.h"
#import <SeedsSDK/Seeds.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Seeds initWithAppKey:YOUR_APP_KEY];
    
    [[Seeds interstitials] fetchWithId:APP_LAUNCH_INTERSTITIAL_ID manualPrice:nil];
    [[Seeds interstitials] fetchWithId:PURCHASE_INTERSTITIAL_ID manualPrice:nil];
    [[Seeds interstitials] fetchWithId:SHARING_INTERSTITIAL_ID manualPrice:nil];
    
    return YES;
}

@end
