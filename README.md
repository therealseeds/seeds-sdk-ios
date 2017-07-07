# Seeds    
[Seeds](http://www.playseeds.com) makes your users more likely to spend money on your digital product through social good. The SDK implements this with an interstitial (popup) system, event tracking analytics, and a recommendation algorithm.

## The following platforms are now available:
- [Unity SDK](https://github.com/therealseeds/seeds-sdk-unity)
- [iOS](https://github.com/therealseeds/seeds-sdk-ios)
- [Android](https://github.com/therealseeds/seeds-sdk-android)
- [API](https://github.com/therealseeds/seeds-public-api)

## Pull requests welcome
We're built on open source and welcome bug fixes and other contributions.

# The Seeds iOS SDK

## Pre-integration checklist

Check that you have everything set up for Seeds integration:

- A Seeds account - [Create it here](https://www.playseeds.com/) if you haven't done so yet

- A registered app with at least one campaign

- [The Dashboard tab](https://developers.playseeds.com/index.html) shows a list of your apps and the campaigns they contain. If you haven't received your final campaigns yet from us, you can start with the default example-campaign campaign.

- You have chosen one or more locations in the app where you want to show the interstitials. [Click here](https://developers.playseeds.com/docs/best-practices.html) to see our best placement guide.

- You have familiarized yourself with the example integration. [iOS Example Integration](https://github.com/therealseeds/seeds-sdk-ios/tree/master/Demo) shows a complete Seeds integration in action, and it's good to have it available as a reference when you are working on the integration.

## Installation
We recommend using CocoaPods for adding the Seeds SDK to your app because it makes it easy to update the Seeds SDK in the future. Add the following to the Podfile in your project root directory:


```
target '<Target_Name>' do
    ...   
    pod 'SeedsSDK'
end
```

## Usage
The Seeds SDK functionality is divided into two parts: [Interstitials](#interstitials_header) that represent all functionality that is connected to the content Seeds shows in-app, and [Events](#events_header) that represent logging analytics data.

### Initialization    
Seeds will be initialized only once, when the app is first loaded. In your [Dashboard](https://developers.playseeds.com/index.html) tab you will find App Keys for both the Test Environment and the Production Environment. Please use these when initializing the Seeds SDK.


```objective-c
#import <SeedsSDK/Seeds.h>
....

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...
  [Seeds initWithAppKey:YOUR_APP_KEY];
  ...
}

```
The earlier Seeds SDK is initialized, the better. It helps us to track the accurate user session length which is used when we target campaigns and interstitials to specific users based on their app use behavior.

****
### <a name="interstitials_header"></a>Interstitials

#### General rules:
* InterstitialId is the id of the interstitial, that can be found in your dashboard under the **Campaign Name** section.
* Context is the desription of the place, where you are showing the interstitial in human-readable manner. Please use short, but understandable descriptions (e.g. “level_1", “pause”, “app_start”).

#### 1) Pre-load the intesrtitial:
**Please note, that every interstitial must be previously loaded before your will attempt to show it.**
You can pre-load interstitial from the any place of your app, but we suggest to pre-load all the interstitials in the app startup:

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

#### 2) Set the interstitials event handler:
To receive the callbacks about events, such as notifications about clicks, dismiss, errors, loading, please set the interstitials event handler to receive callback from the SDK. Choose the class which you want to use for handling those events and implement [SeedsInterstitialsEventProtocol](#interstitialseventprotocol_header) methods:

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
	//Called when any some error occures
}

```

#### 3) Show the Interstitial:
To show the interstitial please do the following:

- At first, сheck to see if the interstitial has already loaded.
- If the interstitial is loaded - show it.

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

#### <a name="interstitialseventprotocol_header"></a> SeedsInterstitialsEventProtocol
The delegate implementation contains five methods for treating different scenarios after the opening of an interstitial has been attempted.

```objective-c
- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial; //Called when the interstitial was loaded
- (void)interstitialDidClick:(SeedsInterstitial *)interstitial; //Called when the interstitial "buy" button was clicked
- (void)interstitialDidShow:(SeedsInterstitial *)interstitial; //Called when the interstitial was successfully shown
- (void)interstitialDidClose:(SeedsInterstitial *)interstitial; //Called when the user presses "close" or "back" button
- (void)interstitial:(NSString *)interstitialId error:(NSError *)error; //Called when any some error occures
```

### <a name="events_header"></a>Events

An event is the generalized mechanism for tracking all user actions taken in-app. **[Seeds events]** use two approaches for logging data: direct logging for purchases made, and an object-based approach for tracking all other data. Use **logSeedsIAPEvent** or **logIAPEvent** after any successful purchase, and **logUserInfo** with the provided wrapper to empower Seeds to make the targeted recommendations that will best convert your non-payers into paying customers. There is also an additional way to log your app’s custom data **logEventWithKey**.

#### After successful in-app purchase:

**This method should be called after any successful purchase in the app to help the to Seeds track the purchases and generate useful tips, statistic and issue correct invoices.**
Depending of the type of purchase (whether it was with Seeds-promoted purchase or usual one), notify the SDK about it:

```objective-c
- (void)someMethod {
	...
	//Successful purchase was made above
 	[[Seeds events] logSeedsIAPEvent:PRODUCT_ID price:YOUR_PURCHASE_PRICE transactionId:YOUR_TRANSACTION_ID]; //If there was a Seeds in-app purchase
 	[[Seeds events] logIAPEvent:PRODUCT_ID price:YOUR_PURCHASE_PRICE transactionId:YOUR_TRANSACTION_ID]; //If there was non-Seeds in-app purchase
}

```

#### After generating user data:

To specify userInfo data, please use following keys. This allows Seeds to show your users the opportunities to contribute to social good that will resonate most, optimizing your non-payer to payer conversion, and therefore your revenue.

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

### Optional: Add Seeds branding to your in-app store

In addition to interstitials, you can make Seeds more visible in your app by adding the Seeds logo next to your promoted in-app purchase items. Contact us with the website chat (or at [team@playseeds.com](mailto:team@playseeds.com)) to discuss what kind of branding is best for your app!

### Switch to Production Environment App Key and launch your app update!

Before you will publish the app update, use Production Environment App Key instead of the one for Test Environment in Seeds initialization. After that you are good to go!

## Solutions to integration problems

#### App is crashing after initializing Seeds

All Seeds methods must be run in the main thread, and probably some of your methods where you call Seeds is on background thread. You can fix this easily by adding Seeds method calls to the dispatch queue of main thread:

```objective-c
dispatch_async(dispatch_get_main_queue(), ^{ [Seeds calls here] });
```

#### The interstitial doesn't show up

- Check that the campaign name is correct
- Check in interstitialDidLoad that preloading the interstitial has been successful
- Check that when calling showWithId you are a parent view that is visible and takes the full screen

#### I'm experiencing some other problem

Feel free to contact us [team@playseeds.com](mailto:team@playseeds.com)!

## License
MIT License

Copyright (c) 2017 Seeds

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.