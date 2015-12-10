//
//  CoreTypes.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

//
//
// Types used for semantic clarity
//
//

/// The module-specific type used for Errors
public typealias Error = ErrorType

/// The tuple that represents a response or error associated with a completed request
public typealias RequestResult = (request:Request, response:Response?, error:Error?)

/// A callback which is invoked when a request completes
public typealias RequestCallback = ((RequestResult) -> Void)

/// A semantic alias for Key-Value hashes used as Query Parameters
public typealias QueryParameters = Dictionary<String, String>

/// A semantic alias for Key-Value hashes used as HTTP Headers
public typealias Headers = Dictionary<String, String>



//
//
// The core protocols of this SDK. Gateway, Request, and Response
//
//

///
/// A Request that may be (or has been) sent to the Gateway
///
public protocol Request
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
}


///
/// A response received from a gateway
///
public protocol Response
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
    var body:AnyObject? { get }
}


///
/// A client-side representation of a JustAPIs Gateway server
///
public protocol Gateway
{
    /// The Base URL to which requests will be sent
    var baseUrl:NSURL { get }
    
    /// Sends a request to the gateway
    func performRequest(request:Request, callback:RequestCallback?)
    

    /// A convenience method for sending a POST request
    //func post(endpoint:NSURL, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)

    /// A convenience method for sending a PUT request
    //func put(endpoint:NSURL, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)

    /// A convenience method for sending a DELETE request
    //func delete(endpoint:NSURL, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
}

///
/// A protocol extension to Gateway that adds convenience methods for preparing GET requests
///
public extension Gateway
{
    /// A convenience method for sending a GET request
    func get(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
    {
        let request = ImmutableRequest(method:"GET", path:path, params:params, headers:headers, body:body, followRedirects:false)
        
        self.performRequest(request, callback: callback)
    }
}
