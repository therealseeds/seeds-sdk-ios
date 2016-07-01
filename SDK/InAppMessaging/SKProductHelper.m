//
//  SKProductHelper.m
//  Seeds
//
//  Created by Alexey Pelykh on 6/24/16.
//
//

#import "SKProductHelper.h"

@implementation SKProductHelper

- (void)getProductsByIdentifiers:(NSArray *)productsId withResult:(void (^)(NSArray *products, NSError *error))block{

    if (!block) {
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    productResultBlock = [block copy];

    _request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productsId]];

    _request.delegate = self;

    [_request start];

}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{

    NSLog(@"responce - %@", response);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    productResultBlock(response.products, nil);

}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{

    NSLog(@"error - %@", error.localizedDescription);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    productResultBlock(nil, error);

}

@end
