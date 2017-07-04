# Seeds    
[Seeds](http://www.playseeds.com) makes your users more likely to spend money on your digital product through social good.  The SDK implements this with an interstitial (popup) system, event tracking analytics, and a recommendation algorithm..

## The following platforms are now available:
- [Unity SDK](https://github.com/therealseeds/seeds-sdk-unity)
- [iOS](https://github.com/therealseeds/seeds-sdk-ios)
- [Android](https://github.com/therealseeds/seeds-sdk-android)
- [API](https://github.com/therealseeds/seeds-public-api)

## Pull requests welcome
We're built on open source and welcome bug fixes and other contributions.

## The Seeds iOS SDK
The Seeds iOS SDK is built with production-tested open source components, including [Countly iOS SDK](https://github.com/countly/countly-sdk-ios) for analytics.

### Installation
We recommend using CocoaPods for adding the Seeds SDK to your app because it makes it easy to update the Seeds SDK later on. Add the following to the Podfile in your project root directory:  

```
target '<Target_Name>' do
    ...   
    pod 'SeedsSDK'
end
```

### Initialization:    
Seeds will be initialized only once from the very beginning of the app start.
In Seeds' [Dashboard](https://developers.playseeds.com/index.html) tab you will see find App Keys for both Test Environment and Production Environment. Those keys identify your app and they are needed in the initialization of Seeds SDK.

```objective-c
#import <SeedsSDK/Seeds.h>
....

[Seeds initWithAppKey:YOUR_APP_KEY];
```

****
### <a name="interstitials_header"></a>Interstitials

- Set interstitials event handler to receive callback from SDK.    
Choose the class which you want to use for handling those events and implement [SeedsInterstitialsEventProtocol](#interstitialseventprotocol_header) methods:

```objective-c
 - (void)setEventsHandler:(id <SeedsInterstitialsEventProtocol>)eventsHandler;
```
example:

```objective-c
[[Seeds Interstitials] setEventsHandler:self];
```

- Load the required interstitial with *interstitialId*:
<u>If manual price not specified - Seeds SDK load price value from Apple StoreKit.</u> 

```objective-c
- (void)fetchWithId:(NSString *)interstitialId manualPrice:(NSString *)manualPrice
```
example:

```objective-c
[[Seeds interstitials] fetchWithId:@"PURCHASE_INTERSTITIAL_ID" manualPrice:nil];
```
- Check if this interstitial is ready to be shown (is loaded). Returns either true or false.

```objective-c
 - (BOOL)isLoadedWithId:(NSString *)interstitialId;
```
example:

```objective-c
if ([[Seeds interstitials] isLoadedWithId:messageId]) {
	...
}
```

- Show the interstitial. The *onViewController* parameter defines the parent viewController where the interstitial view will be added. The withContext parameter is currently obsolete. As callback SDK use the instance that was passed in the setEventsHandler:.
 
```objective-c
 - (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context;
```
example:

```objective-c
[[Seeds interstitials] showWithId:messageId onViewController:self inContext:@"context"];
```

#### <a name="interstitialseventprotocol_header"></a> SeedsInterstitialsEventProtocol
The delegate implementation contains five methods for treating different scenarios after the opening of an interstitial has been attempted.

```objective-c
- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClick:(SeedsInterstitial *)interstitial;
- (void)interstitialDidShow:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClose:(SeedsInterstitial *)interstitial;
- (void)interstitial:(NSString *)interstitialId error:(NSError *)error;
```
****
### <a name="events_header"></a>Events

- Track common event specified by *key* with *parameters*.

```objective-c
 - (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters;
```
- Track the Seeds-promoted in-app purchases for trancaction with *transactionId*

```objective-c
 - (void)logSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;
```
- Track all other in-app purchases for trancaction with *transactionId*: 

```objective-c
 - (void)logIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

```
example:

```objective-c
[[Seeds events] logIAPEvent:@"NORMAL_IAP_EVENT_KEY" price:4.99 transactionId:nil];
```
- Track userInfo  

```objective-c
 - (void)logUserInfo:(NSDictionary *)userInfo;
```
To specify userInfo data, please use following keys:

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
example:

```objective-c
[[Seeds events] logUserInfo:@{kSeedEventUserName:@"Uncle Sam", kSeedEventUserPhone:@"+14561234545"}];
```
****

Please see the [documentation](http://developers.playseeds.com/docs/ios-sdk-setup).
