//
//  SeedsEvents.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsEvents.h"
#import "Seeds.h"

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
    //TODO
}

@end
