//
//  SeedsEvents.h
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import <Foundation/Foundation.h>

extern NSString* const kEventSumKey;
extern NSString* const kEventCountKey;

@class Seeds;

@interface SeedsEvents: NSObject

- (instancetype)initWithSeeds:(Seeds *)seeds;

- (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters;

- (void)logUserInfo:(NSDictionary *)userInfo;

- (void)logIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

- (void)logSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

@end
