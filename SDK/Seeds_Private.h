//
//  Seeds(Private).h
//  Seeds
//
//  Created by Igor Dorofix on 6/29/17.
//
//

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR) && (!SEEDS_TARGET_WATCHKIT)
#import <UIKit/UIKit.h>
#endif

@protocol SeedsInAppMessageDelegate;

@interface Seeds()

@property (nonatomic, copy) NSString* deviceId;
@property (atomic, retain) id<SeedsInAppMessageDelegate> inAppMessageDelegate;
@property (atomic, assign) BOOL adClicked;

+ (instancetype)sharedInstance;

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum;

- (void)recordUserDetails:(NSDictionary *)userDetails;

- (void)recordIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

- (void)recordSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

- (void)requestInAppMessage:(NSString *)messageId withManualLocalizedPrice:(NSString*)price;

- (BOOL)isInAppMessageLoaded:(NSString*)messageId;

- (void)showInAppMessage:(NSString*)messageId in:(UIViewController*)viewController withContext:(NSString*)messageContext;

@end

