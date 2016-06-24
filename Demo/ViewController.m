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

- (void)seedsInAppMessageClicked:(SeedsInAppMessage*)inAppMessage withMessageId:(NSString*)messageId {
    NSLog(@"seedsInAppMessageClicked(%@)", messageId);
}

- (void)seedsInAppMessageClosed:(SeedsInAppMessage*)inAppMessage withMessageId:(NSString*)messageId andCompleted:(BOOL)completed {
    NSLog(@"seedsInAppMessageClosed(%@), completed = %@", messageId, completed ? @"YES" : @"NO");
}

- (void)seedsInAppMessageLoadSucceeded:(SeedsInAppMessage*)inAppMessage withMessageId:(NSString*)messageId {
    NSLog(@"seedsInAppMessageLoadSucceeded(%@)", messageId);
    [Seeds.sharedInstance showInAppMessage:messageId in:self];
}

- (void)seedsInAppMessageShown:(SeedsInAppMessage*)inAppMessage withMessageId:(NSString*)messageId withSuccess:(BOOL)success {
    NSLog(@"seedsInAppMessageShown(%@), success = %@", messageId, success ? @"YES" : @"NO");
}

- (void)seedsNoInAppMessageFound:(NSString*)messageId {
    NSLog(@"seedsNoInAppMessageFound(%@)", messageId);
}

- (IBAction)iapEvent:(id)sender {
    [Seeds.sharedInstance recordIAPEvent:@"ios_iap" price:0.99];
    //[Seeds.sharedInstance trackPurchase:@"ios_iap" price:0.99];
}

- (IBAction)seedsIapEvent:(id)sender {
    [Seeds.sharedInstance recordSeedsIAPEvent:@"ios_seeds_iap" price:0.99];
}

- (IBAction)showIAM0:(id)sender {
    if ([Seeds.sharedInstance isInAppMessageLoaded:MESSAGE_ID_0])
        [Seeds.sharedInstance showInAppMessage:MESSAGE_ID_0 in:self];
    else
        [Seeds.sharedInstance requestInAppMessage:MESSAGE_ID_0];
}

- (IBAction)showIAM1:(id)sender {
    if ([Seeds.sharedInstance isInAppMessageLoaded:MESSAGE_ID_1])
        [Seeds.sharedInstance showInAppMessage:MESSAGE_ID_1 in:self];
    else
        [Seeds.sharedInstance requestInAppMessage:MESSAGE_ID_1];
}

- (void)handleUrl:(NSURL*)url {
    NSLog(@"url = %@", url);
    [self.urlLabel setText:[NSString stringWithFormat:@"InApp URL: %@", url]];

    [Seeds.sharedInstance recordSeedsIAPEvent:@"deep-link-item" price:0.99];
}

@end
