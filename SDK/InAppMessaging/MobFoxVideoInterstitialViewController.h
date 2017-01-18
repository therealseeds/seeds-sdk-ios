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
//  Changed by Oleksii Pelykh
//
//  Changes: kept only text&image ad types;
//


#import <UIKit/UIKit.h>

enum {
    MobFoxInterstitialViewErrorUnknown = 0,
    MobFoxInterstitialViewErrorServerFailure = 1,
    MobFoxInterstitialViewErrorInventoryUnavailable = 2,
};

typedef enum {
    MobFoxAdTypeNoAdInventory = 0,
    MobFoxAdTypeError = 2,
    MobFoxAdTypeUnknown = 3,
    MobFoxAdTypeText = 4,
    MobFoxAdTypeImage = 5,
} MobFoxAdType;

typedef enum {
    MobFoxAdGroupInterstitial = 1
} MobFoxAdGroupType;

@class MobFoxVideoInterstitialViewController;
@class MobFoxAdBrowserViewController;

@protocol MobFoxVideoInterstitialViewControllerDelegate <NSObject>

- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial;

@optional

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType;

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error;

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial;

- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial;

- (void)mobfoxVideoInterstitialViewDidDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial;

- (void)mobfoxVideoInterstitialViewActionWillLeaveApplication:(MobFoxVideoInterstitialViewController *)videoInterstitial;

- (BOOL)mobfoxVideoInterstitialViewWasClicked:(MobFoxVideoInterstitialViewController *)videoInterstitial withUrl:(NSURL *)url;

@end

@interface MobFoxVideoInterstitialViewController : UIViewController
{

    BOOL _advertLoaded;
	BOOL advertViewActionInProgress;

    __unsafe_unretained id <MobFoxVideoInterstitialViewControllerDelegate> delegate;

    MobFoxAdBrowserViewController *_browser;

    NSString *requestURL;
    NSString *videoRequestURL;
    UIImage *_bannerImage;
}

@property (nonatomic, assign) IBOutlet __unsafe_unretained id <MobFoxVideoInterstitialViewControllerDelegate> delegate;

@property (nonatomic, readonly, getter=isAdvertViewActionInProgress) BOOL advertViewActionInProgress;

@property (nonatomic, assign) BOOL locationAwareAdverts;
@property (nonatomic, assign) BOOL enableInterstitialAds;

@property (nonatomic, assign) NSInteger userAge;
@property (nonatomic, copy) NSString* userGender;
@property (nonatomic, retain) NSArray* keywords;
@property (nonatomic, copy) NSString* seedsMessageId;
@property (nonatomic, copy) NSString* seedsMessageVariant;
@property (nonatomic, copy) NSString* seedsMessageContext;
@property (nonatomic, copy) NSString* manuallyEnteredLocalizedPrice;
@property (nonatomic, copy) NSString *requestURL;

- (BOOL)isAdvertLoaded:(NSString*)messageId;

- (void)requestAd:(NSString*)messageId;

- (void)presentAd:(MobFoxAdType)advertType;

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

- (void)interstitialStopAdvert;

- (void)recordInterstitialEvent:(NSString *)key;

- (void)recordInterstitialEvent:(NSString *)key withCustomSegments:(id)customSegments;
@end

extern NSString * const MobFoxVideoInterstitialErrorDomain;