//
//  AppDelegate.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "AppDelegate.h"
#import "Seeds.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Seeds initWithAppKey:YOUR_APP_KEY];
    
    [[Seeds interstitials] fetchWithId:APP_LAUNCH_INTERSTITIAL_ID manualPrice:nil];
    [[Seeds interstitials] fetchWithId:PURCHASE_INTERSTITIAL_ID manualPrice:nil];
    [[Seeds interstitials] fetchWithId:SHARING_INTERSTITIAL_ID manualPrice:nil];

    return YES;
}

@end
