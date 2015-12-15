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
        // TODO
    }

    ///
    /// Tests basic combination of a scheme:host:port/path baseURL and a Request path
    ///
    func testRelativePathAppend()
    {
        // TODO
    }
    
    ///
    /// Tests invalid baseURL during request prep
    ///
    func testInvalidBaseUrl()
    {
        
    }
    
    ///
    /// Tests invalid request path during request prep
    ///
    func testInvalidRequestPath()
    {
        
    }
    
    ///
    /// Tests that simple query parameters are appended to URL properly
    ///
    func testQueryParameterEncoding()
    {
        
    }
    
    ///
    /// Tests that unusual query parameters are appended to URL properly
    ///
    func testComplexQueryParameterEncoding()
    {
        
    }
    
    ///
    /// Tests that headers are encoded as expected
    ///
    func testHeaderEncoding()
    {
        
    }
    
    ///
    /// Tests that default headers are applied when using DefaultFieldsRequestPreparer
    ///
    func testDefaultHeaders()
    {
        
    }
    
    ///
    /// Tests that default query parameters are applied when using a DefaultFieldsRequestPreparer
    ///
    func testDefaultQueryParameters()
    {
        
    }
    
    ///
    /// Tests that the RequestPreparerClosureAdapter can modify requests
    ///
    func testRequestClosureAdapterModification()
    {
        
    }
    
    ///
    /// Tests that the RequestPreparereClosureAdapter can validate and reject requests
    ///
    func testRequestClosureAdapterError()
    {
        
    }
}
