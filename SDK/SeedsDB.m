// CountlyDB.m
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.
//
// Changed by Oleksii Pelykh
//
// Changes: renamed from 'CountlyDB'; changed resources lookup method;
//

#import "SeedsDB.h"

#ifndef SEEDS_DEBUG
#define SEEDS_DEBUG 0
#endif

#if SEEDS_DEBUG
#   define SEEDS_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define SEEDS_LOG(...)
#endif

//#   define SEEDS_APP_GROUP_ID @"group.example.myapp"
#if SEEDS_TARGET_WATCHKIT
#   ifndef SEEDS_APP_GROUP_ID
#       error "Application Group Identifier not specified! Please uncomment the line above and specify it."
#   endif
#import <WatchKit/WatchKit.h>
#endif

/*
Seeds iOS SDK WatchKit Support
================================
To use Seeds iOS SDK in WatchKit apps:
1) While adding Seeds iOS SDK files to the project, make sure you select WatchKit Extension target too.
   (Or add them manually to WatchKit Extension target's Build Settings > Compile Sources section)
2) Add "-DCOUNTLY_TARGET_WATCHKIT=1" flag to "Other C Flags" under WatchKit Extension target's Build Settings
3) For both WatchKit Extension target and Container App target enable App Groups under Capabilities section. 
   ( For details: http://is.gd/ConfiguringAppGroups )
4) Uncomment SEEDS_APP_GROUP_ID line and specify Application Group Identifier there
5) Inside awakeWithContext:(id)context method of your watch app's main entry point (InterfaceController.m by default), start Seeds as usual
    [Seeds.sharedInstance start:@"YOUR_APP_KEY" withHost:@"https://YOUR_API_HOST.com"];
6) That's it. You should see a new session on your Dashboard, when you run WatchKit Extension target. 
   And you can record custom events as usual. 
*/

@interface SeedsDB()
@end

@implementation SeedsDB

+(instancetype)sharedInstance
{
    static SeedsDB* s_sharedSeedsDB;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{s_sharedSeedsDB = self.new;});
	return s_sharedSeedsDB;
}

-(void)createEvent:(NSString*) eventKey count:(double)count sum:(double)sum segmentation:(NSDictionary*)segmentation timestamp:(NSTimeInterval)timestamp
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];

    [newManagedObject setValue:eventKey forKey:@"key"];
    [newManagedObject setValue:@(count) forKey:@"count"];
    [newManagedObject setValue:@(sum) forKey:@"sum"];
    [newManagedObject setValue:@(timestamp) forKey:@"timestamp"];
    [newManagedObject setValue:segmentation forKey:@"segmentation"];
    
    [self saveContext];
}

-(void)deleteEvent:(NSManagedObject*)eventObj
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:eventObj];
    [self saveContext];
}

-(void)addToQueue:(NSString*)postData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Data" inManagedObjectContext:context];
    
#ifdef SEEDS_TARGET_WATCHKIT
    NSString* watchSegmentationKey = @"[CLY]_apple_watch";
    NSString* watchModel = (WKInterfaceDevice.currentDevice.screenBounds.size.width == 136.0)?@"38mm":@"42mm";
    NSString* segmentation = [NSString stringWithFormat:@"{\"%@\":\"%@\"}", watchSegmentationKey, watchModel];
    NSString* escapedSegmentation = (NSString*)CFBridgingRelease(
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)segmentation,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    postData = [postData stringByAppendingFormat:@"&segment=%@", escapedSegmentation];
#endif

    [newManagedObject setValue:postData forKey:@"post"];
    
    [self saveContext];
}

-(void)removeFromQueue:(NSManagedObject*)postDataObj
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:postDataObj];
    [self saveContext];
}

-(NSArray*) getEvents
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    NSArray* result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        SEEDS_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }
    
    return result;
}

-(NSArray*) getQueue
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Data" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    NSArray* result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
         SEEDS_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }
    
    return result;
}

-(NSUInteger)getEventCount
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        SEEDS_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }
    
    return count;
}

-(NSUInteger)getQueueCount
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Data" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        SEEDS_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }
    
    return count;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
           SEEDS_LOG(@"CoreData error %@, %@", error, [error userInfo]);
        }
    }
}

- (NSURL *)applicationSupportDirectory
{
    NSFileManager *fm = NSFileManager.defaultManager;
    NSURL *url = [[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:[url absoluteString]])
    {
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
        if(error) SEEDS_LOG(@"Can not create Application Support directory: %@", error);
    }

    return url;
}

#pragma mark - Core Data Instance

- (NSManagedObjectContext *)managedObjectContext
{
    static NSManagedObjectContext* s_managedObjectContext;
    
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil)
        {
            s_managedObjectContext = [[NSManagedObjectContext alloc] init];
            [s_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    });
    
    return s_managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    static NSManagedObjectModel* s_managedObjectModel;

    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSURL *resourcesBundleUrl = [[NSBundle mainBundle] URLForResource:@"SeedsResources" withExtension:@"bundle"];
        NSBundle *resourcesBundle = (resourcesBundleUrl != nil)
            ? [NSBundle bundleWithURL:resourcesBundleUrl]
            : [NSBundle bundleForClass:[SeedsDB class]];

        NSURL *modelURL = [resourcesBundle URLForResource:@"Seeds" withExtension:@"momd"];

        if (modelURL == nil)
            modelURL = [resourcesBundle URLForResource:@"Seeds" withExtension:@"mom"];
        
        s_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    });

    return s_managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static NSPersistentStoreCoordinator* s_persistentStoreCoordinator;
    
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        
        s_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSError *error=nil;
#ifdef SEEDS_APP_GROUP_ID
        NSURL *storeURL = [[NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:SEEDS_APP_GROUP_ID] URLByAppendingPathComponent:@"Seeds.sqlite"];
#else
        NSURL *storeURL = [[self applicationSupportDirectory] URLByAppendingPathComponent:@"Seeds.sqlite"];
#endif        
        [s_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        if(error)
            SEEDS_LOG(@"Store opening error %@", error);
        
        [storeURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        if(error)
            SEEDS_LOG(@"Unable to exclude Seeds persistent store from backups (%@), error: %@", storeURL.absoluteString, error);
    });

    return s_persistentStoreCoordinator;
}

@end
