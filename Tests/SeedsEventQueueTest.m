//
//  SeedsEventQueueTest.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 05/08/2016.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>
#import "SeedsEventQueue.h"

SeedsEventQueue *seedsEventQueueMock;

@interface SeedsEventQueueTest : XCTestCase

@end

@implementation SeedsEventQueueTest

- (void)setUp {
    [super setUp];
    seedsEventQueueMock = OCMClassMock([SeedsEventQueue class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void) testCount {
    NSUInteger countStub = 4;
    
    OCMStub([seedsEventQueueMock count]).andReturn(countStub);
    
    NSUInteger count = [seedsEventQueueMock count];
    
    XCTAssertEqual(countStub, count);
    OCMVerify([seedsEventQueueMock count]);
}

- (void) testEvents {
    NSString *eventStub = @"new event";
    
    OCMStub([seedsEventQueueMock events]).andReturn(eventStub);
    
    XCTAssertEqual(eventStub, [seedsEventQueueMock events]);
    OCMVerify([seedsEventQueueMock events]);
}

- (void) testRecordEvent {
    [seedsEventQueueMock recordEvent:nil count:4];
    OCMVerify([seedsEventQueueMock recordEvent:nil count:4]);
    
    [seedsEventQueueMock recordEvent:nil count:4 sum:0.98];
    OCMVerify([seedsEventQueueMock recordEvent:nil count:4 sum:0.98]);
    
    [seedsEventQueueMock recordEvent:nil segmentation:@{} count:4];
    OCMVerify([seedsEventQueueMock recordEvent:nil segmentation:@{} count:4]);
    
    [seedsEventQueueMock recordEvent:nil segmentation:@{} count:3 sum:4.5];
    OCMVerify([seedsEventQueueMock recordEvent:nil segmentation:@{} count:3 sum:4.5]);
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
