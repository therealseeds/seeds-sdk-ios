//
//  SeedsConnectionQueueTest.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 05/08/2016.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>
#import "SeedsConnectionQueue.h"

SeedsConnectionQueue *seedsConnectionQueueMock;

@interface SeedsConnectionQueueTest : XCTestCase

@end

@implementation SeedsConnectionQueueTest

- (void)setUp {
    [super setUp];
    seedsConnectionQueueMock = OCMClassMock([SeedsConnectionQueue class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void) testTick {
    [seedsConnectionQueueMock tick];
    OCMVerify([seedsConnectionQueueMock tick]);
}

- (void) testBeginSession {
    [seedsConnectionQueueMock beginSession];
    OCMVerify([seedsConnectionQueueMock beginSession]);
}

- (void) testTokenSession {
    [seedsConnectionQueueMock tokenSession:nil];
    OCMVerify([seedsConnectionQueueMock tokenSession:nil]);
}

- (void) testUpdateSessionWithDuration {
    [seedsConnectionQueueMock updateSessionWithDuration:2];
    OCMVerify([seedsConnectionQueueMock updateSessionWithDuration:2]);
}

- (void) testEndSessionWithDuration {
    [seedsConnectionQueueMock endSessionWithDuration:2];
    OCMVerify([seedsConnectionQueueMock endSessionWithDuration:2]);
}

- (void) testSendUserDetails {
    [seedsConnectionQueueMock sendUserDetails];
    OCMVerify([seedsConnectionQueueMock sendUserDetails]);
}

- (void) testStoreCrashReportToTryLater {
    [seedsConnectionQueueMock storeCrashReportToTryLater:@"crash report"];
    OCMVerify([seedsConnectionQueueMock storeCrashReportToTryLater:@"crash report"]);
}

- (void) testRecordEvents {
    [seedsConnectionQueueMock recordEvents:@"new event"];
    OCMVerify([seedsConnectionQueueMock recordEvents:@"new event"]);
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
