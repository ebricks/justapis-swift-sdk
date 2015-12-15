//
//  FoundationNetworkAdapter.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

public class FoundationNetworkAdapter : NetworkAdapter
{
    public func performRequest(request: Request, gateway:Gateway, callback: RequestCallback)
    {
        // Build the request
        guard let urlRequest:NSURLRequest = request.toNSURLRequest(gateway) else
        {
            // TODO: construct error indicating invalid request and invoke callback
            return
        }
        
        // Get an NSURLSession
        let session:NSURLSession = NSURLSession.sharedSession()
        
        // Submit the request on that session
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            var gatewayResponse:ImmutableResponse? = nil

            // Generate a Gateway Response, if there's
            if let foundationResponse = response as? NSHTTPURLResponse
            {
                gatewayResponse = ImmutableResponse(foundationResponse, data:data, requestedURL:urlRequest.URL!, gateway: gateway, request: request)
            }
            
            callback((request:request, response:gatewayResponse, error:error))
        })
        task.resume()
    }
}

internal extension ImmutableResponse
{
    // Internal initializer method to populate an Immutable Response
    internal init(_ response:NSHTTPURLResponse, data:NSData?, requestedURL:NSURL, gateway:Gateway, request:Request)
    {
        self.gateway = gateway
        self.request = request
        self.statusCode = response.statusCode
        
        var headers = Headers()
        for (key, value) in response.allHeaderFields
        {
            if let keyString = key as? String, let valueString = value as? String
            {
                headers[keyString] = valueString
            }
        }
        self.headers = headers
        self.requestedURL = requestedURL
        self.resolvedURL = response.URL ?? nil
        self.body = data
    }
}

internal extension Request
{
    /// Internal method to convert any type of Request to a NSURLRequest for Foundation networking
    internal func toNSURLRequest(gateway:Gateway) -> NSURLRequest?
    {
        // Identify the absolute URL endpoint
        let endpointUrl:NSURL = gateway.baseUrl.URLByAppendingPathComponent(self.path);
        
        var url:NSURL = endpointUrl

        // If params are assigned, apply them
        if nil != self.params && self.params!.count > 0
        {
            let params = self.params!
            
            // Create a components object
            guard let urlComponents:NSURLComponents = NSURLComponents(URL: endpointUrl, resolvingAgainstBaseURL: false) else
            {
                // Could not parse NSURL through this technique
                return nil
            }

            // Build query list
            var queryItems = Array<NSURLQueryItem>()
            for (key,value) in params
            {
                if let arrayValue = value as? Array<AnyObject>
                {
                    for (innerValue) in arrayValue
                    {
                        let queryItem:NSURLQueryItem = NSURLQueryItem(name: key + "[]", value:String(innerValue))
                        queryItems.append(queryItem)
                    }
                }
                else
                {
                    let queryItem:NSURLQueryItem = NSURLQueryItem(name: key, value: nil != value ? String(value!) : nil);
                    queryItems.append(queryItem)
                }
            }
            urlComponents.queryItems = queryItems
            
            // Try to resolve the URLComponents
            guard let completeUrl = urlComponents.URL else
            {
                // Could not resolve to URL once we included query parameters
                return nil
            }
            url = completeUrl
        }

        // Create the request object
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: url);
        
        // Set the method
        urlRequest.HTTPMethod = self.method;

        // If headers were assigned, apply them
        if nil != self.headers && self.headers!.count > 0
        {
            let headers = self.headers!
            for (field,value) in headers
            {
                urlRequest.addValue(value, forHTTPHeaderField: field);
            }
        }
        
        // If a body was assigned, apply it
        if let body = self.body
        {
            urlRequest.HTTPBody = body
        }        
        
        return urlRequest
    }
}
