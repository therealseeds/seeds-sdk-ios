//
//  SeedsInterstitials.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsInterstitials.h"
#import "SeedsInterstitial.h"
#import "Seeds.h"
#import "Seeds_Private.h"
#import "SeedsInAppMessageDelegate.h"

NSString * const kSeedsInterstitialsDomain = @"SeedsInterstitials";
NSString * const kSeedsInterstitialNotFoundDescription = @"Not found";

@interface SeedsInterstitials() <SeedsInAppMessageDelegate>
    @property (atomic, weak) id<SeedsInterstitialsEventProtocol> eventHandler;
@end

@implementation SeedsInterstitials

- (void)fetchWithId:(NSString *)interstitialId {
    [[Seeds sharedInstance] requestInAppMessage:interstitialId withManualLocalizedPrice:nil];
}

- (BOOL)isLoadedWithId:(NSString *)interstitialId {
    return [[Seeds sharedInstance]  isInAppMessageLoaded:interstitialId];
}

- (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context {
    [[Seeds sharedInstance]  showInAppMessage:interstitialId in:viewController withContext:context];
}

- (void)setEventsHandler:(id<SeedsInterstitialsEventProtocol>)eventsHandler {
    self.eventHandler = eventsHandler;
}

#pragma mark
#pragma mark <SeedsInAppMessageDelegate>

- (void)seedsInAppMessageLoadSucceeded:(NSString *)messageId {
    [self performHandlerSelector:@selector(interstitialDidLoad:) forInterstitial:[[SeedsInterstitial alloc] initWithId:messageId]];
}

- (void)seedsInAppMessageShown:(NSString *)messageId withSuccess:(BOOL)success {
    if (success) {
        [self performHandlerSelector:@selector(interstitialDidShow:) forInterstitial:[[SeedsInterstitial alloc] initWithId:messageId]];
    } else {
        [self seedsNoInAppMessageFound:messageId];
    }
}

- (void)seedsNoInAppMessageFound:(NSString *)messageId {
    if ([self.eventHandler respondsToSelector:@selector(interstitial:error:)]) {
        
        NSError *error = [NSError errorWithDomain:kSeedsInterstitialsDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:kSeedsInterstitialNotFoundDescription}];
        [self.eventHandler interstitial:messageId error:error];
    }
}

- (void)seedsInAppMessageClicked:(NSString *)messageId {
    [self performHandlerSelector:@selector(interstitialDidClick:) forInterstitial:[[SeedsInterstitial alloc] initWithId:messageId]];
}

- (void)seedsInAppMessageDismissed:(NSString *)messageId {
    [self performHandlerSelector:@selector(interstitialDidClose:) forInterstitial:[[SeedsInterstitial alloc] initWithId:messageId]];
}

- (void)seedsInAppMessageClicked:(NSString *)messageId withDynamicPrice:(NSString *)price {
    [self performHandlerSelector:@selector(interstitialDidClick:) forInterstitial:[[SeedsInterstitial alloc] initWithId:messageId price:price]];
}

#pragma mark Private

- (void)performHandlerSelector:(SEL)selector forInterstitial:(SeedsInterstitial *)interstitial {
    if (interstitial != nil && [self.eventHandler respondsToSelector:selector]) {
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.eventHandler performSelector:selector withObject:interstitial];
    }
}

@end
