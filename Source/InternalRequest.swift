//
//  GatewayRequest.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/30/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// Internal, strongly-typed extension of RequestProperties
///
internal protocol InternalRequestProperties : RequestProperties
{
    var gateway:CompositedGateway { get }
}

///
/// A mutable representation of Request properties, used in builders.
///
internal struct MutableInternalRequestProperties : InternalRequestProperties
{
    var gateway:CompositedGateway
    var method:String
    var path:String
    var params:QueryParameters?
    var headers:Headers?
    var body:NSData?
    var followRedirects:Bool
    
    init(_ request:InternalRequestProperties)
    {
        self.gateway = request.gateway
        self.method = request.method
        self.path = request.path
        self.params = request.params
        self.headers = request.headers
        self.body = request.body
        self.followRedirects = request.followRedirects
    }
}

///
/// Immutable internal implementation of Request protocol
///
internal struct InternalRequest : Request, InternalRequestProperties, Hashable
{
    let gateway:CompositedGateway
    let method:String
    let path:String
    let params:QueryParameters?
    let headers:Headers?
    let body:NSData?
    let followRedirects:Bool
    
    init(gateway:CompositedGateway, method:String, path:String, params:QueryParameters? = nil, headers:Headers? = nil, body:NSData? = nil, followRedirects:Bool = true)
    {
        self.gateway = gateway
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.body = body
        self.followRedirects = followRedirects
    }
    
    init(_ request:InternalRequestProperties)
    {
        self.gateway = request.gateway
        self.method = request.method
        self.path = request.path
        self.params = request.params
        self.headers = request.headers
        self.body = request.body
        self.followRedirects = request.followRedirects
    }
    
    init(_ gateway:CompositedGateway, request:RequestProperties)
    {
        self.gateway = gateway
        self.method = request.method
        self.path = request.path
        self.params = request.params
        self.headers = request.headers
        self.body = request.body
        self.followRedirects = request.followRedirects
    }
    
    func getMutableProperties() -> MutableInternalRequestProperties
    {
        return MutableInternalRequestProperties(self)
    }
    
    func calculateHash()
    {
        
    }

    // TODO - !!! implement a better hash !!!
    var hashValue:Int { return "\(self.method) \(self.path) \(self.params) \(self.headers)".hashValue }
}

///
/// Builder methods, returning a new (immutable) InternalRequest with altered properties
///
extension InternalRequest : RequestBuilderMethods
{
    func gateway(value:CompositedGateway) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.gateway = value
        return InternalRequest(properties);
    }
    
    func method(value: String) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.method = value
        return InternalRequest(properties);
    }
    
    func path(value: String) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.path = value
        return InternalRequest(properties);
    }
    
    func params(value: QueryParameters?) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.params = value
        return InternalRequest(properties);
    }
    
    func param(key: String, _ value: AnyObject?) -> InternalRequest {
        var properties = self.getMutableProperties()
        if nil == properties.params && value != nil
        {
            properties.params = QueryParameters()
        }
        
        if let value = value
        {
            properties.params![key] = value
        }
        else
        {
            properties.params!.removeValueForKey(key)
        }
        return InternalRequest(properties);
    }
    
    func headers(value: Headers?) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.headers = value
        return InternalRequest(properties);
    }
    
    func header(key: String, _ value: String?) -> InternalRequest {
        var properties = self.getMutableProperties()
        if nil == properties.headers && value != nil
        {
            properties.headers = Headers()
        }
        
        if let value = value
        {
            properties.headers![key] = value
        }
        else
        {
            properties.headers!.removeValueForKey(key)
        }
        return InternalRequest(properties);
    }
    
    func body(value: NSData?) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.body = value
        return InternalRequest(properties);
    }
    
    func followRedirects(value: Bool) -> InternalRequest {
        var properties = self.getMutableProperties()
        properties.followRedirects = value
        return InternalRequest(properties);
    }
}

func ==(lhs: InternalRequest, rhs: InternalRequest) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
