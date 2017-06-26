//
//  SeedsInterstitials.h
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SeedsInterstitial.h"

@protocol SeedsInterstitialsEventProtocol <NSObject>

- (void)interstitialDidLoad:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClick:(SeedsInterstitial *)interstitial;
- (void)interstitialDidShow:(SeedsInterstitial *)interstitial;
- (void)interstitialDidClose:(SeedsInterstitial *)interstitial;
- (void)interstitial:(NSString *)interstitialId error:(NSError *)error;

@end

@class Seeds;

@interface SeedsInterstitials : NSObject

- (instancetype)initWithSeeds:(Seeds *)seeds;

- (void)fetchWithId:(NSString *)interstitialId manualPrice:(NSString *)manualPrice;

- (BOOL)isLoadedWithId:(NSString *)interstitialId;

- (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context;

- (void)setEventsHandler:(id<SeedsInterstitialsEventProtocol>)eventsHandler;

@end
