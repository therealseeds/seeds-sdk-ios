//
//  SeedsEvents.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsEvents.h"
#import "Seeds.h"
#import "Seeds_Private.h"

NSString* const kEventSumKey = @"EventSumKey";
NSString* const kEventCountKey = @"EventCountKey";

NSString* const kSeedEventUserName = @"name";
NSString* const kSeedEventUserUsername = @"username";
NSString* const kSeedEventUserEmail = @"email";
NSString* const kSeedEventUserOrganization = @"organization";
NSString* const kSeedEventUserPhone = @"phone";
NSString* const kSeedEventUserGender = @"gender";
NSString* const kSeedEventUserPicture = @"picture";
NSString* const kSeedEventUserPicturePath = @"picturePath";
NSString* const kSeedEventUserBirthYear = @"byear";
NSString* const kSeedEventUserCustom = @"custom";


@implementation SeedsEvents

- (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters {
    
    NSUInteger count = 1;
    if (parameters[kEventCountKey] != nil) {
        NSUInteger countValue = [parameters[kEventCountKey] unsignedIntegerValue];
        count = countValue > 0 ? countValue : 1;
    }
    
    double sum = 0;
    if (parameters[kEventSumKey] != nil) {
        sum = [parameters[kEventSumKey] doubleValue];
    }

    [[Seeds sharedInstance] recordEvent:eventKey segmentation:parameters count:(int)count sum:sum];
}

- (void)logUserInfo:(NSDictionary *)userInfo {
    [[Seeds sharedInstance] recordUserDetails:userInfo];
}

- (void)logIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId {
    [[Seeds sharedInstance] recordIAPEvent:key price:price transactionId:transactionId];
}

- (void)logSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId {
    [[Seeds sharedInstance] recordSeedsIAPEvent:key price:price transactionId:transactionId];
}

@end
