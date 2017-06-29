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

extern NSString* const kSeedEventUserName;
extern NSString* const kSeedEventUserUsername;
extern NSString* const kSeedEventUserEmail;
extern NSString* const kSeedEventUserOrganization;
extern NSString* const kSeedEventUserPhone;
extern NSString* const kSeedEventUserGender;
extern NSString* const kSeedEventUserPicture;
extern NSString* const kSeedEventUserPicturePath;
extern NSString* const kSeedEventUserBirthYear;
extern NSString* const kSeedEventUserCustom;

@class Seeds;

@interface SeedsEvents: NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters;

- (void)logUserInfo:(NSDictionary *)userInfo;

- (void)logIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

- (void)logSeedsIAPEvent:(NSString *)key price:(double)price transactionId:(NSString *)transactionId;

@end
