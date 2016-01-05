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
/// Invoked by the CompositedGateway to save and retrieve responses locally cached responses
///
public protocol CacheProvider
{
    /// Called to retrieve a Response from the cache. Should call the callback with nil or the retrieved response
    func cachedResponseForIdentifier(identifier:String, callback:CacheProviderCallback)

    /// Called to save a Response to the cache. The expiration should be considered a preference, not a guarantee.
    func setCachedResponseForIdentifier(identifier:String, response:ResponseProperties, expirationSeconds:UInt)
}

public typealias CacheProviderCallback = ((ResponseProperties?) -> Void)

///
/// A Cache Provider implementation that does nothing. Useful to disable caching without changing your request logic
///
public class NullCacheProvider : CacheProvider
{
    public func cachedResponseForIdentifier(identifier: String, callback: CacheProviderCallback) {
        return callback(nil)
    }
    
    public func setCachedResponseForIdentifier(identifier: String, response: ResponseProperties, expirationSeconds: UInt) {
        return
    }
}

///
/// Implementation of Gateway protocol that dispatches most details to
/// helper classes.
///
public class CompositedGateway : Gateway
{
    public let baseUrl:NSURL
    public let defaultRequestProperties:DefaultRequestPropertySet
    
    private let networkAdapter:NetworkAdapter
    private let cacheProvider:CacheProvider
    private let requestPreparer:RequestPreparer?
    private let responseProcessor:ResponseProcessor?
    private let contentTypeParser:ContentTypeParser
    private var callbacks = [InternalRequest: RequestCallback]()
        
    public init(
        baseUrl:NSURL,
        defaultRequestProperties:DefaultRequestPropertySet? = nil,
        requestPreparer:RequestPreparer? = nil,
        responseProcessor:ResponseProcessor? = nil,
        cacheProvider:CacheProvider? = nil,
        networkAdapter:NetworkAdapter? = nil
        )
    {
        self.baseUrl = baseUrl

        // Use the GatewayDefaultRequestProperties if none were provided
        self.defaultRequestProperties = defaultRequestProperties ?? GatewayDefaultRequestProperties()
        self.requestPreparer = requestPreparer
        self.responseProcessor = responseProcessor
        self.contentTypeParser = ContentTypeParser()

        // Use the InMemory Cache Provider if none was provided
        self.cacheProvider = cacheProvider ?? InMemoryCacheProvider()
        
        // Use the Foundation Network Adapter if none was provided
        self.networkAdapter = networkAdapter ?? FoundationNetworkAdapter()
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
        let request = self.internalizeRequest(request)
        self.submitInternalRequest(request, callback: callback)
    }
    
    ///
    /// Called by CacheProvider or NetworkAdapter once a response is ready
    ///
    public func fulfillRequest(request:Request, response:ResponseProperties?, error:ErrorType?, fromCache:Bool = false)
    {
        guard let request = request as? InternalRequest else
        {
            // TODO: THROW serious error. The Request was corrupted!
            return
        }

        // Apply an empty callback if none was provided. It makes the logic cleaner below
        let callback:RequestCallback? = self.callbacks[request]
        let response:InternalResponse? = (response != nil) ? self.internalizeResponse(response!) : nil

        // Remove the
        self.callbacks.removeValueForKey(request)

        var result:RequestResult = (request:request,
                                    response:response?.retreivedFromCache(fromCache),
                                    error:error)

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
        if request.applyContentTypeParsing
        {
            compoundResponseProcessor.responseProcessors.append(contentTypeParser)
        }

        // Add any all-response processor
        if let responseProcessor = self.responseProcessor
        {
            compoundResponseProcessor.responseProcessors.append(responseProcessor)
        }
        
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

        // When the dispatch group is emptied, cache the response and run the callback
        dispatch_group_notify(responseProcessingDispatchGroup, dispatch_get_main_queue(), {
            
            
            if result.error == nil // There's no error
                && result.response != nil // And there is a response
                && !fromCache // And the response isn't already from the cache
                && request.cacheResponseWithExpiration > 0 // And we're supposed to cache it
            {
                // Cache the response
                self.cacheProvider.setCachedResponseForIdentifier(request.cacheIdentifier, response: result.response!, expirationSeconds:request.cacheResponseWithExpiration)
            }
            
            // Pass result back to caller
            callback?(result)
        })
    }
    
    ///
    /// Wraps raw ResponseProperties as an InternalResponse
    ///
    private func internalizeResponse(response:ResponseProperties) -> InternalResponse
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
    private func internalizeRequest(request:RequestProperties) -> InternalRequest
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

        if request.allowCachedResponse
        {
            // Check the cache
            self.cacheProvider.cachedResponseForIdentifier(request.cacheIdentifier, callback: {
                (response:ResponseProperties?) in
                
                if let response = response
                {
                    // There was a subitably fresh response in the cache. Use it
                    self.fulfillRequest(request, response: response, error: nil, fromCache:true)
                }
                else
                {
                    // Otherwise, send the request to the network adapter
                    self.networkAdapter.submitRequest(request, gateway:self)
                }
            })
        }
        else
        {
            // Ignore anything in the cache, and send the request to the network adapter immediately
            self.networkAdapter.submitRequest(request, gateway:self)
        }
        
    }
}

///
/// Convenience subclass of CompositedGateway that uses the JsonResponseProcessor.
///
public class JsonGateway : CompositedGateway
{
    public override init(baseUrl: NSURL, requestPreparer: RequestPreparer? = nil, responseProcessor:ResponseProcessor? = nil, cacheProvider:CacheProvider? = nil, networkAdapter: NetworkAdapter? = nil)
    {
        super.init(baseUrl: baseUrl, requestPreparer:requestPreparer, responseProcessor:nil, networkAdapter:networkAdapter)
        super.setParser(JsonResponseProcessor(), contentType: "application/json")
    }
}