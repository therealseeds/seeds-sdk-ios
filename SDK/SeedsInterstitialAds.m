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
        self.controller = [[MobFoxVideoInterstitialViewController alloc] init];
        self.controller.delegate = self;
        self.controller.enableInterstitialAds = YES;
    }
    return self;
}

- (void)requestInAppMessage:(NSString*)messageId
{
    self.controller.requestURL = self.appHost;
    [self.controller requestAd:messageId];
}

- (BOOL)isInAppMessageLoaded:(NSString*)messageId
{
    return [self.controller isAdvertLoaded:messageId];
}

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext
{
    if (![self isInAppMessageLoaded:messageId] || Seeds.sharedInstance.inAppMessageDoNotShow) {
        id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
            [delegate seedsInAppMessageShown:Seeds.sharedInstance.inAppMessageId withSuccess:NO];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:)])
            [delegate seedsInAppMessageShown:NO];

        return;
    }
    
    Seeds.sharedInstance.adClicked = NO;
    [Seeds sharedInstance].clickUrl = nil;

    [viewController.view addSubview:self.controller.view];
    [viewController addChildViewController:self.controller];

    Seeds.sharedInstance.inAppMessageContext = messageContext != nil ? messageContext : @"";
    [self.controller presentAd:MobFoxAdTypeText];
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
        [delegate seedsInAppMessageLoadSucceeded:Seeds.sharedInstance.inAppMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded)])
        [delegate seedsInAppMessageLoadSucceeded];
    
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialView didFailToReceiveAdWithError");
    NSLog(@"[Seeds] Are you trying to request an interstitial before calling the [[Seeds sharedInstance] start ...] method?");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound:)])
        [delegate seedsNoInAppMessageFound:Seeds.sharedInstance.inAppMessageId];
    
    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound)])
        [delegate seedsNoInAppMessageFound];
}

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewActionWillPresentScreen");

    [Seeds.sharedInstance recordEvent:@"message shown"
                         segmentation:@{ @"message" : Seeds.sharedInstance.inAppMessageVariantName,
                                         @"context" : Seeds.sharedInstance.inAppMessageContext }
                                count:1];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
        [delegate seedsInAppMessageShown:Seeds.sharedInstance.inAppMessageId withSuccess:YES];
    
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
    
    [self.controller.view removeFromSuperview];
    [self.controller removeFromParentViewController];
}

- (void)mobfoxVideoInterstitialViewActionWillLeaveApplication:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewActionWillLeaveApplication");
    
    [self.controller interstitialStopAdvert];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    
    if (!Seeds.sharedInstance.adClicked) {
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageDismissed:)])
            [delegate seedsInAppMessageDismissed:Seeds.sharedInstance.inAppMessageId];
        
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageDismissed)])
            [delegate seedsInAppMessageDismissed:nil];
    }
}

- (void)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial withUrl:(NSURL *)url {
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked");
    
    [Seeds.sharedInstance recordEvent:@"message clicked"
                         segmentation:@{ @"message" : Seeds.sharedInstance.inAppMessageVariantName,
                                         @"context" : Seeds.sharedInstance.inAppMessageContext }
                                count:1];

    Seeds.sharedInstance.adClicked = YES;
    
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked (ad clicked = %s)", Seeds.sharedInstance.adClicked ? "yes" : "no");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:)])
        [delegate seedsInAppMessageClicked:Seeds.sharedInstance.inAppMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked)])
        [delegate seedsInAppMessageClicked];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked: withPrice:)]) {
        // Interpret the price from the link url
        NSString* path = [url path];
        bool isPriceUrl = [[url path] hasPrefix:@"/price"];
        if (isPriceUrl) {
            float price = [[url lastPathComponent] floatValue];
            [delegate seedsInAppMessageClicked:Seeds.sharedInstance.inAppMessageId withPrice:price];
        }

    }
    
    // - (void)seedsInAppMessageClicked:(NSString*)messageId withPrice:(double)price;
}

@end
