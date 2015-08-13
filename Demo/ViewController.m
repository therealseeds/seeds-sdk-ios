//
//  ViewController.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "ViewController.h"

@interface ViewController () <MobFoxInterstitialDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.interstitial = [[MobFoxInterstitialViewController alloc] initWithViewController:self];
    self.interstitial.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mobfoxInterstitialDidLoad {
    [self.interstitial showAd];
}

- (void)mobfoxDidFailToLoadWithError:(NSError *)error {
    NSLog(@"Failed to load %@", error);
}

- (NSString*)publisherIdForMobFoxInterstitial {
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
