//
//  SeedsInterstitial.h
//  Seeds
//
//  Created by Dmitriy Romanov on 6/23/17.
//
//

#import <Foundation/Foundation.h>

@interface SeedsInterstitial: NSObject

@property (nonatomic, readonly) NSString *messageId;
@property (nonatomic, readonly) NSString *price;

- (instancetype)initWithId:(NSString *)messageId;
- (instancetype)initWithId:(NSString *)messageId price:(NSString *)price;

@end
