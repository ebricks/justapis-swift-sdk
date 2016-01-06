//
//  ResponsePreparers.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// A Response Processor implementation that does nothing
///
public class NullResponseProcessor : ResponseProcessor
{
    public func processResponse(response: Response, callback: ResponseProcessorCallback) {
        callback(response: response, error: nil)
    }
}

///
/// A ResponseProcessor that dispatches its functionality to
/// a closure provided at initialization
///
public class ResponseProcessorClosureAdapter : ResponseProcessor
{
    public typealias ResponseProcessorClosure = (Response) -> (RequestResult)
    
    private let closure:ResponseProcessorClosure
    
    public func processResponse(response: Response, callback:ResponseProcessorCallback) {
        let result = self.closure(response)
        callback(response: result.response!, error: result.error)
    }
    
    public init(closure:ResponseProcessorClosure)
    {
        self.closure = closure
    }
}

///
/// A ResponseProcessor that executes multiple other processors in series
///
public class CompoundResponseProcessor : ResponseProcessor
{
    public var responseProcessors = [ResponseProcessor]()
    
    public func processResponse(response: Response, callback:ResponseProcessorCallback) {

        let dispatchGroup = dispatch_group_create()

        var response = response
        var error:ErrorType? = nil

        for responseProcessor in responseProcessors
        {
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
                guard error == nil else
                {
                    // If there's an error, do no more processing
                    return
                }

                dispatch_group_enter(dispatchGroup)
                
                responseProcessor.processResponse(response,
                    callback:
                    {
                        (immediateResponse:Response, immediateError:ErrorType?) in
                        
                        response = immediateResponse
                        error = immediateError
                        dispatch_group_leave(dispatchGroup)
                    }
                )
            })
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
            callback(response:response, error: error)
        })
    }
    
    public init()
    {
        
    }
}

///
/// Dispatches a ResponseProcessor for a matched Content-Type header (or overriden Content-Type)
///
public class ContentTypeParser : ResponseProcessor
{
    /// Map of "Content-Type" value to ResponseProcessor
    public var contentTypes = [String:ResponseProcessor]()
    
    public func processResponse(response: Response, callback: ResponseProcessorCallback) {

        if let contentType = response.request.contentTypeOverride ?? response.headers["Content-Type"]
        {
            if let processor:ResponseProcessor = contentTypes[contentType]
            {
                processor.processResponse(response, callback: callback)
                return
            }
        }
        
        // There was either no contentType or no ResponseProcess. Just pass along our input:
        callback(response: response, error: nil)
    }
}

///
/// Implementation of a ResponseProcessor that decodes body data as a JSON object
///
public class JsonResponseProcessor : ResponseProcessor
{
    public func processResponse(response: Response, callback:ResponseProcessorCallback)
    {
        // Make sure the body is an NSData object, as expected
        guard let body = response.body else
        {
            // TODO create an error to indicate no body data and return
            let error:ErrorType? = nil
            callback(response: response, error: error)
            return
        }

        var response:Response = response
        var error:ErrorType? = nil

        // Unpack the body data as a JSON object
        do
        {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(body, options: [])

            // TODO: Parsing should use different properties! Not overwrite body!
            // Build a new Response with the parsed data replacing the original NSData
            response = response.parsedBody(jsonData)
        }
        catch let jsonError
        {
            error = jsonError
        }
        
        // TODO if successful, replace the response with an ImmutableJsonResponse
        callback(response: response, error: error)
    }
}
