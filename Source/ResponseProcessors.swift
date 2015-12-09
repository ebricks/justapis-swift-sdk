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