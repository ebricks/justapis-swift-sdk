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
    ///
    /// Fundamental Request Properties:
    /// ----
    
    /// The HTTP Verb to use
    var method:String { get }
    
    /// The path to request, relative to the Gateway's baseURL
    var path:String { get }
    
    /// A Dictionary of query string parameters to append to the path
    var params:QueryParameters? { get }
    
    /// HTTP headers to be sent with the request
    var headers:Headers? { get }
    
    /// Any body data to send along with the request
    var body:NSData? { get }
    
    /// Whether HTTP redirects should be followed before a response is handled
    var followRedirects:Bool { get }

    ///
    /// Autoparsing Options, for use with the ContentTypeParser:
    /// ----

    /// Whether to use contentTypeParsing
    var applyContentTypeParsing:Bool { get }

    /// The Content-Type to assume for any results, disregarding response headers
    var contentTypeOverride:String? { get }
    
    
    ///
    /// Cache Control Options
    /// ----
    
    /// Whether to check the gateway's response cache before sending
    var allowCachedResponse:Bool { get }
    
    /// How long to store responses in the cache. 0 to not cache response at all
    var cacheResponseWithExpiration:UInt { get }
    
    /// A custom identifier to use for caching. Default is METHOD + PATH + PARAMS
    var customCacheIdentifier:String? { get }
    
}

extension RequestProperties
{
    /// Cache identifier: either the customCacheIdentifier if provided, or METHOD + PATH + PARAMS
    var cacheIdentifier:String { return customCacheIdentifier ?? "\(self.method) \(self.path)?\(self.params)" }
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
    
    /// Returns a new Request with applyContentTypeParsing set to the provided value
    func applyContentTypeParsing(value:Bool) -> Self
    
    /// Returns a new Request with contentTypeOverride set to the provided value
    func contentTypeOverride(value:String?) -> Self
    
    /// Returns a new Request with allowCachedResponse set to the provided value
    func allowCachedResponse(value:Bool) -> Self
    
    /// Returns a new Request with cacheResponseWithExpiration set to the provided value
    func cacheResponseWithExpiration(value:UInt) -> Self
    
    /// Returns a new Request with customCacheIdentifier set to the provided value
    func customCacheIdentifier(value:String?) -> Self
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

    public var applyContentTypeParsing:Bool = true
    public var contentTypeOverride:String? = nil
    
    public var allowCachedResponse:Bool = false
    public var cacheResponseWithExpiration:UInt = 0
    public var customCacheIdentifier:String? = nil
}

///
/// Provides default request properties to use for specific methods
///
public protocol DefaultRequestPropertySet
{
    var get:MutableRequestProperties { get }
    var post:MutableRequestProperties { get }
    var put:MutableRequestProperties { get }
    var delete:MutableRequestProperties { get }
}

///
/// An flexible implementation of the DefaultRequestPropertySet
///
public struct GatewayDefaultRequestProperties : DefaultRequestPropertySet
{
    public let get:MutableRequestProperties
    public let post:MutableRequestProperties
    public let put:MutableRequestProperties
    public let delete:MutableRequestProperties
    
    public init(
        get:MutableRequestProperties? = nil,
        post:MutableRequestProperties? = nil,
        put:MutableRequestProperties? = nil,
        delete:MutableRequestProperties? = nil)
    {
        self.get = get ?? MutableRequestProperties(method:"GET", path:"/", params:nil, headers:nil, body:nil, followRedirects:true, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: kGatewayDefaultCacheExpiration, customCacheIdentifier: nil)
        
        self.post = post ?? MutableRequestProperties(method:"POST", path:"/", params:nil, headers:nil, body:nil, followRedirects:true, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
        
        self.put = put ?? MutableRequestProperties(method:"PUT", path:"/", params:nil, headers:nil, body:nil, followRedirects:true, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
        
        self.delete = delete ?? MutableRequestProperties(method:"DELETE", path:"/", params:nil, headers:nil, body:nil, followRedirects:true, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
    }
}
