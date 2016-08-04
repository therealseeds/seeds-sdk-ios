//
//  SeedsInterstitialAds.h
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#pragma mark - Seeds Interstitial Ads

#import "InAppMessaging/MobFoxVideoInterstitialViewController.h"

@interface SeedsInterstitialAds : NSObject <MobFoxVideoInterstitialViewControllerDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appHost;
@property (nonatomic, retain) MobFoxVideoInterstitialViewController *controller;

+ (instancetype)sharedInstance;

- (void)requestInAppMessage:(NSString*)messageId;

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController;

@end

