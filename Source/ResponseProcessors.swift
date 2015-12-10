//
//  ResponsePreparers.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// Implementation of ResponseProcessor that dispatches its functionality to
/// a closure provided at initialization
///
public class ResponseProcessorClosureAdapter : ResponseProcessor
{
    public typealias ResponseProcessorClosure = (Response) -> (RequestResult)
    
    private let closure:ResponseProcessorClosure
    
    public func processResponse(response: Response) -> (RequestResult) {
        return self.closure(response)
    }
    
    public init(closure:ResponseProcessorClosure)
    {
        self.closure = closure
    }
}

///
/// Implementation of a ResponseProcessor that decodes body data as a JSON object
///
public class JsonResponseProcessor : ResponseProcessor
{
    public func processResponse(response: Response) -> (RequestResult)
    {
        // Make sure the body is an NSData object, as expected
        guard let body = response.body as? NSData else
        {
            // TODO create an error to indicate no body data and return
            let error:Error? = nil
            return (request:response.request, response:response, error:error)
        }

        var response:Response = response
        var error:Error? = nil

        // Unpack the body data as a JSON object
        do
        {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(body, options: [])

            // Build a new Response with the parsed data replacing the original NSData
            let mutableResponse:MutableResponse = MutableResponse(response)
            mutableResponse.body = jsonData
            response = mutableResponse.immutableCopy()
        }
        catch let jsonError
        {
            error = jsonError
        }
        
        // TODO if successful, replace the response with an ImmutableJsonResponse
        return (request:response.request, response:response, error:error)
    }
}
