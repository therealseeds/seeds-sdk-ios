//
//  SeedsEvent.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 04/08/2016.
//
//

#import <Foundation/Foundation.h>
#import "SeedsEvent.h"

@interface SeedsEvent()
@end

@implementation SeedsEvent

- (void)dealloc
{
    self.key = nil;
    self.segmentation = nil;
}

+ (SeedsEvent*)objectWithManagedObject:(NSManagedObject*)managedObject
{
    SeedsEvent* event = [SeedsEvent new];
    
    event.key = [managedObject valueForKey:@"key"];
    event.count = [[managedObject valueForKey:@"count"] doubleValue];
    event.sum = [[managedObject valueForKey:@"sum"] doubleValue];
    event.timestamp = [[managedObject valueForKey:@"timestamp"] doubleValue];
    event.segmentation = [managedObject valueForKey:@"segmentation"];
    return event;
}

- (NSDictionary*)serializedData
{
    NSMutableDictionary* eventData = NSMutableDictionary.dictionary;
    eventData[@"key"] = self.key;
    if (self.segmentation)
    {
        eventData[@"segmentation"] = self.segmentation;
    }
    eventData[@"count"] = @(self.count);
    eventData[@"sum"] = @(self.sum);
    eventData[@"timestamp"] = @(self.timestamp);
    return eventData;
}

@end
