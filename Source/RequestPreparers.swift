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
        // TODO: Infill defaultHeaders into request.headers
        // TODO: Infill defaultQueryParameters into request.queryParameters
        return request
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