//
//  RequestPreparers.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// Implementation of RequestPreparer that infills default values
/// for headers and query parameters
///
public class DefaultFieldsRequestPreparer : RequestPreparer
{
    public var defaultHeaders:Headers = Headers()
    public var defaultQueryParameters:QueryParameters = QueryParameters()
    
    public func prepareRequest(request: Request) -> Request
    {
        if (self.defaultHeaders.count == 0 && self.defaultQueryParameters.count == 0)
        {
            // Nothing to do. Don't even make our working copy
            return request;
        }
        let request:MutableRequest = MutableRequest(request)

        // Infill defaultHeaders into request.headers if they're missing
        for (key, value) in self.defaultHeaders
        {
            request.headers = request.headers ?? Headers()
            if (nil == request.headers![key])
            {
                request.headers![key] = value
            }
        }
        
        // Infill defaultQueryParameters into request.queryParameters
        for (key, value) in self.defaultQueryParameters
        {
            request.params = request.params ?? QueryParameters()
            if (nil == request.params![key])
            {
                request.params![key] = value
            }
        }
        return request
    }
    
    public init()
    {
        
    }
}

///
/// Implementation of RequestPreparer that dispatches its functionality
//  to a closure provided at initialization
///
public class RequestPreparerClosureAdapter : RequestPreparer
{
    public typealias RequestPreparerClosure = (Request) -> (Request)
    
    private let closure:RequestPreparerClosure
    
    public func prepareRequest(request: Request) -> Request
    {
        // Call the closure
        return self.closure(request)
    }
    
    public init(closure:RequestPreparerClosure)
    {
        self.closure = closure
    }
}