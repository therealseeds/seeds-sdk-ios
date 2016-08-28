//
//  SeedsInterstitialAds.h
//  Seeds
//

#pragma mark - Seeds Interstitial Ads

#import "InAppMessaging/MobFoxVideoInterstitialViewController.h"

@interface SeedsInterstitialAds : NSObject <MobFoxVideoInterstitialViewControllerDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appHost;
@property (nonatomic, retain) MobFoxVideoInterstitialViewController *controller;

+ (instancetype)sharedInstance;
- (void)requestInAppMessage:(NSString*)messageId;
- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext;
- (BOOL)isInAppMessageLoaded:(NSString*)messageId;

@end

