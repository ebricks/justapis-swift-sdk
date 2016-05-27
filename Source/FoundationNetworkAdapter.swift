//
//  FoundationNetworkAdapter.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 12/9/15.
//  Copyright © 2015 AnyPresence. All rights reserved.
//

import Foundation

public class FoundationNetworkAdapter : NSObject, NetworkAdapter, NSURLSessionDataDelegate, NSURLSessionDelegate
{
    typealias TaskCompletionHandler =  (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void;
    
    public init(sslCertificate:SSLCertificate? = nil)
    {
        self.sslCertificate = sslCertificate
        super.init()
        
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
    }
    
    private let sslCertificate:SSLCertificate?
    private var session:NSURLSession!
    private var taskToRequestMap = [Int: (request:Request, handler:TaskCompletionHandler)]()
    
    @objc public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response:
        NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {

            if let taskRequest = self.taskToRequestMap[task.taskIdentifier]
            {
                if (taskRequest.request.followRedirects)
                {
                    // Allow redirect
                    completionHandler(request)
                }
                else
                {
                    // Reject redirect
                    completionHandler(nil)
                    
                    // HACK: For a currently unclear reason, the data task's completion handler doesn't
                    // get called by the NSURLSession framework if we reject the redirect here. 
                    // So we call it here explicitly.
                    taskRequest.handler(data:nil, response: response, error:nil)
                }
            }
            else
            {
                completionHandler(request)
            }
    }
    
    @objc public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {

        // If we have a SSL certificate for certificate pinning, verify it

        guard let serverTrust = challenge.protectionSpace.serverTrust else
        {
            // APPROVE: This isn't the challenge we're looking for
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, nil)
            return
        }
     
        let credential = NSURLCredential(forTrust: serverTrust)

        guard let sslCertificate = self.sslCertificate else
        {
            // APPROVE: We're not worried about trusting the server as we have no certificate pinned
            challenge.sender?.useCredential(credential, forAuthenticationChallenge: challenge)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            return
        }
        
        guard let remoteCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else
        {
            // FAIL: We want to verify the server ceritifate, but it didn't give us one!
            challenge.sender?.cancelAuthenticationChallenge(challenge)
            completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
            return
        }
        
        guard let
            remoteCertificateData:NSData = SecCertificateCopyData(remoteCertificate)
            where
            remoteCertificateData.isEqualToData(sslCertificate.data) else
        {
            // FAIL: The certificates didn't match!
            challenge.sender?.cancelAuthenticationChallenge(challenge)
            completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
            return
        }
        
        // APPROVE: We checked for a certificate and it was valid!
        challenge.sender?.useCredential(credential, forAuthenticationChallenge: challenge)
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        return
    }
    
    public func submitRequest(request: Request, gateway:CompositedGateway)
    {
        // Build the request
        guard let urlRequest:NSURLRequest = request.toNSURLRequest(gateway) else
        {
            // TODO: construct error indicating invalid request and invoke callback
            return
        }
        
        var taskIdentifier:Int!
        let taskCompletionHandler = { [weak self]
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            var gatewayResponse:MutableResponseProperties? = nil
            
            // Generate a Gateway Response, if there's
            if let foundationResponse = response as? NSHTTPURLResponse
            {
                gatewayResponse = MutableResponseProperties(foundationResponse, data:data, requestedURL:urlRequest.URL!, gateway: gateway, request: request)
            }
            
            self?.taskToRequestMap.removeValueForKey(taskIdentifier)

            // Let the gateway finish processing the response (on main thread)
            dispatch_async(dispatch_get_main_queue(), {
                gateway.fulfillRequest(request, response:gatewayResponse, error:error);
            })
        }
        
        // Submit the request on the session
        let task = self.session.dataTaskWithRequest(urlRequest, completionHandler: taskCompletionHandler)
        
        taskIdentifier = task.taskIdentifier
        self.taskToRequestMap[taskIdentifier] = (request, taskCompletionHandler)
        task.resume()
    }
}

internal extension MutableResponseProperties
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
        self.parsedBody = nil
        self.retreivedFromCache = false
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
                else if let _ = value as? NSNull
                {
                    let queryItem:NSURLQueryItem = NSURLQueryItem(name: key, value: nil);
                    queryItems.append(queryItem)
                }
                else if let stringValue = value as? CustomStringConvertible
                {
                    let queryItem:NSURLQueryItem = NSURLQueryItem(name: key, value: String(stringValue));
                    queryItems.append(queryItem)
                }
                else
                {
                    assert(false, "Unsupported query item value. Must be array, NSNull, or a CustomStringConvertible type")
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

            // NSURLSession has a known bug where it strips HTTPBody from the request, making testing
            // more difficult. (5/17/2016) Until this is fixed, we stash the body using NSURLProtocol
            // so we can expect it there in tests.
            // https://github.com/AliSoftware/OHHTTPStubs/wiki/Testing-for-the-request-body-in-your-stubs
            NSURLProtocol.setProperty(body, forKey: "HTTPBody", inRequest: urlRequest)
        }
        
        return urlRequest
    }
}
