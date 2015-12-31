//
//  Request.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/29/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation


///
/// Properties that define a Request.
///
public protocol RequestProperties
{
    /// The HTTP Verb to use
    var method:String { get }
    
    // The path to request, relative to the Gateway's baseURL
    var path:String { get }
    
    // A Dictionary of query string parameters to append to the path
    var params:QueryParameters? { get }
    
    // HTTP headers to be sent with the request
    var headers:Headers? { get }
    
    // Any body data to send along with the request
    var body:NSData? { get }
    
    // Whether HTTP redirects should be followed before a response is handled
    var followRedirects:Bool { get }
    
    // TODO: add cache-control properties
    
    // TODO: add autoparse properties
}

///
/// Methods that provide a fluent syntax for building Requests
///
public protocol RequestBuilderMethods
{    
    /// Returns a new Request with the method set to the provided value
    func method(value:String) -> Self
    
    /// Returns a new Request with the path set to the provided value
    func path(value:String) -> Self
    
    /// Returns a new Request with all query params set to the provided value
    func params(value:QueryParameters?) -> Self
    
    /// Returns a new Request with a query parameter of the provided key set to the provided value
    func param(key:String, _ value:AnyObject?) -> Self
    
    /// Returns a new Request with all headers set to the provided value
    func headers(value:Headers?) -> Self
    
    /// Returns a new Request with a header of the provided key set to the provided value
    func header(key:String, _ value:String?) -> Self
    
    /// Returns a new Request with a body set to the provided value
    func body(value:NSData?) -> Self
    
    /// Returns a new Request with the HTTP redirect support flag set to the provided value
    func followRedirects(value:Bool) -> Self
}

///
/// A Request suitable for the JustApi SDK Gateway
///
public protocol Request : RequestProperties, RequestBuilderMethods
{
    
}

///
/// Basic mutable representation of public Request properties
///
public struct MutableRequestProperties : RequestProperties
{
    public var method:String
    public var path:String
    public var params:QueryParameters?
    public var headers:Headers?
    public var body:NSData?
    public var followRedirects:Bool
}

