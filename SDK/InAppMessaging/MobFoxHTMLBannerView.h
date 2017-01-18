//
//  Copyright 2015 MobFox
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import <UIKit/UIKit.h>

enum {
    MobFoxErrorUnknown = 0,
    MobFoxErrorServerFailure = 1,
    MobFoxErrorInventoryUnavailable = 2,
};

@class MobFoxHTMLBannerView;

@protocol MobFoxHTMLBannerViewDelegate <NSObject>

- (NSString *)publisherIdForMobFoxHTMLBannerView:(MobFoxHTMLBannerView *)banner;

@optional

- (void)mobfoxHTMLBannerViewDidLoadMobFoxAd:(MobFoxHTMLBannerView *)banner;

- (void)mobfoxHTMLBannerViewDidLoadRefreshedAd:(MobFoxHTMLBannerView *)banner;

- (void)mobfoxHTMLBannerView:(MobFoxHTMLBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;

- (BOOL)mobfoxHTMLBannerViewActionShouldBegin:(MobFoxHTMLBannerView *)banner willLeaveApplication:(BOOL)willLeave;

- (void)mobfoxHTMLBannerViewActionWillPresent:(MobFoxHTMLBannerView *)banner;

- (void)mobfoxHTMLBannerViewActionWillFinish:(MobFoxHTMLBannerView *)banner;

- (void)mobfoxHTMLBannerViewActionDidFinish:(MobFoxHTMLBannerView *)banner;

- (void) mobfoxHTMLBannerViewActionWillLeaveApplication:(MobFoxHTMLBannerView *)banner withUrl: (NSURL*) url;

- (void)interstitialSkipAction:(id)sender;

@end

@interface MobFoxHTMLBannerView : UIView 
{
	NSString *advertisingSection;
	BOOL bannerLoaded;
	BOOL bannerViewActionInProgress;

	BOOL _tapThroughLeavesApp;
	BOOL _shouldScaleWebView;
	BOOL _shouldSkipLinkPreflight;
	BOOL _statusBarWasVisible;
    NSInteger _refreshInterval;
	NSTimer *_refreshTimer;

}

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxHTMLBannerViewDelegate> delegate;
@property (nonatomic, copy) NSString *advertisingSection;
@property (nonatomic, assign) UIViewAnimationTransition refreshAnimation;

@property (nonatomic, assign) NSInteger adspaceWidth;
@property (nonatomic, assign) NSInteger adspaceHeight;
@property (nonatomic, assign) BOOL adspaceStrict;

@property (nonatomic, readonly, getter=isBannerLoaded) BOOL bannerLoaded;
@property (nonatomic, readonly, getter=isBannerViewActionInProgress) BOOL bannerViewActionInProgress;

@property (nonatomic, assign) BOOL refreshTimerOff;
@property (nonatomic, assign) NSInteger customReloadTime;
@property (nonatomic, retain) UIImage *bannerImage;
@property (strong, nonatomic) NSString *requestURL;

@property (nonatomic, assign) NSInteger userAge;
@property (nonatomic, copy) NSString* userGender;
@property (nonatomic, retain) NSArray* keywords;

@property (nonatomic, copy) NSString* manuallyEnteredLocalizedPrice;

@property (nonatomic, assign) BOOL locationAwareAdverts;

- (void)setupAdFromJson:(NSDictionary*)json;
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

@end

extern NSString * const MobFoxErrorDomain;