//
//  SeedsEventQueue.h
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#pragma mark - SeedsEventQueue

@interface SeedsEventQueue : NSObject
- (NSUInteger)count;
- (NSString *)events;
- (void)recordEvent:(NSString *)key count:(int)count;
- (void)recordEvent:(NSString *)key count:(int)count sum:(double)sum;
- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count;
- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum;
@end