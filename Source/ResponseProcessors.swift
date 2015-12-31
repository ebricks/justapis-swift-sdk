//
//  ResponsePreparers.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

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
}

public class ContentTypeParser : ResponseProcessor
{
    public var contentTypes = [String:ResponseProcessor]()
    
    public func processResponse(response: Response, callback: ResponseProcessorCallback) {
        // TODO:
        // 1. Check if the response.request has forced the contentType to parse
        // 2. If not, check the header for a content type
        // 3. If we have a content type, see if a ResponseProcessor has been registered for it
        // 4. If we have a ResponseProcessor, call it! Else continue with no error

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
        guard let body = response.body as? NSData else
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
            response = response.body(jsonData)
        }
        catch let jsonError
        {
            error = jsonError
        }
        
        // TODO if successful, replace the response with an ImmutableJsonResponse
        callback(response: response, error: error)
    }
}
