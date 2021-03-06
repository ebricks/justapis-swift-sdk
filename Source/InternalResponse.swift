//
//  InternalResponse.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/30/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

internal protocol InternalResponseProperties : ResponseProperties
{
    var internalRequest:InternalRequest? { get }
}

internal struct MutableInternalResponseProperties : InternalResponseProperties
{
    var gateway:Gateway
    var request:Request
    var requestedURL:NSURL
    var resolvedURL:NSURL?
    var statusCode:Int
    var headers:Headers
    var body:NSData?
    var parsedBody:AnyObject?
    var retreivedFromCache:Bool
    var internalRequest:InternalRequest? { get { return request as? InternalRequest } }

    init(_ response:InternalResponseProperties)
    {
        self.gateway = response.gateway
        self.request = response.request
        self.requestedURL = response.requestedURL
        self.resolvedURL = response.resolvedURL
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = response.body
        self.parsedBody = response.parsedBody
        self.retreivedFromCache = response.retreivedFromCache
    }
    
}

///
/// Internal immutable implementation of Response Protocol
///
internal struct InternalResponse: Response, InternalResponseProperties
{
    typealias ResponseType = InternalResponse

    let gateway:Gateway
    let request:Request
    let requestedURL:NSURL
    let resolvedURL:NSURL?
    let statusCode:Int
    let headers:Headers
    let body:NSData?
    let parsedBody:AnyObject?
    let retreivedFromCache:Bool
    var internalRequest:InternalRequest? { get { return request as? InternalRequest } }
    
    init(_ response:InternalResponseProperties)
    {
        self.gateway = response.gateway
        self.request = response.request
        self.requestedURL = response.requestedURL
        self.resolvedURL = response.resolvedURL
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = response.body
        self.parsedBody = response.parsedBody
        self.retreivedFromCache = response.retreivedFromCache
    }
    
    init(_ gateway:CompositedGateway, response:ResponseProperties)
    {
        self.gateway = gateway
        self.request = response.request
        self.requestedURL = response.requestedURL
        self.resolvedURL = response.resolvedURL
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = response.body
        self.parsedBody = response.parsedBody
        self.retreivedFromCache = response.retreivedFromCache
    }

    func getMutableProperties() -> MutableInternalResponseProperties
    {
        return MutableInternalResponseProperties(self)
    }
}

extension InternalResponse : ResponseBuilderMethods
{
    func gateway(value: Gateway) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.gateway = value
        return InternalResponse(properties)
    }
    
    func request(value: Request) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.request = value
        return InternalResponse(properties)
    }
        
    func requestedURL(value: NSURL) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.requestedURL = value
        return InternalResponse(properties)
    }
    
    func resolvedURL(value: NSURL) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.resolvedURL = value
        return InternalResponse(properties)
    }
    
    func statusCode(value: Int) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.statusCode = value
        return InternalResponse(properties)
    }
    
    func headers(value: Headers) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.headers = value
        return InternalResponse(properties)
    }
    
    func header(key: String, value: String?) -> InternalResponse {
        var properties = self.getMutableProperties()
        
        if let value = value
        {
            properties.headers[key] = value
        }
        else
        {
            properties.headers.removeValueForKey(key)
        }
        return InternalResponse(properties)
    }
    
    func body(value: NSData?) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.body = value
        return InternalResponse(properties)
    }
    
    func parsedBody(value: AnyObject?) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.parsedBody = value
        return InternalResponse(properties)
    }
    
    func retreivedFromCache(value: Bool) -> InternalResponse {
        var properties = self.getMutableProperties()
        properties.retreivedFromCache = value
        return InternalResponse(properties)
    }
}