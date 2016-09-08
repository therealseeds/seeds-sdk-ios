//
//  SeedsInterstitialAds.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SeedsInterstitialAds.h"
#import "Seeds.h"
#import "SeedsInAppMessageDelegate.h"

@interface SeedsInterstitialAds()
@end

@implementation SeedsInterstitialAds

@synthesize appKey;
@synthesize appHost;

+ (instancetype)sharedInstance
{
    static SeedsInterstitialAds *s_sharedSeedsInterstitialAds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{s_sharedSeedsInterstitialAds = self.new;});
    return s_sharedSeedsInterstitialAds;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.interstitialsByMessageId = [NSMutableDictionary dictionary];
    }
    return self;
}

- (MobFoxVideoInterstitialViewController *)getInterstitial:(NSString*)messageId
{
    // TODO: Refactor this when we start to require explicit messageId
    NSString *key = messageId != nil ? messageId : @"key-for-no-messageid";

    // Create the controller on the fly if needed
    if (self.interstitialsByMessageId[key] == nil) {
        self.interstitialsByMessageId[key] = [[MobFoxVideoInterstitialViewController alloc] init];
        self.interstitialsByMessageId[key].delegate = self;
        self.interstitialsByMessageId[key].enableInterstitialAds = YES;
    }

    return self.interstitialsByMessageId[key];
}

- (void)requestInAppMessage:(NSString*)messageId
{
    MobFoxVideoInterstitialViewController *interstitial = [self getInterstitial:messageId];

    interstitial.requestURL = self.appHost;
    [interstitial requestAd:messageId];
}

- (BOOL)isInAppMessageLoaded:(NSString*)messageId
{
    return [[self getInterstitial:messageId] isAdvertLoaded:messageId];
}

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext
{
    if (![self isInAppMessageLoaded:messageId] || Seeds.sharedInstance.inAppMessageDoNotShow) {
        id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
            [delegate seedsInAppMessageShown:Seeds.sharedInstance.currentMessageId withSuccess:NO];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:)])
            [delegate seedsInAppMessageShown:NO];

        return;
    }
    
    [Seeds sharedInstance].adClicked = NO;
    [Seeds sharedInstance].clickUrl = nil;

    if (messageId != nil) {
        [Seeds sharedInstance].currentMessageId = messageId;
    }

    MobFoxVideoInterstitialViewController *interstitial = [self getInterstitial:messageId];
    [viewController.view addSubview:interstitial.view];
    [viewController addChildViewController:interstitial];

    Seeds.sharedInstance.inAppMessageContext = messageContext != nil ? messageContext : @"";
    [interstitial presentAd:MobFoxAdTypeText];
}

- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    return self.appKey;
}

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewDidLoadMobFoxAd");
    
    Seeds.sharedInstance.adClicked = NO;
    Seeds.sharedInstance.clickUrl = nil;
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded:)])
        [delegate seedsInAppMessageLoadSucceeded:Seeds.sharedInstance.currentMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded)])
        [delegate seedsInAppMessageLoadSucceeded];
    
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialView didFailToReceiveAdWithError");
    NSLog(@"[Seeds] Are you trying to request an interstitial before calling the [[Seeds sharedInstance] start ...] method?");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound:)])
        [delegate seedsNoInAppMessageFound:Seeds.sharedInstance.currentMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound)])
        [delegate seedsNoInAppMessageFound];
}

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewActionWillPresentScreen");

    [Seeds.sharedInstance recordEvent:@"message shown"
                         segmentation:@{ @"message" : Seeds.sharedInstance.currentMessageId,
                                         @"context" : Seeds.sharedInstance.inAppMessageContext }
                                count:1];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
        [delegate seedsInAppMessageShown:Seeds.sharedInstance.currentMessageId withSuccess:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:)])
        [delegate seedsInAppMessageShown:YES];
    
}

- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWillDismissScreen");
}

- (void)mobfoxVideoInterstitialViewDidDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewDidDismissScreen");
    
    [videoInterstitial.view removeFromSuperview];
    [videoInterstitial removeFromParentViewController];
}

- (void)mobfoxVideoInterstitialViewActionWillLeaveApplication:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewActionWillLeaveApplication");
    
    [videoInterstitial interstitialStopAdvert];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    
    if (!Seeds.sharedInstance.adClicked) {
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageDismissed:)])
            [delegate seedsInAppMessageDismissed:Seeds.sharedInstance.currentMessageId];
        
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageDismissed)])
            [delegate seedsInAppMessageDismissed:nil];
    }
}

- (void)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial withUrl:(NSURL *)url {
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked");
    
    [Seeds.sharedInstance recordEvent:@"message clicked"
                         segmentation:@{ @"message" : Seeds.sharedInstance.currentMessageId,
                                         @"context" : Seeds.sharedInstance.inAppMessageContext }
                                count:1];

    Seeds.sharedInstance.adClicked = YES;
    
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked (ad clicked = %s)", Seeds.sharedInstance.adClicked ? "yes" : "no");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:)])
        [delegate seedsInAppMessageClicked:Seeds.sharedInstance.currentMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked)])
        [delegate seedsInAppMessageClicked];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:withDynamicPrice:)]) {
        // Interpret the price from the link url
        bool isPriceUrl = [[url path] hasPrefix:@"/price"];
        if (isPriceUrl) {
            float price = [[url lastPathComponent] floatValue];
            [delegate seedsInAppMessageClicked:Seeds.sharedInstance.currentMessageId withDynamicPrice:price];
        }

    }
    
    // - (void)seedsInAppMessageClicked:(NSString*)messageId withPrice:(double)price;
}

@end
