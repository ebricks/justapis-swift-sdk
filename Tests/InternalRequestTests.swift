//
//  InternalRequestTests.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 1/5/16.
//  Copyright © 2016 AnyPresence. All rights reserved.
//

import XCTest
@testable import JustApisSwiftSDK

class InternalRequestTests: XCTestCase {

    private let mockRequestDefaults:MutableRequestProperties = MutableRequestProperties(
        method: "GET",
        path: "/",
        params: ["foo":"bar"],
        headers: ["foo-header":"bar-value"],
        body: nil,
        followRedirects: true,
        applyContentTypeParsing: true,
        contentTypeOverride: "test/content-type",
        allowCachedResponse: false,
        cacheResponseWithExpiration: 0,
        customCacheIdentifier: nil)
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHashableProtocolSupport()
    {
        let gateway:CompositedGateway = CompositedGateway(baseUrl: NSURL(string:"http://localhost")!)

        let request = gateway.internalizeRequest(self.mockRequestDefaults)
            .path("/abc")
            .params(["a":1,"b":2])
        
        let requestWithDifferentMethod = request.method("POST")
        let requestWithBarelyDifferentPath = request.path("/abc/")
        let requestWithVeryDifferentPath = request.path("/foo/bar/test")
        let requestWithBarelyDifferentParams = request.params(["a":1,"b":3])
        let requestWithOtherReorderedParams = request.params(["b":2,"a":1])
        let requestWithVeryDifferentParams = request.params(["sessionID":"adakjlasdlkjsadljkaffa="])
        let requestWithDifferentBody = request.body("test".dataUsingEncoding(NSUTF8StringEncoding))
        
        // These requests should be equal!
        XCTAssertEqual(request, request)
        XCTAssertEqual(request, requestWithOtherReorderedParams)
        XCTAssertEqual(request, requestWithDifferentBody)

        // These requests should be unequal!
        XCTAssertNotEqual(request, requestWithDifferentMethod)
        XCTAssertNotEqual(request, requestWithBarelyDifferentPath)
        XCTAssertNotEqual(request, requestWithVeryDifferentPath)
        XCTAssertNotEqual(request, requestWithBarelyDifferentParams)
        XCTAssertNotEqual(request, requestWithVeryDifferentParams)
    }
    
    func testBuilderMethods()
    {
        let gateway:CompositedGateway = CompositedGateway(baseUrl: NSURL(string:"http://localhost")!)
        
        let request = gateway.internalizeRequest(self.mockRequestDefaults)

        XCTAssertEqual(request.method("TEST").method, "TEST")
        XCTAssertEqual(request.path("/abc").path, "/abc")
        XCTAssertEqual(request.params(["a":"test"]).params?["a"] as? String, "test")
        XCTAssertEqual(request.headers(["b":"test"]).headers?["b"], "test")
        XCTAssertEqual(request.body("test".dataUsingEncoding(NSUTF8StringEncoding)).body, "test".dataUsingEncoding(NSUTF8StringEncoding))
        XCTAssertEqual(request.body("test".dataUsingEncoding(NSUTF8StringEncoding)).body, "test".dataUsingEncoding(NSUTF8StringEncoding))
        XCTAssertEqual(request.followRedirects(false).followRedirects, false)
        XCTAssertEqual(request.followRedirects(true).followRedirects, true)

        XCTAssertEqual(request.applyContentTypeParsing(false).applyContentTypeParsing, false)
        XCTAssertEqual(request.applyContentTypeParsing(true).applyContentTypeParsing, true)
        XCTAssertEqual(request.contentTypeOverride("test/test").contentTypeOverride, "test/test")

        XCTAssertEqual(request.allowCachedResponse(false).allowCachedResponse, false)
        XCTAssertEqual(request.allowCachedResponse(true).allowCachedResponse, true)

        XCTAssertEqual(request.cacheResponseWithExpiration(10).cacheResponseWithExpiration, 10)
        XCTAssertEqual(request.cacheResponseWithExpiration(100).cacheResponseWithExpiration, 100)
        
        XCTAssertEqual(request.customCacheIdentifier("testCacheIdentifier").customCacheIdentifier, "testCacheIdentifier")
    }
    
    func testInitFromMutableRequestProperties()
    {
        func XCTAssertEqualDictionaries<S, T: Equatable>(first: [S:T], _ second: [S:T]) {
            XCTAssert(first == second)
        }
        
        let gateway:CompositedGateway = CompositedGateway(baseUrl: NSURL(string:"http://localhost")!)
        let props = self.mockRequestDefaults
        let request = gateway.internalizeRequest(self.mockRequestDefaults)

        XCTAssertEqual(request.method, props.method)
        XCTAssertEqual(request.path, props.path)
        XCTAssertEqual(request.body, props.body)
        XCTAssertEqual(request.params?["foo"] as? String, "bar")
        if (request.headers != nil || props.headers != nil)
        {
            XCTAssertEqualDictionaries(request.headers!, props.headers!)
        }
        XCTAssertEqual(request.followRedirects, props.followRedirects)
        XCTAssertEqual(request.applyContentTypeParsing, props.applyContentTypeParsing)
        XCTAssertEqual(request.contentTypeOverride, props.contentTypeOverride)
        XCTAssertEqual(request.allowCachedResponse, props.allowCachedResponse)
        XCTAssertEqual(request.cacheResponseWithExpiration, props.cacheResponseWithExpiration)
        XCTAssertEqual(request.customCacheIdentifier, props.customCacheIdentifier)
    }
}
