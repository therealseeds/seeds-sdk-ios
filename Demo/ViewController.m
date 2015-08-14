//
//  ViewController.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "ViewController.h"
#import "SeedsInAppMessageDelegate.h"

@interface ViewController () <SeedsInAppMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    [Seeds sharedInstance].inAppMessageDelegate = self;
}

- (void)seedsInAppMessageLoadSucceeded:(SeedsInAppMessage*)inAppMessage {
    [[Seeds sharedInstance] showInAppMessageIn:self];
}

- (IBAction)iapEvent:(id)sender {
    [[Seeds sharedInstance] recordIAPEvent:@"ios_iap" price:0.99];
}

- (IBAction)seedsIapEvent:(id)sender {
    [[Seeds sharedInstance] recordSeedsIAPEvent:@"ios_seeds_iap" price:0.99];
}

- (IBAction)showIAM:(id)sender {
    [[Seeds sharedInstance] requestInAppMessage];
}

@end
