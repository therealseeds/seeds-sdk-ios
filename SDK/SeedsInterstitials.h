//
//  SeedsInterstitials.h
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import <Foundation/Foundation.h>

@class SeedsInterstitial, UIViewController;

@protocol SeedsInterstitialsEventProtocol <NSObject>

- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClick:(SeedsInterstitial *)interstitial;
- (void)interstitialDidShow:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClose:(SeedsInterstitial *)interstitial;
- (void)interstitial:(NSString *)interstitialId error:(NSError *)error;

@end

@interface SeedsInterstitials : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)fetchWithId:(NSString *)interstitialId;

- (BOOL)isLoadedWithId:(NSString *)interstitialId;

- (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context;

- (void)setEventsHandler:(id<SeedsInterstitialsEventProtocol>)eventsHandler;

@end
