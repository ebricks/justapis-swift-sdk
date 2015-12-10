//
//  BasicRequests.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation


///
/// Minimal implementation of Request protocol
///
public struct ImmutableRequest : Request
{
    public let method:String
    public let path:String
    public let params:QueryParameters?
    public let headers:Headers?
    public let body:NSData?
    public let followRedirects:Bool
    
    public init(method:String, path:String, params:QueryParameters? = nil, headers:Headers? = nil, body:NSData? = nil, followRedirects:Bool = false)
    {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.body = body
        self.followRedirects = followRedirects
    }
    
    /// Initializes with values provided in the given request
    public init(_ request:Request)
    {
        self.method = request.method
        self.path = request.path
        self.params = request.params
        self.headers = request.headers
        self.body = request.body
        self.followRedirects = request.followRedirects
    }
    
    /// Returns a mutable copy of this request
    public func mutableCopy() -> MutableRequest
    {
        return MutableRequest(self)
    }
}

///
/// Minimal mutable implementation of Request protocol
///
public class MutableRequest : Request
{
    public var method:String
    public var path:String
    public var params:QueryParameters?
    public var headers:Headers?
    public var body:NSData?
    public var followRedirects:Bool
    
    public init(method:String, path:String, params:QueryParameters? = nil, headers:Headers? = nil, body:NSData? = nil, followRedirects:Bool = false)
    {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.body = body
        self.followRedirects = followRedirects
    }
    
    /// Initializes with values provided in the given request
    public init(_ request:Request)
    {
        self.method = request.method
        self.path = request.path
        self.params = request.params
        self.headers = request.headers
        self.body = request.body
        self.followRedirects = request.followRedirects
    }
    
    /// Returns an immutable copy of this request
    public func immutableCopy() -> ImmutableRequest
    {
        return ImmutableRequest(self)
    }
}
