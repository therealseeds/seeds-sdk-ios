//
//  ViewController.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "ViewController.h"

@interface ViewController () <MobFoxVideoInterstitialViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.interstitial = [[MobFoxVideoInterstitialViewController alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.requestURL = @"http://devdash.playseeds.com";
    self.interstitial.enableInterstitialAds = YES;
    [self.view addSubview:self.interstitial.view];
}

- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType {
    [self.interstitial presentAd:MobFoxAdTypeText];
}

- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Failed to load %@", error);
}

- (NSString *)publisherIdForMobFoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)videoInterstitial {
    return @"test";
}

- (IBAction)iapEvent:(id)sender {
    [[Seeds sharedInstance] recordEvent:@"ios_iap" count:1 sum:0.99];
}

- (IBAction)seedsIapEvent:(id)sender {
    [[Seeds sharedInstance] recordEvent:@"ios_seeds_iap" count:1 sum:0.99];
}

- (IBAction)showIAM:(id)sender {
    [self.interstitial requestAd];
}

@end
