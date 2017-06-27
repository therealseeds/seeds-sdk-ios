//
//  SeedsEvents.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsEvents.h"
#import "Seeds.h"

NSString* const kEventSumKey = @"EventSumKey";
NSString* const kEventCountKey = @"EventCountKey";

@implementation SeedsEvents {
    Seeds *seedsInstance;
}

- (instancetype)initWithSeeds:(Seeds *)seeds {
    self = [super init];
    if (self) {
        seedsInstance = seeds;
    }
    return self;
}

- (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters {
    [seedsInstance recordEvent:eventKey segmentation:parameters count:[parameters[kEventCountKey] intValue] sum:[parameters[kEventSumKey] doubleValue]];
}

- (void)logUserInfo:(NSDictionary *)userInfo {
    [seedsInstance recordUserDetails:userInfo];
}

- (void)logIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId {
    [seedsInstance recordIAPEvent:key price:price transactionId:transactionId];
}

- (void)logSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId {
    [seedsInstance recordSeedsIAPEvent:key price:price transactionId:transactionId];
}

@end
