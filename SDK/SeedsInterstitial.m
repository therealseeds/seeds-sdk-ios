//
//  SeedsInterstitial.m
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import "SeedsInterstitial.h"

@implementation SeedsInterstitial

- (instancetype)initWithId:(NSString *)messageId {
    return [self initWithId:messageId price:0];
}

- (instancetype)initWithId:(NSString *)messageId price:(NSString *)price {
    self = [super init];
    if (self) {
        _messageId = messageId;
        _price = price;
    }
    return self;
}

@end
