//
//  AppDelegate.h
//  SeedsDemo
//
//  Created by Igor Dorofix on 6/30/17.
//

#import <UIKit/UIKit.h>

#define YOUR_SERVER @"https://dash.playseeds.com"
#define YOUR_APP_KEY @"2db64b49085be463cade71ce22e6341d7f6bd901"
#define APP_LAUNCH_INTERSTITIAL_ID @"app-launch"
#define PURCHASE_INTERSTITIAL_ID @"purchase"
#define SHARING_INTERSTITIAL_ID @"social-sharing"
#define SEEDS_IAP_EVENT_KEY @"TestSeedsPurchase"
#define NORMAL_IAP_EVENT_KEY @"TestNormalPurchase"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

