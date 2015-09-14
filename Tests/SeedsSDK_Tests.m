//
//  SeedsSDK_Tests.m
//  SeedsSDK Tests
//
//  Created by Alexey Pelykh on 9/14/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Seeds.h"
#import "SeedsInAppMessageDelegate.h"
#import "TestViewController.h"

#define YOUR_SERVER @"http://devdash.playseeds.com"
#define YOUR_APP_KEY @"aa1fd1f255b25fb89b413f216f11e8719188129d"

@interface SeedsSDK_Tests : XCTestCase <SeedsInAppMessageDelegate> {

    BOOL _seedsInAppMessageLoaded;
    BOOL _seedsInAppMessageShown;
    BOOL _seedsNotFound;
    TestViewController *_testVC;

}

@end

@implementation SeedsSDK_Tests

- (void)setUp {
    
    [super setUp];

    [Seeds.sharedInstance start:YOUR_APP_KEY withHost:YOUR_SERVER];
    [Seeds sharedInstance].inAppMessageDelegate = self;
    _testVC = [[TestViewController alloc] init];
    
}

- (void)tearDown {

//    [Seeds sharedInstance].inAppMessageDelegate = nil;
    
    [super tearDown];
    
}

- (void)testSeedInAppMessageShown {

    NSDate *fiveSeconds = [NSDate dateWithTimeIntervalSinceNow:5.0];
    
    if ([[Seeds sharedInstance] isInAppMessageLoaded]) {
        [[Seeds sharedInstance] showInAppMessageIn:_testVC];
    } else {
        [[Seeds sharedInstance] requestInAppMessage];
    }

    [[NSRunLoop currentRunLoop] runUntilDate:fiveSeconds];
    
    XCTAssertTrue(_seedsInAppMessageShown, @"in app message not shown");
    XCTAssertTrue(_seedsInAppMessageLoaded, @"not loaded");
    XCTAssertFalse(_seedsNotFound, @"not found");


}

#pragma mark - SeedsInAppMessageDelegate

- (void)seedsInAppMessageLoadSucceeded:(SeedsInAppMessage*)inAppMessage {

    _seedsInAppMessageLoaded = YES;
    [[Seeds sharedInstance] showInAppMessageIn:_testVC];

}

- (void)seedsNoInAppMessageFound {
    _seedsNotFound = YES;
}

@end
