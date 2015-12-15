//
//  FoundationRequestTests.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/15/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import XCTest

///
/// Tests request building when using the FoundationNetworkAdapter
///
class FoundationRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    ///
    /// Tests basic combination of a scheme:host:port baseURL and a Request path
    ///
    func testSimplePathAppend()
    {
        XCTFail("Test not implemented!");
    }

    ///
    /// Tests basic combination of a scheme:host:port/path baseURL and a Request path
    ///
    func testRelativePathAppend()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests invalid baseURL during request prep
    ///
    func testInvalidBaseUrl()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests invalid request path during request prep
    ///
    func testInvalidRequestPath()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that simple query parameters are appended to URL properly
    ///
    func testQueryParameterEncoding()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that unusual query parameters are appended to URL properly
    ///
    func testComplexQueryParameterEncoding()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that headers are encoded as expected
    ///
    func testHeaderEncoding()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that default headers are applied when using DefaultFieldsRequestPreparer
    ///
    func testDefaultHeaders()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that default query parameters are applied when using a DefaultFieldsRequestPreparer
    ///
    func testDefaultQueryParameters()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the RequestPreparerClosureAdapter can modify requests
    ///
    func testRequestClosureAdapterModification()
    {
        XCTFail("Test not implemented!");
    }
    
    ///
    /// Tests that the RequestPreparereClosureAdapter can validate and reject requests
    ///
    func testRequestClosureAdapterError()
    {
        XCTFail("Test not implemented!");        
    }
}
