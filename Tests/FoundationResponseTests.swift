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
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNil(result.error)
            XCTAssert(result.response != nil)
            XCTAssertEqual(result.response!.statusCode, 200)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    ///
    /// Tests that 4xx respones are returned as a Response and no error
    ///
    func testResponse4xxFailure()
    {
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: NSData(), statusCode: 404, headers: nil)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNil(result.error) // 4xx not an error at this layer. Callback or responseProcessor can check
            XCTAssertNotNil(result.response)
            XCTAssertEqual(result.response!.statusCode, 404)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    ///
    /// Tests that a connection failure returns an error and no response
    ///
    func testConnectionFailure()
    {
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in

            let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue), userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNotNil(result.error) // 4xx not an error at this layer. Callback or responseProcessor can check
            XCTAssertNil(result.response)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    ///
    /// Tests that body data is preserved in a successful Response
    ///
    func testBodyDataInResponse()
    {
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        let body = "test".dataUsingEncoding(NSUTF8StringEncoding)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: body!, statusCode: 200, headers: nil)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.response)
            XCTAssertEqual(result.response!.body as? NSData, body!)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    ///
    /// Tests that headers are delivered and parsed in a successful Response
    ///
    func testHeadersInResponse()
    {
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        let body = "test".dataUsingEncoding(NSUTF8StringEncoding)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: body!, statusCode: 200, headers: nil)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.response)
            XCTAssertEqual(result.response!.headers["Content-Length"], "4")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
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
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        let body = "test".dataUsingEncoding(NSUTF8StringEncoding)
        let alternateBody = "rest".dataUsingEncoding(NSUTF8StringEncoding)

        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: body!, statusCode: 200, headers: nil)
        })
        
        let responseProcessor = ResponseProcessorClosureAdapter(closure: {
            (response) in
            let response = MutableResponse(response)
            response.body = alternateBody
            return (request:response.request, response: response, error:nil)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!, requestPreparer: nil, responseProcessor: responseProcessor)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.response)
            XCTAssertEqual(result.response!.body as? NSData, alternateBody)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    ///
    /// Tests that the ResponseProcessorClosureAdapter can signal an error
    ///
    func testResponseClosureAdapterError()
    {
        let baseUrl = "http://localhost"
        let requestPath = "test/request/path"
        let expectation = self.expectationWithDescription(self.name)
        let body = "test".dataUsingEncoding(NSUTF8StringEncoding)
        let alternateBody = "rest".dataUsingEncoding(NSUTF8StringEncoding)
        
        stub(isHost("localhost"), response: {
            (request:NSURLRequest) in
            
            return OHHTTPStubsResponse(data: body!, statusCode: 200, headers: nil)
        })
        
        let responseProcessor = ResponseProcessorClosureAdapter(closure: {
            (response) in
            let response = MutableResponse(response)
            response.body = alternateBody
            let error = NSError(domain: "JustApisSwiftSDK.ResponseProcessorClosureAdapter", code: -1, userInfo: nil)
            return (request:response.request, response: response, error:error)
        })
        
        let gateway:Gateway = CompositedGateway(baseUrl: NSURL(string: baseUrl)!, requestPreparer: nil, responseProcessor: responseProcessor)
        gateway.get(requestPath, callback: { (result) in
            XCTAssertNotNil(result.error)
            XCTAssertNotNil(result.response)
            XCTAssertEqual(result.response!.body as? NSData, alternateBody)
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
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
