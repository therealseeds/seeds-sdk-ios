//
//  AppDelegate.h
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import <UIKit/UIKit.h>

//#define YOUR_SERVER @"https://dash.playseeds.com"
//#define YOUR_APP_KEY @"4e3bf7164b3799c9800fef2d4d1d6df68acf6c83"
//#define MESSAGE_ID_0 nil
//#define MESSAGE_ID_1 nil

#define YOUR_SERVER @"https://dash.playseeds.com"
#define YOUR_APP_KEY @"2db64b49085be463cade71ce22e6341d7f6bd901"
#define APP_LAUNCH_INTERSTITIAL_ID @"57e362bead5957420e12083f"
#define PURCHASE_INTERSTITIAL_ID @"57e36337ad5957420e120842"
#define SHARING_INTERSTITIAL_ID @"57e36365ad5957420e120845"
#define SEEDS_IAP_EVENT_KEY @"TestSeedsPurchase"
#define NORMAL_IAP_EVENT_KEY @"TestNormalPurchase"

//development server info
//#define YOUR_SERVER @"https://devdash.playseeds.com"
//#define YOUR_APP_KEY_NEVER @"ef2444ec9f590d24db5054fad8385991138a394b"
//#define YOUR_APP_KEY_ALWAYS @"c30f02a55541cbe362449d29d83d777c125c8dd6"
//#define YOUR_APP_KEY YOUR_APP_KEY_ALWAYS

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

