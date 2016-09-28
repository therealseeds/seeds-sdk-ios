//
//  SeedsEventQueue.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#import <Foundation/Foundation.h>
#import "SeedsEventQueue.h"
#import "SeedsDB.h"
#import "SeedsEvent.h"
#import "SeedsUrlFormatter.h"

@interface SeedsEventQueue()
@end

@implementation SeedsEventQueue

- (NSUInteger)count
{
    @synchronized (self)
    {
        return [[SeedsDB sharedInstance] getEventCount];
    }
}


- (NSString *)events
{
    NSMutableArray* result = [NSMutableArray array];
    
    @synchronized (self)
    {
        NSArray* events = [[[SeedsDB sharedInstance] getEvents] copy];
        for (id managedEventObject in events)
        {
            SeedsEvent* event = [SeedsEvent objectWithManagedObject:managedEventObject];
            
            [result addObject:event.serializedData];
            
            [SeedsDB.sharedInstance deleteEvent:managedEventObject];
        }
    }
    
    return SeedsURLEscapedString(SeedsJSONFromObject(result));
}

- (void)recordEvent:(NSString *)key count:(int)count
{
    @synchronized (self)
    {
        SeedsEvent *event = [SeedsEvent new];
        event.key = key;
        event.count = count;
        event.timestamp = time(NULL);
        
        [[SeedsDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key count:(int)count sum:(double)sum
{
    @synchronized (self)
    {
        SeedsEvent *event = [SeedsEvent new];
        event.key = key;
        event.count = count;
        event.sum = sum;
        event.timestamp = time(NULL);
        
        [[SeedsDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count;
{
    @synchronized (self)
    {
        SeedsEvent *event = [SeedsEvent new];
        event.key = key;
        event.segmentation = segmentation;
        event.count = count;
        event.timestamp = time(NULL);
        
        [[SeedsDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum;
{
    @synchronized (self)
    {
        SeedsEvent *event = [SeedsEvent new];
        event.key = key;
        event.segmentation = segmentation;
        event.count = count;
        event.sum = sum;
        event.timestamp = time(NULL);
        
        [[SeedsDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

@end
