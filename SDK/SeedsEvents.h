//
//  SeedsEvents.h
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import <Foundation/Foundation.h>

@class Seeds;

@interface SeedsEvents : NSObject

// TODO: add consts keys for eventKey, parameters

- (instancetype)initWithSeeds:(Seeds *)seeds;

- (void)logEventWithKey:(NSString *)eventKey parameters:(NSDictionary *)parameters;

@end
