//
//  SeedsTest.m
//  Seeds
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>
#import "SeedsCore.h"
#import "SeedsConnectionQueue.h"
#import "SeedsInterstitialAds.h"

NSString *appKey;
NSString *appHost;
NSString *deviceId;
Seeds *seedsMock;

@interface SeedsTest : XCTestCase

@end

@implementation SeedsTest

- (void)setUp {
    [super setUp];
    appKey = @"1234";
    appHost = @"www.testurl.com";
    deviceId = nil;
    seedsMock = OCMClassMock([Seeds class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void) testStart {
    [[Seeds sharedInstance] start:appKey withHost: appHost];
    
    XCTAssertEqual(appKey, [[Seeds sharedInstance] getAppKey]);
    XCTAssertTrue([[Seeds sharedInstance] isStarted]);
    XCTAssertNotEqual(deviceId, [[Seeds sharedInstance] deviceId]);
}

- (void) testStartWithDeviceId {
    deviceId = @"Iphone 5s";
    [[Seeds sharedInstance] start:appKey withHost:appHost andDeviceId:deviceId];
    
    XCTAssertEqual(appKey, [[Seeds sharedInstance] getAppKey]);
    XCTAssertEqual(appKey, [[SeedsInterstitialAds sharedInstance] appKey]);
    XCTAssertEqual(appKey, [[SeedsConnectionQueue sharedInstance] appKey]);
    XCTAssertEqual(appHost, [[SeedsConnectionQueue sharedInstance] appHost]);
    XCTAssertEqual(appHost, [[SeedsInterstitialAds sharedInstance] appHost]);

    XCTAssertTrue([[Seeds sharedInstance] isStarted]);
    XCTAssertNotNil([[Seeds sharedInstance] deviceId]);
    XCTAssertEqual(deviceId, [[Seeds sharedInstance] deviceId]);
}

// Mock this method to test properly
- (void) testStartWithTestMessagingUsing {
    [[Seeds sharedInstance] startWithTestMessagingUsing:appKey withHost:appHost andOptions:nil];
    
    XCTAssertEqual(appKey, [[Seeds sharedInstance] getAppKey]);
    XCTAssertTrue([[Seeds sharedInstance] isStarted]);
    XCTAssertNotEqual(deviceId, [[Seeds sharedInstance] deviceId]);
    XCTAssertTrue([[SeedsConnectionQueue sharedInstance] startedWithTest]);
}

- (void) testSeedsNotificationCategories {
    NSMutableSet *categories = [[Seeds sharedInstance] seedsNotificationCategories];
    
    XCTAssertNotNil(categories);
    XCTAssertEqual(3, categories.count);
}

- (void) testSeedsNotificationCategoriesWithActionTitles {
    NSArray *actions = @[@"Open", @"Update", @"Review", @""];
    
    NSMutableSet *categories = [[Seeds sharedInstance] seedsNotificationCategoriesWithActionTitles:actions];
    
    XCTAssertNotNil(categories);
    XCTAssertEqual(3, categories.count);
}

- (void) testRecordEvent {
    [seedsMock recordEvent:appKey count:2];
    OCMVerify([seedsMock recordEvent:appKey count:2]);
    
    [seedsMock recordEvent:appKey count:3 sum:10];
    OCMVerify([seedsMock recordEvent:appKey count:3 sum:10]);
    
    [seedsMock recordEvent:appKey segmentation:nil count:1];
    OCMVerify([seedsMock recordEvent:appKey segmentation:nil count:1]);
    
    [seedsMock recordEvent:appKey segmentation: nil count:4 sum:2];
    OCMVerify([seedsMock recordEvent:appKey segmentation: nil count:4 sum:2]);
}

- (void) testRecordUserDetails {
    [seedsMock recordUserDetails:@{}];
    OCMVerify([seedsMock recordUserDetails:@{}]);
}

- (void) testTrackPurchase {
    [seedsMock trackPurchase:appKey price:0.99];
    OCMVerify([seedsMock trackPurchase:appKey price:0.99]);
}

- (void) testRecordIAPEvent {
    [seedsMock recordIAPEvent:appKey price:0.99];
    OCMVerify([seedsMock recordIAPEvent:appKey price:0.99]);
}

- (void) testSeedsIAPEvent {
    [seedsMock recordSeedsIAPEvent:appKey price:0.99];
    OCMVerify([seedsMock recordSeedsIAPEvent:appKey price:0.99]);
}

- (void) testRequestInAppMessage {
    [seedsMock requestInAppMessage];
    OCMVerify([seedsMock requestInAppMessage]);
    
    [seedsMock requestInAppMessage:@"testString"];
    OCMVerify([seedsMock requestInAppMessage:@"testString"]);
}

- (void) testIsMessageLoaded {
    BOOL isLoaded = [[Seeds sharedInstance] isInAppMessageLoaded];
    XCTAssertFalse(isLoaded);
    
    isLoaded = [[Seeds sharedInstance] isInAppMessageLoaded:@"testString"];
    XCTAssertFalse(isLoaded);
}

- (void) testShowInAppMessage {
    UIViewController* mockController = OCMClassMock(UIViewController.class);
    
    [seedsMock showInAppMessageIn:mockController];
    OCMVerify([seedsMock showInAppMessageIn:mockController]);
    
    [seedsMock showInAppMessage:@"testString" in:mockController];
    OCMVerify([seedsMock showInAppMessage:@"testString" in:mockController]);
}

- (void) testSetLocation {
    [seedsMock setLocation:3.44 longitude:8.99];
    OCMVerify([seedsMock setLocation:3.44 longitude:8.99]);
}

- (void) testHandleRemoteNotification {
    BOOL isHandled = [[Seeds sharedInstance] handleRemoteNotification:nil];
    XCTAssertFalse(isHandled);
    
    isHandled = [[Seeds sharedInstance] handleRemoteNotification:nil withButtonTitles:nil];
    XCTAssertFalse(isHandled);
}

- (void) testRecordPushOpenForSeedsDictionary {
    [seedsMock recordPushOpenForSeedsDictionary:nil];
    OCMVerify([seedsMock recordPushOpenForSeedsDictionary:nil]);
}

- (void) testRecordPushActionForSeedsDictionary {
    [seedsMock recordPushActionForSeedsDictionary:nil];
    OCMVerify([seedsMock recordPushActionForSeedsDictionary:nil]);
}

- (void) testDidRegisterForRemoteNotificationWithDeviceToken {
    [seedsMock didRegisterForRemoteNotificationsWithDeviceToken:nil];
    OCMVerify([seedsMock didRegisterForRemoteNotificationsWithDeviceToken:nil]);
}

- (void) testDidFailToREgisterForRemoteNotification {
    [seedsMock didFailToRegisterForRemoteNotifications];
     OCMVerify([seedsMock didFailToRegisterForRemoteNotifications]);
}

- (void) testStartCrashReporting {
    [seedsMock startCrashReporting];
    OCMVerify([seedsMock startCrashReporting]);
}

- (void) testStartCrashReportingWithSegments {
    [seedsMock startCrashReportingWithSegments:@{}];
    OCMVerify([seedsMock startCrashReportingWithSegments:@{}]);
}

- (void) testRecordHandledException {
    [seedsMock recordHandledException:nil];
    OCMVerify([seedsMock recordHandledException:nil]);
}

- (void) testCrashTest {
    [seedsMock crashTest];
    OCMVerify([seedsMock crashTest]);
}

- (void) testCrashTest2 {
    [seedsMock crashTest2];
    OCMVerify([seedsMock crashTest2]);
}

- (void) testCrashTest3 {
    [seedsMock crashTest3];
    OCMVerify([seedsMock crashTest3]);
}

- (void) testCrashTest4 {
    [seedsMock crashTest4];
    OCMVerify([seedsMock crashTest4]);
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
