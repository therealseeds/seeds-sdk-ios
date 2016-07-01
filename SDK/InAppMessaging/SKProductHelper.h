//
//  SKProductHelper.h
//  Seeds
//
//  Created by Alexey Pelykh on 6/24/16.
//
//

#ifndef SKProductHelper_h
#define SKProductHelper_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProductHelper : NSObject <SKProductsRequestDelegate> {

    void (^productResultBlock)(NSArray *products, NSError *error);

}

@property (strong, nonatomic) SKProductsRequest *request;

- (void)getProductsByIdentifiers:(NSArray *)productsId withResult:(void (^)(NSArray *products, NSError *error))block;

@end

#endif /* SKProductHelper_h */
