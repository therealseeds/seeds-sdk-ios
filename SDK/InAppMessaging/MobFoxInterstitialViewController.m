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
//  MobFoxInterstitialViewController.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 05.05.2015.
//  Changed by Oleksii Pelykh
//
//  Changes: removed native ads support; removed unused imports; removed add creative types support except banner;
//

#import "MobFoxInterstitialViewController.h"
#import "MobFoxCreativesQueueManager.h"
#import "MobFoxVideoInterstitialViewController.h"
#import "MobFoxInterstitialPlayerViewController.h"
#import "UIImage+MobFox.h"

@interface MobFoxInterstitialViewController () <MobFoxVideoInterstitialViewControllerDelegate> {
}

@property (nonatomic, strong) MobFoxCreativesQueueManager* queueManager;
@property (nonatomic, strong) NSMutableArray* adQueue;

@property (nonatomic, strong) MobFoxVideoInterstitialViewController *videoInterstitialViewController;

@property (nonatomic, assign) MobFoxCreativeType loadedCreativeType;
@property (nonatomic, assign) BOOL advertRequestInProgress;
@property (nonatomic, strong) UIViewController* viewController;

@end


@implementation MobFoxInterstitialViewController


@synthesize videoInterstitialViewController;

-(instancetype)initWithViewController:(UIViewController *)controller {
    self = [super init];
    self.viewController = controller;
    [self setup];
    return self;
}


- (void)setup {
    
    self.videoInterstitialViewController = [[MobFoxVideoInterstitialViewController alloc] init];
    self.videoInterstitialViewController.delegate = self;
    
    [self.viewController.view addSubview:self.videoInterstitialViewController.view];
}

-(void)setDelegate:(id<MobFoxInterstitialDelegate>)delegate {
    _delegate = delegate;
    self.queueManager = [MobFoxCreativesQueueManager sharedManagerWithPublisherId:[self.delegate publisherIdForMobFoxInterstitial]];
}

-(void)requestAd {
    if (self.advertRequestInProgress) {
        return;
    }
    [self requestAdInternal];
}

-(void) requestAdInternal {
    if (!self.delegate)
    {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Delegate for interstitial not set!" forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorInventoryUnavailable userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        
        return;
    }
    
    self.loadedCreativeType = 0;
    self.advertRequestInProgress = YES;
    
    if(!self.adQueue) {
        self.adQueue = [self.queueManager getCreativesQueueForFullscreen];
    }
    if (self.adQueue.count < 1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No ad types in queue!" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        return;
    }
    
    
    MobFoxCreative* chosenCreative = [self.queueManager getCreativeFromQueue:self.adQueue];
    
    switch (chosenCreative.type) {
        case MobFoxCreativeBanner: {
            [self requestStaticInterstitial];
            break;
        }

        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Chosen creative type not supported for interstitials!" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(interstitialFailedWithError:) withObject:error waitUntilDone:YES];
        }
    }

}

-(void)dealloc {
    self.delegate = nil;
    [self.videoInterstitialViewController removeFromParentViewController];
    self.videoInterstitialViewController.delegate = nil;
    self.videoInterstitialViewController = nil;
    self.viewController = nil;
}

- (void) requestStaticInterstitial {
    //SEEDS_TODO: make this a setting
    self.videoInterstitialViewController.requestURL = @"http://devdash.playseeds.com";//@"http://my.mobfox.com/request.php";
    self.videoInterstitialViewController.enableInterstitialAds = YES;
    [self.videoInterstitialViewController requestAd];
}

- (void) showAd {
    switch (self.loadedCreativeType) {
        case MobFoxCreativeBanner: {
            [self.videoInterstitialViewController presentAd:MobFoxAdTypeText];
            break;
        }

        default: {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Cannot display interstitial, as it is not properly loaded." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self.delegate mobfoxDidFailToLoadWithError:error];
        }
    }

}

- (void) reportAdLoaded {
    self.adQueue = nil;
    self.advertRequestInProgress = NO;
    [self.delegate mobfoxInterstitialDidLoad];
}

- (void)interstitialFailedWithError:(NSError *)error
{

    if(self.adQueue.count > 0) {
        [self requestAdInternal];
    } else {
        self.adQueue = nil;
        self.advertRequestInProgress = NO;
        [self.delegate mobfoxDidFailToLoadWithError:error];
    }
}

#pragma mark VideoInterstitialViewController delegate methods
- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    return [self.delegate publisherIdForMobFoxInterstitial];
}

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType {
    self.loadedCreativeType = MobFoxCreativeBanner;

    [self reportAdLoaded];
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error {
    [self interstitialFailedWithError:error];
}

- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    if ([self.delegate respondsToSelector:@selector(mobfoxInterstitialWillPresent)])
    {
        [self.delegate mobfoxInterstitialWillPresent];
    }
}

- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    if ([self.delegate respondsToSelector:@selector(mobfoxInterstitialActionWillFinish)])
    {
        [self.delegate mobfoxInterstitialActionWillFinish];
    }
}

@end
