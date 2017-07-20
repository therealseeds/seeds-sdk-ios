//
//  SeedsInAppMessageDelegate.h
//  Seeds
//
//  Created by Alexey Pelykh on 8/14/15.
//
//

@class SeedsInAppMessage;

@protocol SeedsInAppMessageDelegate <NSObject>

@optional

// Callback signatures for an app with a single interstitial
- (void)seedsInAppMessageLoadSucceeded;
- (void)seedsInAppMessageShown:(BOOL)success;
- (void)seedsNoInAppMessageFound;
- (void)seedsInAppMessageClicked;
- (void)seedsInAppMessageDismissed;

// Callback signatures for an app with multiple interstitials
- (void)seedsInAppMessageLoadSucceeded:(NSString*)messageId;
- (void)seedsInAppMessageShown:(NSString*)messageId withSuccess:(BOOL)success;
- (void)seedsNoInAppMessageFound:(NSString*)messageId;
- (void)seedsInAppMessageClicked:(NSString*)messageId;
- (void)seedsInAppMessageDismissed:(NSString*)messageId;

// Use only if your interstitial enables the user to choose from multiple price tags
- (void)seedsInAppMessageClicked:(NSString *)messageId withDynamicPrice:(NSString *)price;

@end
