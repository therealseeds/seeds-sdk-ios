//
//  SeedsSDK_Tests.m
//  SeedsSDK Tests
//
//  Created by Alexey Pelykh on 9/14/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SeedsCore.h"
#import "SeedsInAppMessageDelegate.h"
#import "TestViewController.h"

#define YOUR_SERVER @"http://devdash.playseeds.com"
#define YOUR_APP_KEY @"aa1fd1f255b25fb89b413f216f11e8719188129d"
#define YOUR_APP_KEY_NEVER @"ef2444ec9f590d24db5054fad8385991138a394b"
#define YOUR_APP_KEY_ALWAYS @"c30f02a55541cbe362449d29d83d777c125c8dd6"

@interface SeedsSDK_Tests : XCTestCase <SeedsInAppMessageDelegate> {

    BOOL _seedsInAppMessageLoaded;
    BOOL _seedsInAppMessageShown;
    BOOL _seedsNotFound;
    
    BOOL _seedsInAppMessageLoadedNever;
    BOOL _seedsInAppMessageShownNever;
    BOOL _seedsNotFoundNever;
    
    BOOL _seedsInAppMessageLoadedAlways;
    BOOL _seedsInAppMessageShownAlways;
    BOOL _seedsNotFoundAlways;
    
    UIViewController *_testVC;

}

@end

@implementation SeedsSDK_Tests

- (void)setUp {
    
    [super setUp];

    [Seeds sharedInstance].inAppMessageDelegate = self;

<<<<<<< HEAD
    _testVC = [[TestViewController alloc] init];
=======
    _testVC = OCMClassMock([UIViewController class]);
    Seeds.sharedInstance.inAppMessageVariantName = @"testVariantName";
>>>>>>> 210379b... Fix tests
    
}

- (void)tearDown {
    
    [super tearDown];
    
}

- (void)testSeedInAppMessageShown {

    [Seeds.sharedInstance start:YOUR_APP_KEY withHost:YOUR_SERVER];
    
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

- (void)testSeedInAppMessageShownNeverAds {
    
    [[Seeds sharedInstance] start:YOUR_APP_KEY_NEVER withHost:YOUR_SERVER];
    
    NSDate *fiveSeconds = [NSDate dateWithTimeIntervalSinceNow:5.0];
    
    if ([[Seeds sharedInstance] isInAppMessageLoaded]) {
        [[Seeds sharedInstance] showInAppMessageIn:_testVC];
    } else {
        [[Seeds sharedInstance] requestInAppMessage];
    }
    
    [[NSRunLoop currentRunLoop] runUntilDate:fiveSeconds];
    
    XCTAssertFalse(_seedsInAppMessageLoadedNever, @"Message loaded");

}

- (void)testSeedInAppMessageShownAlwaysAds {

    [[Seeds sharedInstance] start:YOUR_APP_KEY_ALWAYS withHost:YOUR_SERVER];
    
    NSDate *fiveSeconds = [NSDate dateWithTimeIntervalSinceNow:5.0];
    
    if ([[Seeds sharedInstance] isInAppMessageLoaded]) {
        [[Seeds sharedInstance] showInAppMessageIn:_testVC];
    } else {
        [[Seeds sharedInstance] requestInAppMessage];
    }
    
    [[NSRunLoop currentRunLoop] runUntilDate:fiveSeconds];
    
    XCTAssertTrue(_seedsInAppMessageLoadedAlways, @"Message not loaded");
    
}

#pragma mark - SeedsInAppMessageDelegate

- (void)seedsInAppMessageShown:(SeedsInAppMessage*)inAppMessage withSuccess:(BOOL)success {
    
    if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY]) {
        _seedsInAppMessageShown = success;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_NEVER]) {
        _seedsInAppMessageShownNever = success;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_ALWAYS]) {
        _seedsInAppMessageShownAlways = success;
    }
}

- (void)seedsInAppMessageLoadSucceeded:(SeedsInAppMessage*)inAppMessage {
    
    if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY]) {
        _seedsInAppMessageLoaded = YES;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_NEVER]) {
        _seedsInAppMessageLoadedNever = YES;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_ALWAYS]) {
        _seedsInAppMessageLoadedAlways = YES;
    }
    
    [[Seeds sharedInstance] showInAppMessageIn:_testVC];

}


- (void)seedsNoInAppMessageFound {

    if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY]) {
        _seedsNotFound = YES;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_NEVER]) {
        _seedsNotFoundNever = YES;
    } else if ([[[Seeds sharedInstance] getAppKey] isEqualToString:YOUR_APP_KEY_ALWAYS]) {
        _seedsNotFoundAlways = YES;
    }
}






//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
