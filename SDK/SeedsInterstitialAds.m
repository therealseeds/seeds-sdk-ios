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
#import "SeedsCore.h"
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

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController
{
    if (![self isInAppMessageLoaded:messageId] || Seeds.sharedInstance.inAppMessageDoNotShow) {
        id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withMessageId:withSuccess:)])
            [delegate seedsInAppMessageShown:nil withMessageId:Seeds.sharedInstance.inAppMessageId withSuccess:NO];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
            [delegate seedsInAppMessageShown:nil withSuccess:NO];

        return;
    }
    
    [viewController.view addSubview:self.controller.view];
    [viewController addChildViewController:self.controller];
    
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
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded:withMessageId:)])
        [delegate seedsInAppMessageLoadSucceeded:nil withMessageId:Seeds.sharedInstance.inAppMessageId];
    

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded:)])
        [delegate seedsInAppMessageLoadSucceeded:nil];
    
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
                         segmentation:@{ @"message" : Seeds.sharedInstance.inAppMessageVariantName }
                                count:1];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withMessageId:withSuccess:)])
        [delegate seedsInAppMessageShown:nil withMessageId:Seeds.sharedInstance.inAppMessageId withSuccess:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
        [delegate seedsInAppMessageShown:nil withSuccess:YES];
    
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
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClosed:withMessageId:andCompleted:)])
        [delegate seedsInAppMessageClosed:nil withMessageId:Seeds.sharedInstance.inAppMessageId andCompleted:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClosed:andCompleted:)])
        [delegate seedsInAppMessageClosed:nil andCompleted:YES];
    
}

- (void)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked");
    
    [Seeds.sharedInstance recordEvent:@"message clicked"
                         segmentation:@{ @"message" : Seeds.sharedInstance.inAppMessageVariantName }
                                count:1];
    
    Seeds.sharedInstance.adClicked = YES;
    
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked (ad clicked = %s)", Seeds.sharedInstance.adClicked ? "yes" : "no");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:withMessageId:)])
        [delegate seedsInAppMessageClicked:nil withMessageId:Seeds.sharedInstance.inAppMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:)])
        [delegate seedsInAppMessageClicked:nil];
}

@end
