//
//  Gateway.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/29/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

let kGatewayDefaultCacheExpiration:UInt = 300

///
/// A client-side representation of a JustAPIs Gateway server
///
public protocol Gateway : class
{
    /// The Base URL to which requests will be sent
    var baseUrl:NSURL { get }
    
    /// Sends a request to the gateway
    func submitRequest(request:RequestProperties, callback:RequestCallback?)
}


///
/// A protocol extension to Gateway that adds convenience methods for preparing GET requests
///
public extension Gateway
{
    /// A convenience method for sending a GET request
    func get(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, followRedirects:Bool, callback:RequestCallback?)
    {
        let request = MutableRequestProperties(method:"GET", path:path, params:params, headers:headers, body:body, followRedirects:followRedirects, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: true, cacheResponseWithExpiration: kGatewayDefaultCacheExpiration, customCacheIdentifier: nil)
        
        self.submitRequest(request, callback: callback)
    }
    
    /// A convenience method for sending a GET request
    func get(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
    {
        return self.get(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a GET request
    func get(path:String, params:QueryParameters?, headers:Headers?, callback:RequestCallback?)
    {
        return self.get(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a GET request
    func get(path:String, params:QueryParameters?, callback:RequestCallback?)
    {
        return self.get(path, params: params, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a GET request
    func get(path:String, callback:RequestCallback?)
    {
        return self.get(path, params: nil, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
}

///
/// A protocol extension to Gateway that adds convenience methods for preparing POST requests
///
public extension Gateway
{
    /// A convenience method for sending a POST request
    func post(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, followRedirects:Bool, callback:RequestCallback?)
    {
        let request = MutableRequestProperties(method:"POST", path:path, params:params, headers:headers, body:body, followRedirects:followRedirects, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
        
        self.submitRequest(request, callback: callback)
    }
    
    /// A convenience method for sending a POST request
    func post(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
    {
        return self.post(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a POST request
    func post(path:String, params:QueryParameters?, headers:Headers?, callback:RequestCallback?)
    {
        return self.post(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a POST request
    func post(path:String, params:QueryParameters?, callback:RequestCallback?)
    {
        return self.post(path, params: params, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a POST request
    func post(path:String, callback:RequestCallback?)
    {
        return self.post(path, params: nil, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
}

///
/// A protocol extension to Gateway that adds convenience methods for preparing PUT requests
///
public extension Gateway
{
    /// A convenience method for sending a PUT request
    func put(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, followRedirects:Bool, callback:RequestCallback?)
    {
        let request = MutableRequestProperties(method:"PUT", path:path, params:params, headers:headers, body:body, followRedirects:followRedirects, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
        
        self.submitRequest(request, callback: callback)
    }
    
    /// A convenience method for sending a PUT request
    func put(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
    {
        return self.put(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a PUT request
    func put(path:String, params:QueryParameters?, headers:Headers?, callback:RequestCallback?)
    {
        return self.put(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a PUT request
    func put(path:String, params:QueryParameters?, callback:RequestCallback?)
    {
        return self.put(path, params: params, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a PUT request
    func put(path:String, callback:RequestCallback?)
    {
        return self.put(path, params: nil, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
}

///
/// A protocol extension to Gateway that adds convenience methods for preparing DELETE requests
///
public extension Gateway
{
    /// A convenience method for sending a DELETE request
    func delete(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, followRedirects:Bool, callback:RequestCallback?)
    {
        let request = MutableRequestProperties(method:"PUT", path:path, params:params, headers:headers, body:body, followRedirects:followRedirects, applyContentTypeParsing: true, contentTypeOverride: nil, allowCachedResponse: false, cacheResponseWithExpiration: 0, customCacheIdentifier: nil)
        
        self.submitRequest(request, callback: callback)
    }
    
    /// A convenience method for sending a DELETE request
    func delete(path:String, params:QueryParameters?, headers:Headers?, body:NSData?, callback:RequestCallback?)
    {
        return self.delete(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a DELETE request
    func delete(path:String, params:QueryParameters?, headers:Headers?, callback:RequestCallback?)
    {
        return self.delete(path, params: params, headers: headers, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a DELETE request
    func delete(path:String, params:QueryParameters?, callback:RequestCallback?)
    {
        return self.delete(path, params: params, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
    
    /// A convenience method for sending a DELETE request
    func delete(path:String, callback:RequestCallback?)
    {
        return self.delete(path, params: nil, headers: nil, body: nil, followRedirects: true, callback: callback)
    }
}
