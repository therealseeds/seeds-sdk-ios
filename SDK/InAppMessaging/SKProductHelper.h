//
//  SKProductHelper.h
//  Seeds
//
//  Created by Alexey Pelykh on 6/24/16.
//
//

#ifndef SKProductHelper_h
#define SKProductHelper_h

#import <StoreKit/StoreKit.h>

@interface SKProductHelper : NSObject

+ (SKProduct*)productWithIdentifier:(NSString*)productId;

@end

#endif /* SKProductHelper_h */
