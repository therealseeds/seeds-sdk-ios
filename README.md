# Seeds iOS SDK

Increase your revenue (and so much more) with the power of social good by integrating Seeds into your app!   If you have any questions regarding your specific setup, feel free to contact our team through the [website](http://www.playseeds.com/#social-good) chat.

We’re so happy you’re here!

## The following platforms are now available:

- [Unity SDK](https://github.com/therealseeds/seeds-sdk-unity)
- [Android](https://github.com/therealseeds/seeds-sdk-android)

## Pull requests welcome

We're built on open source and welcome bug fixes and other contributions.

## Pre-integration checklist

Before beginning the integration, please take care of all of the below:

- Create a Seeds account [here](http://www.playseeds.com/) if you haven't already done so
- The [Dashboard](https://developers.playseeds.com/index.html) tab shows a list of your apps and the campaigns they contain. You can start with the default example-campaign, and we’ll add your final campaigns automatically.
- Familiarize yourself with the [iOS Example Integration](https://github.com/therealseeds/seeds-sdk-ios/tree/master/Example), which shows a complete Seeds integration in action.  It’s good to have on hand as a reference if needed.

## Installation

We recommend using CocoaPods to add the Seeds SDK to your app because it makes it easy to update the Seeds SDK in the future. Please add the following to the Podfile in your project root directory:

```
target '<Target_Name>' do
    ...   
    pod 'SeedsSDK'
end
```

## Usage

The Seeds SDK functionality is divided into two parts: [Interstitials](#interstitials_header) that represent all functionality that is connected to the content Seeds shows in-app, and [Events](#events_header) that represent logging analytics data.

## Initialization

Seeds will be initialized only once, when your app is first loaded. You will find App Keys for both the Test Environment and the Production Environment in your [Dashboard](https://developers.playseeds.com/index.html) tab. Please use these when initializing the Seeds SDK.

```objective-c
#import <SeedsSDK/Seeds.h>
....

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...
  [Seeds initWithAppKey:YOUR_APP_KEY];
  ...
}
```

The earlier the Seeds SDK is initialized, the better, as this helps us track accurate user session length.  This in turn allows us to better target users based on their specific behavior, so that we can deliver you the greatest revenue uptick possible. :)

## <a name="interstitials_header"></a> Interstitials

### General rules:

- InterstitialId is the id of the interstitial (naturally :)).  It can be found in your [Dashboard](https://developers.playseeds.com/index.html) under the Campaign Name section.
- Context is the description of the place in your app at which you are showing the Seeds interstitial.  Please use short but understandable descriptions (e.g. “level_1", “pause”, “app_start”).

### 1) Pre-load the interstitial:

Please note that every interstitial must be pre-loaded before you attempt to show it. We suggest pre-loading all the interstitials in the app startup:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...
  [Seeds initWithAppKey:YOUR_APP_KEY];
  
  [[Seeds interstitials] fetchWithId:@"PURCHASE_INTERSTITIAL_ID"];
  [[Seeds interstitials] fetchWithId:@"PURCHASE_INTERSTITIAL_ID_2"];
  [[Seeds interstitials] fetchWithId:@"PURCHASE_INTERSTITIAL_ID_3"];
  ...
}
```

### 2) Set the interstitials event handler:

To receive callbacks about events (e.g. notifications about clicks, dismissals, errors, and loading), please set the interstitials event handler to receive callback from the SDK. Choose the class you’d like to use for handling those events, and implement [SeedsInterstitialsEventProtocol](#interstitialseventprotocol_header) methods:

```objective-c
#import <SeedsSDK/Seeds.h>

@interface ViewController () <SeedsInterstitialsEventProtocol>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Seeds interstitials] setEventsHandler:self];
}

- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial {
	//Called when the interstitial was loaded
}

- (void)interstitialDidClick:(SeedsInterstitial *)interstitial {
	//Called when the interstitial "buy" button was clicked
}

- (void)interstitialDidShow:(SeedsInterstitial *)interstitial {
	//Called when the interstitial was successfully shown
}

- (void)interstitialDidClose:(SeedsInterstitial *)interstitial {
	//Called when the user presses "close" or "back" button
}

- (void)interstitial:(NSString *)interstitialId error:(NSError *)error {
	//Called when error occurs
}
```

### 3) Show the Interstitial

- First сheck to see if the interstitial has already loaded.
- If the interstitial is loaded - show it!  Sample usage:

```objective-c
@interface ViewController ()
@end

@implementation ViewController

- (void)showInterstitial {
    if ([[Seeds interstitials] isLoadedWithId:YOUR_INTERSTITIAL_ID]) {
        [[Seeds interstitials] showWithId:YOUR_INTERSTITIAL_ID onViewController:self inContext:context];
    }
}

...
```

### <a name="interstitialseventprotocol_header"></a> SeedsInterstitialsEventProtocol

The protocol contains five methods for addressing different scenarios of a Seeds interstitial events.

```objective-c
- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial; //Called when the interstitial was loaded
- (void)interstitialDidClick:(SeedsInterstitial *)interstitial; //Called when the interstitial "buy" button was clicked
- (void)interstitialDidShow:(SeedsInterstitial *)interstitial; //Called when the interstitial was successfully shown
- (void)interstitialDidClose:(SeedsInterstitial *)interstitial; //Called when the user presses "close" or "back" button
- (void)interstitial:(NSString *)interstitialId error:(NSError *)error; //Called when error occurs
```

## <a name="events_header"></a> Events

An event is the generalized mechanism for tracking all user actions taken in-app. [Seeds events] use two approaches for logging data: direct logging for purchases made, and an object-based approach for tracking all other data.  Please use logSeedsIAPEvent or logIAPEvent after any successful purchase, and logUserInfo with the provided wrapper to empower Seeds to make the targeted recommendations that will best convert your non-payers into paying customers. You can also log your app’s custom data with logEventWithKey.

### After a successful in-app purchase:

This method should be called after any successful purchase in the app.  Depending on whether a completed purchases was either a Seeds purchase or a non-Seeds purchase, please notify the SDK in one of the two following ways:

```objective-c
- (void)someMethod {
	...
	//Successful purchase was made above
 	[[Seeds events] logSeedsIAPEvent:PRODUCT_ID price:YOUR_PURCHASE_PRICE transactionId:YOUR_TRANSACTION_ID]; 
 	//If there was a Seeds in-app purchase
 	[[Seeds events] logIAPEvent:PRODUCT_ID price:YOUR_PURCHASE_PRICE transactionId:YOUR_TRANSACTION_ID]; 
 	//If there was non-Seeds in-app purchase
}
```

### After generating user data:

To specify userInfo data, please use following keys. This allows Seeds to show your users the opportunities to contribute to social good that they will love most, optimizing your non-payer to payer conversion - and therefore your revenue.

```objective-c
kSeedEventUserName
kSeedEventUserUsername
kSeedEventUserEmail
kSeedEventUserOrganization
kSeedEventUserPhone
kSeedEventUserGender
kSeedEventUserPicture
kSeedEventUserPicturePath
kSeedEventUserBirthYear
kSeedEventUserCustom
```

Sample usage:

```objective-c
- (void)someMethod {
	...
	[[Seeds events] logUserInfo:@{kSeedEventUserName: @"Uncle Sam",
                                  kSeedEventUserPhone: @"+14561234545"}];
}
```

### Switch to the Production Environment App Key

Before publishing your app update, please switch from using the Test Environment App Key to the Production Environment App Key.  If needed, you can find both keys in your [Dashboard](https://developers.playseeds.com/index.html).

### Optional: Add Seeds branding to your in-app store

In addition to boosting your revenue using the Seeds interstitials, you can increase profits by adding the Seeds logo to the appropriate in-app purchase items within your marketplace.  If you’d like to try this, please contact us via the [website](http://www.playseeds.com/#social-good) chat. We’re more than happy to help!

### Add Your Social Good Transfer Information

Visit [this link](https://developers.playseeds.com/) and click on the Social Good Transfer tab on the left menu to input the credit card information for your future social good transfers!

### Finally, Submit Your App Update to the Store!

Now you’re all set to make as much as 30% more money while simultaneously helping folks in need around the world.  You are amazing!  Thank you!

## Solutions to common integration problems

### Why is my app crashing after initializing Seeds?

All Seeds methods must be run in the main thread.  If your app is crashing, please confirm that no Seeds methods are on the background thread, as this is a likely cause. If needed, you can easily fix this by adding Seeds method calls to the dispatch queue of the main thread:

```objective-c
dispatch_async(dispatch_get_main_queue(), ^{ [Seeds calls here] });
```

### Why isn’t the interstitial showing up?

- Check that the campaign name is correct at the [Dashboard](https://developers.playseeds.com/index.html).
- Confirm in interstitialDidLoad that the interstitial preload was successful
- If you’re still having trouble, try making sure that when calling showWithId you are in a parent view that is visible and takes up the full screen

### Ahhh, I'm experiencing another problem.  Please help!

Please reach out via the [website](http://www.playseeds.com/#social-good) chat, and we’ll be happy to quickly assist. 

## License

MIT License

Copyright (c) 2017 Seeds

Copyright (c) 2012, 2013 Countly

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
