//
//  SeedsInterstitialAds.h
//  Seeds
//

#pragma mark - Seeds Interstitial Ads

#import "InAppMessaging/MobFoxVideoInterstitialViewController.h"

@interface SeedsInterstitialAds : NSObject <MobFoxVideoInterstitialViewControllerDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appHost;
@property (nonatomic, retain) NSMutableDictionary<NSString *, MobFoxVideoInterstitialViewController *> *interstitialsByMessageId;

+ (instancetype)sharedInstance;
- (void)requestInAppMessage:(NSString *)messageId withManualLocalizedPrice: (NSString*)price;
- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext;
- (BOOL)isInAppMessageLoaded:(NSString*)messageId;

@end

