//
//  BasicResponses.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

/// ImmutableResponse where body data is left an unprocessed NSData blob
typealias FoundationImmutableResponse = ImmutableResponse<NSData>

/// MutableResponse where body data is left as an unprocessed NSData blob
typealias FoundationMutableResponse = MutableResponse<NSData>

///
/// Minimal implementation of Response Protocol
///
public struct ImmutableResponse<BDT> : Response
{
    public typealias BodyDataType = BDT
    public typealias MutableType = MutableResponse<BDT>
    
    public let gateway:Gateway
    public let request:Request
    public let requestedURL:NSURL
    public let resolvedURL:NSURL
    public let statusCode:Int
    public let headers:Headers
    public let body:BodyDataType?
    
    public init(gateway:Gateway, request:Request, requestedURL:NSURL, resolvedURL:NSURL, statusCode:Int, headers:Headers, body:BodyDataType?)
    {
        self.gateway = gateway
        self.request = request
        self.requestedURL = requestedURL
        self.resolvedURL = resolvedURL
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
    
    public init(_ response:MutableType)
    {
        self.gateway = response.gateway
        self.request = response.request
        self.requestedURL = response.requestedURL
        self.resolvedURL = response.resolvedURL
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = response.body
    }
    
    public func mutableCopy() -> MutableType
    {
        return MutableResponse(self)
    }
}

///
/// Minimal mutable implementation of Response Protocol
///
public class MutableResponse<BDT> : Response
{
    public typealias BodyDataType = BDT
    public typealias ImmutableType = ImmutableResponse<BDT>

    public var gateway:Gateway
    public var request:Request
    public var requestedURL:NSURL
    public var resolvedURL:NSURL
    public var statusCode:Int
    public var headers:Headers
    public var body:BodyDataType?

    public init(gateway:Gateway, request:Request, requestedURL:NSURL, resolvedURL:NSURL, statusCode:Int, headers:Headers, body:BodyDataType?)
    {
        self.gateway = gateway
        self.request = request
        self.requestedURL = requestedURL
        self.resolvedURL = resolvedURL
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
    
    public init(_ response:ImmutableType)
    {
        self.gateway = response.gateway
        self.request = response.request
        self.requestedURL = response.requestedURL
        self.resolvedURL = response.resolvedURL
        self.statusCode = response.statusCode
        self.headers = response.headers
        self.body = response.body
    }
    
    public func immutableCopy() -> ImmutableType
    {
        return ImmutableResponse(self)
    }
}