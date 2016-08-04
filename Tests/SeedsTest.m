//
//  SeedsTest.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 03/08/2016.
//
//

#import <XCTest/XCTest.h>
#import "SeedsCore.h"
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>

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

- (void) testTrackPurchase {
//    
//    [seedsMock trackPurchase:appKey price:0.99];
//    OCMVerify([seedsMock trackPurchase:appKey price:0.99]);
//    OCMVerify([seedsMock recordIAPEvent:appKey price:0.99]);
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

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
