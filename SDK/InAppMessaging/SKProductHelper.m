//
//  SKProductHelper.m
//  Seeds
//
//  Created by Alexey Pelykh on 6/24/16.
//
//

#import "SKProductHelper.h"

@interface SKProductHelper ()

@end

@interface SKProductRequestHandler : NSObject <SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *lastRequest;
@property (nonatomic, strong) SKProductsResponse *lastResponse;
@property (nonatomic, strong) NSError *lastError;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (void)requestDidFinish:(SKRequest *)request;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;

- (void)startAndWait:(SKProductsRequest*)request;

@end

@implementation SKProductHelper

+ (SKProduct*)productWithIdentifier:(NSString*)productId
{
    SKProductRequestHandler *handler = [[SKProductRequestHandler alloc] init];

    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                  [NSSet setWithObjects:productId, nil]];

    [handler startAndWait:request];

    if (handler.lastResponse != nil && handler.lastResponse.products.count > 0)
        return [handler.lastResponse.products objectAtIndex:0];

    return nil;
}

@end

@implementation SKProductRequestHandler
{
    dispatch_semaphore_t semaphore;
}

@synthesize lastRequest;
@synthesize lastResponse;
@synthesize lastError;

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.lastRequest = request;
    self.lastResponse = response;
}

- (void)requestDidFinish:(SKRequest *)request
{
    self.lastRequest = (SKProductsRequest *)request;

    dispatch_semaphore_signal(semaphore);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.lastRequest = (SKProductsRequest *)request;
    self.lastError = error;

    dispatch_semaphore_signal(semaphore);
}

- (void)startAndWait:(SKProductsRequest*)request
{
    semaphore = dispatch_semaphore_create(0);

    request.delegate = self;
    [request start];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end