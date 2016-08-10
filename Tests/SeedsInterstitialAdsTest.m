//
//  SeedsInterstitialAdsTest.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 05/08/2016.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>
#import "SeedsInterstitialAds.h"

NSString *messageId;
SeedsInterstitialAds *seedsInterstitialAdsMock;
MobFoxVideoInterstitialViewController *mockVideoController;

@interface SeedsInterstitialAdsTest : XCTestCase

@end

@implementation SeedsInterstitialAdsTest

- (void)setUp {
    [super setUp];
    messageId = @"messageId";
    seedsInterstitialAdsMock = OCMClassMock([SeedsInterstitialAds class]);
    mockVideoController = OCMClassMock([MobFoxVideoInterstitialViewController class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void) testRequestInAppMessage {
    
    
}

- (void) testIsInAppMessageLoaded {
    [[SeedsInterstitialAds sharedInstance] requestInAppMessage:messageId];
    XCTAssertFalse([[SeedsInterstitialAds sharedInstance] isInAppMessageLoaded:messageId]);
}

- (void) testShowInAppMessage {
    UIViewController *mockController = OCMClassMock([UIViewController class]);
    [seedsInterstitialAdsMock showInAppMessage:messageId in:mockController];
    OCMVerify([seedsInterstitialAdsMock showInAppMessage:messageId in:mockController]);
}

- (void) testPublisherIdForMobFoxVideoInterstitialView {
    NSString *publisherId = [[SeedsInterstitialAds sharedInstance] publisherIdForMobFoxVideoInterstitialView:mockVideoController];
    
    XCTAssertNotNil(publisherId);
}

- (void) testMobFoxVideoInterstitialViewDidLoadMobFoxAd {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialViewDidLoadMobFoxAd:mockVideoController advertTypeLoaded:0];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialViewDidLoadMobFoxAd:mockVideoController advertTypeLoaded:0]);
}

- (void) testMobFoxVideoInterstitialView {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialView:mockVideoController didFailToReceiveAdWithError:nil];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialView:mockVideoController didFailToReceiveAdWithError:nil]);
}

- (void) testMobfoxVideoInterstitialViewActionWillPresentScreen {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialViewActionWillPresentScreen:mockVideoController];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialViewActionWillPresentScreen:mockVideoController]);
}

- (void) testMobfoxVideoInterstitialViewDidDismissScreen {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialViewDidDismissScreen:mockVideoController];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialViewDidDismissScreen:mockVideoController]);
}

- (void) testMobfoxVideoInterstitialViewActionWillLeaveApplication {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialViewActionWillLeaveApplication:mockVideoController];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialViewActionWillLeaveApplication:mockVideoController]);
}

- (void) testMobfoxVideoInterstitialViewWasClicked {
    [seedsInterstitialAdsMock mobfoxVideoInterstitialViewWasClicked:mockVideoController];
    OCMVerify([seedsInterstitialAdsMock mobfoxVideoInterstitialViewWasClicked:mockVideoController]);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
