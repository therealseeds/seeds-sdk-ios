//
//  SeedsEvent.h
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#pragma mark - SeedsEvent

#import <CoreData/NSManagedObject.h>

@interface SeedsEvent : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, retain) NSDictionary *segmentation;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) double sum;
@property (nonatomic, assign) NSTimeInterval timestamp;

- (void)dealloc;
+ (SeedsEvent*)objectWithManagedObject:(NSManagedObject*)managedObject;
- (NSDictionary*)serializedData;

@end