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

    Seeds.sharedInstance.inAppMessageDelegate = self;
}

- (void)seedsInAppMessageClicked:(SeedsInAppMessage*)inAppMessage {
    NSLog(@"seedsInAppMessageClicked");
}

- (void)seedsInAppMessageClosed:(SeedsInAppMessage*)inAppMessage andCompleted:(BOOL)completed {
    NSLog(@"seedsInAppMessageClosed, completed = %@", completed ? @"YES" : @"NO");
}

- (void)seedsInAppMessageLoadSucceeded:(SeedsInAppMessage*)inAppMessage {
    NSLog(@"seedsInAppMessageLoadSucceeded");
    [Seeds.sharedInstance showInAppMessageIn:self];
}

- (void)seedsInAppMessageShown:(SeedsInAppMessage*)inAppMessage withSuccess:(BOOL)success {
    NSLog(@"seedsInAppMessageShown, success = %@", success ? @"YES" : @"NO");
}

- (void)seedsNoInAppMessageFound {
    NSLog(@"seedsNoInAppMessageFound");
}

- (IBAction)iapEvent:(id)sender {
    [Seeds.sharedInstance recordIAPEvent:@"ios_iap" price:0.99];
    //[Seeds.sharedInstance trackPurchase:@"ios_iap" price:0.99];
}

- (IBAction)seedsIapEvent:(id)sender {
    [Seeds.sharedInstance recordSeedsIAPEvent:@"ios_seeds_iap" price:0.99];
}

- (IBAction)showIAM:(id)sender {
    if (Seeds.sharedInstance.isInAppMessageLoaded)
        [Seeds.sharedInstance showInAppMessageIn:self];
    else
        [Seeds.sharedInstance requestInAppMessage];
}

@end
