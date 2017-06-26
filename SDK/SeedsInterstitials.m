//
//  SeedsInterstitials.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsInterstitials.h"
#import "Seeds.h"

@implementation SeedsInterstitials {
    Seeds *seedsInstance;    
}

- (instancetype)initWithSeeds:(Seeds *)seeds {
    self = [super init];
    if (self) {
        seedsInstance = seeds;
    }
    return self;
}

- (void)fetchWithId:(NSString *)interstitialId manualPrice:(NSString *)manualPrice {
    //TODO
}

- (BOOL)isLoadedWithId:(NSString *)interstitialId {
    //TODO
    return false;
}

- (void)showWithId:(NSString *)interstitialId onViewController:(UIViewController *)viewController inContext:(NSString *)context {
    //TODO
}

- (void)addEventsHandler:(id<SeedsInterstitialsEventProtocol>)eventsHandler withInterstitialId:(NSString *)interstitialId {
    //TODO
}

- (void)removeEventsHandler:(id<SeedsInterstitialsEventProtocol>)eventsHandler {
    //TODO
}

- (void)clearAllEventsHandlers {
    //TODO
}

@end
