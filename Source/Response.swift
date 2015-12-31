//
//  Response.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/29/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// Properties that define a Response.
///
public protocol ResponseProperties
{
    /// The Gateway from which this response was generated
    var gateway:Gateway { get }
    
    /// The Request that was ultimately submitted to the gateway
    var request:Request { get }
    
    /// The final URL that was sent to the gateway (prior to redirection)
    var requestedURL:NSURL { get }
    
    /// The final URL of the request (after any redirection)
    var resolvedURL:NSURL? { get }
    
    /// The HTTP status code returned by the server
    var statusCode:Int { get }
    
    /// HTTP headers returned by the server
    var headers:Headers { get }
    
    /// Any body data returned by the server
    var body:NSData? { get }

    /// Any parsed body data
    var parsedBody:AnyObject? { get }
    
    /// TODO: Add cache data (did this come from the cache? how old is it?)
    
}

public protocol ResponseBuilderMethods
{
    /// Returns a new Response with gateway set to the provided value
    func gateway(value:Gateway) -> Self
    
    /// Returns a new Response with request set to the provided value
    func request(value:Request) -> Self
    
    /// Returns a new Response with requestedURL set to the provided value
    func requestedURL(value:NSURL) -> Self
    
    /// Returns a new Response with resolvedURL set to the provided value
    func resolvedURL(value:NSURL) -> Self
    
    /// Returns a new Response with statusCode set to the provided value
    func statusCode(value:Int) -> Self
    
    /// Returns a new Response with all headers set to the provided value
    func headers(value:Headers) -> Self
    
    /// Returns a new Response with a header with the provided key set to the provided value
    func header(key:String, value:String?) -> Self
    
    /// Returns a new Response with body set to the provided value
    func body(value:NSData?) -> Self
    
    /// Returns a new Response with parsedBody set to the provided value
    func parsedBody(value:AnyObject?) -> Self
}

public protocol Response : ResponseProperties, ResponseBuilderMethods
{
    
}

///
/// Basic mutable representation of public Response properties
///
public struct MutableResponseProperties : ResponseProperties
{
    public var gateway:Gateway
    public var request:Request
    public var requestedURL:NSURL
    public var resolvedURL:NSURL?
    public var statusCode:Int
    public var headers:Headers
    public var body:NSData?
    public var parsedBody:AnyObject?

    public init(gateway:Gateway, request:Request, requestedURL:NSURL, resolvedURL:NSURL, statusCode:Int, headers:Headers, body:NSData?, parsedBody:AnyObject?) {
        self.gateway = gateway
        self.request = request
        self.requestedURL = requestedURL
        self.resolvedURL = resolvedURL
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.parsedBody = parsedBody
    }
}