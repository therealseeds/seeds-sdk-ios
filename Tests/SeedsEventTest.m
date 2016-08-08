//
//  SeedsEventTest.m
//  Seeds
//
//  Created by Obioma Ofoamalu on 05/08/2016.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMockObject.h>
#import <OCMock/OCMock.h>
#import "SeedsEvent.h"

SeedsEvent *seedsEventMock;

@interface SeedsEventTest : XCTestCase

@end

@implementation SeedsEventTest

- (void)setUp {
    [super setUp];
    seedsEventMock = OCMClassMock([SeedsEvent class]);
}

- (void)tearDown {
    [super tearDown];
}

- (void) testSerializedData {
    NSDictionary *dataStub = @{};
    OCMStub([seedsEventMock serializedData]).andReturn(dataStub);
    
    XCTAssertEqual(dataStub, [seedsEventMock serializedData]);
    OCMVerify([seedsEventMock serializedData]);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
