//
//  ViewController.m
//  iOS Demo
//
//  Created by Alexey Pelykh on 8/13/15.
//
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SeedsInAppMessageDelegate.h"

@interface ViewController () <SeedsInAppMessageDelegate>

@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    Seeds.sharedInstance.inAppMessageDelegate = self;
}

- (void)seedsInAppMessageClicked:(NSString*)messageId {
    NSLog(@"seedsInAppMessageClicked(%@)", messageId);
}

- (void)seedsInAppMessageClicked:(NSString *)messageId withDynamicPrice:(double)price {
    NSLog(@"seedsInAppMessageClicked(%@), price = %@", messageId, @(price));
    [Seeds.sharedInstance recordSeedsIAPEvent:IAP_KEY price:0.99];
}

- (void)seedsInAppMessageDismissed:(NSString*)messageId {
    NSLog(@"seedsInAppMessageDismissed(%@)", messageId);
}

- (void)seedsInAppMessageLoadSucceeded:(NSString *)messageId {
    NSLog(@"seedsInAppMessageLoadSucceeded(%@)", messageId);
}

- (void)seedsInAppMessageShown:(NSString*)messageId withSuccess:(BOOL)success {
    NSLog(@"seedsInAppMessageShown(%@), success = %@", messageId, success ? @"YES" : @"NO");
}

- (void)seedsNoInAppMessageFound:(NSString*)messageId {
    NSLog(@"seedsNoInAppMessageFound(%@)", messageId);
}

- (IBAction)iapEvent:(id)sender {
    [Seeds.sharedInstance recordIAPEvent:@"ios_iap" price:0.99];


    // TODO: Create a separate button for user queries
    [Seeds.sharedInstance requestInAppMessageShowCount:^(NSString *errorMessage, int showCount) {
        if(errorMessage == nil)
            NSLog(@"requestInAppMessageShowCount(%@): %i", MESSAGE_ID_0, showCount);
    } of: MESSAGE_ID_0];

    [Seeds.sharedInstance requestTotalInAppMessageShowCount:^(NSString *errorMessage, int showCount) {
        if(errorMessage == nil)
            NSLog(@"requestTotalInAppMessageShowCount: %i", showCount);
    }];

    [Seeds.sharedInstance requestInAppPurchaseCount:^(NSString *errorMessage, int purchaseCount) {
        if(errorMessage == nil)
            NSLog(@"requestInAppPurchaseCount(%@): %i", IAP_KEY, purchaseCount);
    } of: IAP_KEY];

    [Seeds.sharedInstance requestTotalInAppPurchaseCount:^(NSString *errorMessage, int purchaseCount) {
        if (errorMessage == nil)
            NSLog(@"requestTotalInAppPurchaseCount: %i", purchaseCount);
    }];
}

- (IBAction)seedsIapEvent:(id)sender {
    [Seeds.sharedInstance recordSeedsIAPEvent:@"ios_seeds_iap" price:0.99];
}

- (IBAction)showIAM0:(id)sender {
    if ([Seeds.sharedInstance isInAppMessageLoaded:MESSAGE_ID_0])
        [Seeds.sharedInstance showInAppMessage:MESSAGE_ID_0 in:self withContext: @"in-demo-app"];
    else
        [Seeds.sharedInstance requestInAppMessage:MESSAGE_ID_0];
}

- (IBAction)showIAM1:(id)sender {   
    if ([Seeds.sharedInstance isInAppMessageLoaded:MESSAGE_ID_1])
        [Seeds.sharedInstance showInAppMessage:MESSAGE_ID_1 in:self withContext: @"in-demo-app"];
    else
        [Seeds.sharedInstance requestInAppMessage:MESSAGE_ID_1];
}

@end
