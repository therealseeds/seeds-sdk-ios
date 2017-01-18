//
//  SeedsConnectionQueue.h
//  Seeds
//

#pragma mark - SeedsConnectionQueue

@interface SeedsConnectionQueue : NSObject

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appHost;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic) BOOL startedWithTest;
@property (nonatomic, copy) NSString *locationString;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
#endif

+ (instancetype)sharedInstance;
- (void)beginSession;
- (void) tick;
- (void)sendUserDetails;
- (void)recordEvents:(NSString *)events;
- (void)updateSessionWithDuration:(int)duration;
- (void)endSessionWithDuration:(int)duration;
- (void)tokenSession:(NSString *)token;
- (void)storeCrashReportToTryLater:(NSString *)report;

@end
