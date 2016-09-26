//
//  AppDelegate.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Seeds.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Seeds.sharedInstance start:YOUR_APP_KEY withHost:YOUR_SERVER];

    // Preload all interstitials at once
    [Seeds.sharedInstance requestInAppMessage: PURCHASE_INTERSTITIAL_ID];
    [Seeds.sharedInstance requestInAppMessage: SHARING_INTERSTITIAL_ID];
    [Seeds.sharedInstance requestInAppMessage: APP_LAUNCH_INTERSTITIAL_ID];

    // Override point for customization after application launch.
    return YES;
}

@end
