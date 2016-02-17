//
//  AppDelegate.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "AppDelegate.h"
#import "Seeds.h"

//#define YOUR_SERVER @"https://dash.playseeds.com"
#define YOUR_SERVER @"http://devdash.playseeds.com"
#define YOUR_APP_KEY @"aa1fd1f255b25fb89b413f216f11e8719188129d"

//development server info
//#define YOUR_SERVER @"https://devdash.playseeds.com"
//#define YOUR_APP_KEY_NEVER @"ef2444ec9f590d24db5054fad8385991138a394b"
//#define YOUR_APP_KEY_ALWAYS @"c30f02a55541cbe362449d29d83d777c125c8dd6"
//#define YOUR_APP_KEY YOUR_APP_KEY_ALWAYS

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Seeds.sharedInstance start:YOUR_APP_KEY withHost:YOUR_SERVER];

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
