//
//  FoundationResponseTests.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/15/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import XCTest
import JustApisSwiftSDK

class FoundationResponseTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    ///
    /// Tests that a 2xx Response is returned as a Response with no error
    ///
    func testResponseSuccess()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that 4xx respones are returned as a Response and an error
    ///
    func testResponse4xxFailure()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that body data is preserved in a successful Response
    ///
    func testBodyDataInResponse()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that headers are delivered and parsed in a successful Response
    ///
    func testHeadersInResponse()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that a followed, redirected URL is returned with a Response
    ///
    func testFollowedRedirect()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that a disallowed redirect is rejected and returned as an error
    ///
    func testRejectedRedirect()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the ResposeProcessorClosureAdapter may modify the returned response
    ///
    func testResponseClosureAdapterModification()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the ResponseProcessorClosureAdapter can signal an error
    ///
    func testResponseClosureAdapterError()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the JsonResponseProcessor can parse a JSON object in body
    ///
    func testJsonObjectResponse()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the JsonResponseProcessor can parse a JSON array in body
    ///
    func testJsonArrayResponse()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the JsonResponseProcessor produces an error for non-RFC JSON data
    ///
    func testJsonError()
    {
        XCTFail("Test not implemented!");
    }
    
}
