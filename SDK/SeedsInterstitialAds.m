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
#import "Seeds_Private.h"
#import "SeedsInAppMessageDelegate.h"
#import <Social/Social.h>

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

- (MobFoxVideoInterstitialViewController *)getInterstitial:(NSString *)messageId inContext:(NSString *)context {
    // Create the controller on the fly if needed
    if (self.interstitialsByMessageId[messageId] == nil) {
        MobFoxVideoInterstitialViewController *interstitial = [[MobFoxVideoInterstitialViewController alloc] init];
        interstitial.delegate = self;
        interstitial.enableInterstitialAds = YES;
        interstitial.seedsMessageId = messageId;
        self.interstitialsByMessageId[messageId] = interstitial;
    }

    self.interstitialsByMessageId[messageId].seedsMessageContext= context;

    return self.interstitialsByMessageId[messageId];
}

- (void)requestInAppMessage:(NSString *)messageId withManualLocalizedPrice: (NSString*)price
{
    MobFoxVideoInterstitialViewController *interstitial = [self getInterstitial:messageId inContext:@""];
    interstitial.manuallyEnteredLocalizedPrice = price;
    interstitial.requestURL = self.appHost;

    [interstitial requestAd:messageId];
}

- (BOOL)isInAppMessageLoaded:(NSString*)messageId
{
    return [[self getInterstitial:messageId inContext:nil] isAdvertLoaded:messageId];
}

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext
{
    if (![self isInAppMessageLoaded:messageId]) {
        id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
            [delegate seedsInAppMessageShown:messageId withSuccess:NO];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:)])
            [delegate seedsInAppMessageShown:NO];

        return;
    }
    
    [Seeds sharedInstance].adClicked = NO;
    
    NSString *context = messageContext != nil ? messageContext : @"";
    MobFoxVideoInterstitialViewController *interstitial = [self getInterstitial:messageId inContext: context];
    
    // Remove the interstitial from its former superview and parent view controller
    if ([interstitial.view superview] != nil) [interstitial.view removeFromSuperview];
    if ([interstitial parentViewController] != nil) [interstitial removeFromParentViewController];
    
    [viewController.view addSubview:interstitial.view];
    [viewController addChildViewController:interstitial];
    
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

    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded:)])
        [delegate seedsInAppMessageLoadSucceeded:videoInterstitial.seedsMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageLoadSucceeded)])
        [delegate seedsInAppMessageLoadSucceeded];
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialView didFailToReceiveAdWithError");
    NSLog(@"[Seeds] Are you trying to request an interstitial before calling the [[Seeds sharedInstance] start ...] method?");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound:)])
        [delegate seedsNoInAppMessageFound:videoInterstitial.seedsMessageId];

    if (delegate && [delegate respondsToSelector:@selector(seedsNoInAppMessageFound)])
        [delegate seedsNoInAppMessageFound];
}

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewActionWillPresentScreen");

    [videoInterstitial recordInterstitialEvent:@"message shown"];
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageShown:withSuccess:)])
        [delegate seedsInAppMessageShown:videoInterstitial.seedsMessageId withSuccess:YES];

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
            [delegate seedsInAppMessageDismissed:videoInterstitial.seedsMessageId];
        
        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageDismissed)])
            [delegate seedsInAppMessageDismissed:nil];
    }
}

- (BOOL)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial withUrl:(NSURL *)url {
    BOOL closeAfterClick = true;

    Seeds.sharedInstance.adClicked = YES;
    
    NSLog(@"[Seeds] mobfoxVideoInterstitialViewWasClicked (ad clicked = %s)", Seeds.sharedInstance.adClicked ? "yes" : "no");
    
    id<SeedsInAppMessageDelegate> delegate = Seeds.sharedInstance.inAppMessageDelegate;

    NSArray<NSString *> *path = [url pathComponents];

    bool isSocialSharingUrl = path.count == 3 && [path[1] isEqualToString: @"social-share"];
    bool isPriceUrl = path.count == 3 && [path[1] isEqualToString: @"price"];
    bool isShowMoreUrl = path.count == 2 && [path[1] isEqualToString: @"show-more"];

    if (isSocialSharingUrl) {
        NSURL *sharingUrl = [NSURL URLWithString:[@"http://playseeds.com/" stringByAppendingString: path[2]]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[sharingUrl] applicationActivities:nil];
        activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                UIActivityTypePrint,
                UIActivityTypeCopyToPasteboard,
                UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToFlickr,
                UIActivityTypePostToVimeo,
                UIActivityTypePostToTencentWeibo,
                UIActivityTypeAirDrop];
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            activityController.popoverPresentationController.sourceView = [videoInterstitial parentViewController].view;
            
            CGRect bounds = [videoInterstitial parentViewController].view.bounds;
            bounds.size.height /= 2;
            
            activityController.popoverPresentationController.sourceRect = bounds;
            activityController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }

        [[videoInterstitial parentViewController] presentViewController:activityController animated:YES completion:nil];

        closeAfterClick = false;

        [videoInterstitial recordInterstitialEvent: @"social share clicked"];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:)])
            [delegate seedsInAppMessageClicked:videoInterstitial.seedsMessageId];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked)])
            [delegate seedsInAppMessageClicked];

    } else if (isPriceUrl) {
        NSString* priceString = path[2];
        [videoInterstitial recordInterstitialEvent: @"dynamic price clicked" withCustomSegments: @{@"price" : priceString}];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:withDynamicPrice:)]) {
            [delegate seedsInAppMessageClicked:videoInterstitial.seedsMessageId withDynamicPrice:priceString];
        }
    } else if (isShowMoreUrl) {
        [videoInterstitial recordInterstitialEvent: @"show more clicked"];
        closeAfterClick = false;
    } else {
        [videoInterstitial recordInterstitialEvent: @"message clicked"];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked:)])
            [delegate seedsInAppMessageClicked:videoInterstitial.seedsMessageId];

        if (delegate && [delegate respondsToSelector:@selector(seedsInAppMessageClicked)])
            [delegate seedsInAppMessageClicked];
    }

    return closeAfterClick;
}

@end
