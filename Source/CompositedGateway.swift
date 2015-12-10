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
    func processResponse(response:Response) -> (RequestResult)
}

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
    func performRequest(request:Request, gateway:Gateway, callback:RequestCallback)
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
        
        // Assign the given network adapter, or init the default one
        if (nil == networkAdapter)
        {
            networkAdapter = FoundationNetworkAdapter()
        }
        self.networkAdapter = networkAdapter!
    }
    
    public func performRequest(request:Request, callback:RequestCallback?)
    {
        var request = request
        
        // Apply an empty callback if none was provided. It makes the logic cleaner below
        let callback:RequestCallback = nil != callback ? callback! : {(_:RequestResult) in }

        // Prepare the request if a preparer is available
        if let requestPreparer = self.requestPreparer
        {
            request = requestPreparer.prepareRequest(request)
        }

        // Send the request to the network adapter
        self.networkAdapter.performRequest(request, gateway:self, callback: {
            (result:RequestResult) -> (Void) in
            
            var result = result
            
            // Check if there was an error
            guard result.error == nil else
            {
                callback(result)
                return
            }
            
            // Check if there was no response
            guard result.response != nil else
            {
                // TODO: create error
                callback(result)
                return
            }
            
            // Post-process the response if a processor is available
            if let responseProcessor = self.responseProcessor
            {
                // TODO: invoke this on a background thread. Parsing could take a while
                result = responseProcessor.processResponse(result.response!)
            }
            
            // Pass result back to caller
            callback(result)
        })
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