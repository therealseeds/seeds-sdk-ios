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

#define YOUR_SERVER @"http://staging.playseeds.com"
#define YOUR_APP_KEY @"71ac2900e9d31647d68d0ddc6f0aaf52611a612d"
#define MESSAGE_ID_0 @"575f872a64bc1e5b0eca506f"
#define MESSAGE_ID_1 @"5746851bb29ee753053a7c9a"

//development server info
//#define YOUR_SERVER @"https://devdash.playseeds.com"
//#define YOUR_APP_KEY_NEVER @"ef2444ec9f590d24db5054fad8385991138a394b"
//#define YOUR_APP_KEY_ALWAYS @"c30f02a55541cbe362449d29d83d777c125c8dd6"
//#define YOUR_APP_KEY YOUR_APP_KEY_ALWAYS

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

