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

    Seeds.sharedInstance.inAppMessageDelegate = self;
}


- (IBAction)showIAM0:(id)sender {
    [self showInterstitial:PURCHASE_INTERSTITIAL_ID withContext:@"in-store"];
}

- (IBAction)showIAM1:(id)sender {
    [self triggerPayment: ^() {
        [Seeds.sharedInstance recordIAPEvent:NORMAL_IAP_EVENT_KEY price:4.99];
        NSLog(@"Event %@ tracked as a non-Seeds purchase", NORMAL_IAP_EVENT_KEY);
    }];
}


- (void)triggerPayment: (void (^)(void))callback {
    UIAlertController * alert=   [UIAlertController
            alertControllerWithTitle:@"In-app purchase"
                             message:@"Do you want to confirm the in-app purchase? (Simulated payment)"
                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
            actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * action)
                    {
                        callback();
                    }];
    UIAlertAction* cancel = [UIAlertAction
            actionWithTitle:@"Cancel"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * action)
                    {
                        // No action taken
                    }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)seedsInAppMessageClicked:(NSString*)messageId {
    // Called when a user clicks the buy button. Handle the purchase here!
    // The interstitial is specified by messageId parameter
    if ([messageId isEqualToString:PURCHASE_INTERSTITIAL_ID]) {
        [self triggerPayment:^() {
            [Seeds.sharedInstance recordSeedsIAPEvent:SEEDS_IAP_EVENT_KEY price:0.99];
            NSLog(@"Event %@ tracked as a Seeds purchase", PURCHASE_INTERSTITIAL_ID);
            [self showInterstitial:SHARING_INTERSTITIAL_ID withContext:@"after-purchase"];
        }];
    }

    NSLog(@"seedsInAppMessageClicked(%@)", messageId);
}

- (void)seedsInAppMessageDismissed:(NSString*)messageId {
    // Called when a user dismisses the interstitial and no purchase is being made
    // The interstitial is specified by messageId parameter
    NSLog(@"seedsInAppMessageDismissed(%@)", messageId);
}

- (void)seedsInAppMessageLoadSucceeded:(NSString *)messageId {
    // Called when an interstitial is loaded
    // The interstitial is specified by messageId parameter
    if ([messageId isEqualToString: APP_LAUNCH_INTERSTITIAL_ID]) {
        [self showInterstitial:APP_LAUNCH_INTERSTITIAL_ID withContext:@"app startup"];
    }
    NSLog(@"seedsInAppMessageLoadSucceeded(%@)", messageId);
}

- (void)seedsInAppMessageShown:(NSString*)messageId withSuccess:(BOOL)success {
    // Called when an interstitial is successfully opened
    // The interstitial is specified by messageId parameter
    NSLog(@"seedsInAppMessageShown(%@), success = %@", messageId, success ? @"YES" : @"NO");
}

- (void)seedsNoInAppMessageFound:(NSString*)messageId {
    // Called when an interstitial couldn't be found or the preloading resulted in an error
    NSLog(@"seedsNoInAppMessageFound(%@)", messageId);
}

- (void)seedsInAppMessageClicked:(NSString *)messageId withDynamicPrice:(double)price {
    // Called when an interstitial has multiple price options, and a user chooses one of them
    // Not needed in applications where the user can't choose the price in the Seeds interstitial
    NSLog(@"seedsInAppMessageClicked(%@), price = %@", messageId, @(price));
}

- (void)showInterstitial: (NSString*)messageId withContext:(NSString*)context {
    if ([Seeds.sharedInstance isInAppMessageLoaded:messageId])
        [Seeds.sharedInstance showInAppMessage:messageId in:self withContext: context];
    else
        // Skip the interstitial showing this time and try to reload the interstitial
        [Seeds.sharedInstance requestInAppMessage:messageId];
}

@end
