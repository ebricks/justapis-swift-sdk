//
//  CompositedGateway.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

///
/// Invoked by the CompositedGateway to prepare a request before sending.
///
/// Common use cases of a RequestPreparer might be to:
///  - add default headers
///  - add default query parameters
///  - rewrite a path
///  - serialize data as JSON or XML
///
public protocol RequestPreparer
{
    func prepareRequest(request:Request) -> Request
}

///
/// Invoked by the CompositedGateway to process a request after its received
///
/// Common use cases of a ResponseProcessor might be to:
///  - validate the type of a response
///  - interpret application-level error messages
///  - deserialize JSON or XML responses
///
public protocol ResponseProcessor
{
    func processResponse(response:Response, callback:ResponseProcessorCallback)
}

public typealias ResponseProcessorCallback = ((response:Response, error:ErrorType?) -> Void)

///
/// Invoked by the CompositedGateway to send the request along the wire
///
/// Common use cases of a NetworkAdapter might be to:
///  - Use a specific network library (Foundation, AFNetworking, etc)
///  - Mock responses
///  - Reference a cache before using network resources
///
public protocol NetworkAdapter
{
    func submitRequest(request:Request, gateway:CompositedGateway)
}

///
/// Implementation of Gateway protocol that dispatches most details to
/// helper classes.
///
public class CompositedGateway : Gateway
{
    public let baseUrl:NSURL
    
    private let networkAdapter:NetworkAdapter
    private let requestPreparer:RequestPreparer?
    private let responseProcessor:ResponseProcessor?
    private let contentTypeParser:ContentTypeParser
    private var callbacks = [InternalRequest: RequestCallback]()
    
    public init(
        baseUrl:NSURL,
        requestPreparer:RequestPreparer? = nil,
        responseProcessor:ResponseProcessor? = nil,
        networkAdapter:NetworkAdapter? = nil
        )
    {
        self.baseUrl = baseUrl
        
        var networkAdapter = networkAdapter
        self.requestPreparer = requestPreparer
        self.responseProcessor = responseProcessor
        self.contentTypeParser = ContentTypeParser()

        // Assign the given network adapter, or init the default one
        if (nil == networkAdapter)
        {
            networkAdapter = FoundationNetworkAdapter()
        }
        self.networkAdapter = networkAdapter!
    }
    
    ///
    /// Sets a ResponseProcessor to run when the given contentType is encountered in a response
    ///
    public func setParser(parser:ResponseProcessor?, contentType:String)
    {
        if (parser != nil)
        {
            self.contentTypeParser.contentTypes[contentType] = parser
        }
        else
        {
            self.contentTypeParser.contentTypes.removeValueForKey(contentType)
        }
    }
    
    public func submitRequest(request:RequestProperties, callback:RequestCallback?)
    {
        let request = self.prepareInternalRequest(request)
        self.submitInternalRequest(request, callback: callback)
    }
    
    ///
    /// Called by CacheProvider or NetworkAdapter once a response is ready
    ///
    public func fulfillRequest(request:Request, response:ResponseProperties?, error:ErrorType?)
    {
        guard let request = request as? InternalRequest else
        {
            // TODO: THROW serious error. The Request was corrupted!
            return
        }

        // Apply an empty callback if none was provided. It makes the logic cleaner below
        let callback:RequestCallback? = self.callbacks[request]
        let response:InternalResponse? = (response != nil) ? self.prepareInternalResponse(response!) : nil

        // Remove the
        self.callbacks.removeValueForKey(request)

        var result:RequestResult = (request:request, response:response, error:error)

        // Check if there was an error
        guard error == nil else
        {
            callback?(result)
            return
        }
        
        // Check if there was no response; that's an error itself!
        guard response != nil else
        {
            // TODO: create meaningful error
            result.error = createError(0, context:nil, description:"")
            callback?(result)
            return
        }
        
        // Compound 0+ response processors for this response
        let compoundResponseProcessor = CompoundResponseProcessor()
        
        // Add the content type parser
        compoundResponseProcessor.responseProcessors.append(contentTypeParser)

        // Add any all-response processor
        if let responseProcessor = self.responseProcessor
        {
            compoundResponseProcessor.responseProcessors.append(responseProcessor)
        }
        
        // TODO: add any cache-storing response processors
        
        // Run the compound processor in a dispatch group
        let responseProcessingDispatchGroup = dispatch_group_create()
        dispatch_group_enter(responseProcessingDispatchGroup)
        compoundResponseProcessor.processResponse(result.response!,
            callback:
            {
                (response:Response, error:ErrorType?) in
                
                result = (request:request, response:response, error:error)
                dispatch_group_leave(responseProcessingDispatchGroup)
            }
        )

        // When the dispatch group is emptied, run the callback
        dispatch_group_notify(responseProcessingDispatchGroup, dispatch_get_main_queue(), {
            // Pass result back to caller
            callback?(result)
        })
    }
    
    ///
    /// Wraps raw ResponseProperties as an InternalResponse
    ///
    private func prepareInternalResponse(response:ResponseProperties) -> InternalResponse
    {
        // Downcast to an InternalResponse, or wrap externally prepared properties
        var internalResponse:InternalResponse = (response as? InternalResponse) ?? InternalResponse(self, response:response)
        
        if (internalResponse.gateway !== self)
        {
            // response was prepared for another gateway. Associate it with this one!
            internalResponse = internalResponse.gateway(self)
        }
        
        return internalResponse
    }

    ///
    /// Prepares RequestProperties as an InteralRequest and performs preflight prep
    ///
    private func prepareInternalRequest(request:RequestProperties) -> InternalRequest
    {
        // Downcast to an InternalRequest, or wrap externally prepared properties
        var internalRequest:InternalRequest = (request as? InternalRequest) ?? InternalRequest(self, request:request)

        if (internalRequest.gateway !== self)
        {
            // request was prepared for another gateway. Associate it with this one!
            internalRequest = internalRequest.gateway(self)
        }
        
        // Prepare the request if a preparer is available
        if let requestPreparer = self.requestPreparer
        {
            // TODO?: change interface to something async; may need to do something complex
            internalRequest = requestPreparer.prepareRequest(internalRequest) as! InternalRequest
        }

        // TODO: assign an identifer?

        return internalRequest
    }
    
    ///
    /// Checks CacheProvider for matching Response or submits InternalRequest to NetworkAdapter
    ///
    private func submitInternalRequest(request:InternalRequest, callback:RequestCallback?)
    {
        if (nil != callback)
        {
            self.callbacks[request] = callback
        }

        // TODO: check cache
        
        // Send the request to the network adapter
        self.networkAdapter.submitRequest(request, gateway:self)
    }
}

///
/// Convenience subclass of CompositedGateway that uses the JsonResponseProcessor.
///
public class JsonGateway : CompositedGateway
{
    public init(baseUrl: NSURL, requestPreparer: RequestPreparer? = nil, networkAdapter: NetworkAdapter? = nil)
    {
        super.init(baseUrl: baseUrl, requestPreparer:requestPreparer, responseProcessor:JsonResponseProcessor(), networkAdapter:networkAdapter)
    }
}