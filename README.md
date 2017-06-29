#Seeds
[Seeds](http://www.playseeds.com) increases paying user conversion for freemium mobile games motivating users to make their first purchase by letting them know that their purchase will help finance microloans in the developing world. The SDK implements this with an interstitial ad and event tracking analytics.

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
target '<Application_Name>' do
    ...   
    pod 'SeedsSDK', '0.4.6'
end
```

###Initialization: 
Seeds will be initialized only once from the very beginning of the app start.
In Seeds' [Dashboard](https://developers.playseeds.com/index.html) tab you will see find App Keys for both Test Environment and Production Environment. Those keys identify your app and they are needed in the initialization of Seeds SDK.

```objective-c
[Seeds initWithAppKey:YOUR_APP_KEY];
```

****
### <a name="interstitials_header"></a>Seeds.Interstitials

- Set interstitials-handler to receive callback from SDK.    
Choose the class which you want to use for handling those events and implement [SeedsInterstitialsEventProtocol](#interstitialseventprotocol_header) methods:

```objective-c
 - (void)setEventsHandler:(id <SeedsInterstitialsEventProtocol>)eventsHandler;
```
- Load the required interstitial with *interstitialId*:
<u>If manual price not specified - Seeds SDK load price value from Apple StoreKit.</u> 
```objective-c
- (void)fetchWithId:(NSString *)interstitialId manualPrice:(NSString *)manualPrice
```
- Check if this interstitial is ready to be shown (is loaded). Returns either true or false.

```objective-c
 - (BOOL)isLoadedWithId:(NSString *)interstitialId;
```

- Show the interstitial. The *onViewController* parameter defines the parent viewController where the interstitial view will be added. The withContext parameter is currently obsolete. As callback SDK use the instance that was passed in the setEventsHandler:.
 
```objective-c
 - (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context;
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
### <a name="events_header"></a>Seeds.Events

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
****

Please see the [documentation](http://developers.playseeds.com/docs/ios-sdk-setup).
