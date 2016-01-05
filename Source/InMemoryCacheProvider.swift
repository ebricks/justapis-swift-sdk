//
//  InMemoryCacheProvider.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 1/4/16.
//  Copyright © 2016 AnyPresence. All rights reserved.
//

import Foundation

public class InMemoryCacheProvider : CacheProvider
{
    var cache = NSCache()

    internal class CacheObject : NSObject
    {
        var response:ResponseProperties
        var expiresAt:NSDate
        
        init(response:ResponseProperties, expiresAt:NSDate)
        {
            self.response = response
            self.expiresAt = expiresAt
        }
    }
    
    public func cachedResponseForIdentifier(identifier:String, callback:CacheProviderCallback)
    {
        // See if a response was stored for this identifier at all
        guard let object:CacheObject = self.cache.objectForKey(identifier) as? CacheObject else
        {
            // Respond that there was no cache entry for this identifier
            callback(nil)
            return
        }
        
        // See if the response is actually valid, and make sure it expires in the future
        guard let response:ResponseProperties = object.response where object.expiresAt.timeIntervalSinceNow > 0 else
        {
            // clean out this cache object if it already expired or is invalid
            cache.removeObjectForKey(identifier)

            // Respond that there was no cache entry for this identifier
            callback(nil)
            return
        }

        callback(response)
    }
    
    public func setCachedResponseForIdentifier(identifier:String, response:ResponseProperties, expirationSeconds:UInt)
    {
        // Wrap the response in a cache object, including the preferred expiration date
        let cacheObject:CacheObject = CacheObject(response:response, expiresAt: NSDate(timeIntervalSinceNow: NSTimeInterval(expirationSeconds)))

        // Insert the response into the cache
        cache.setObject(cacheObject, forKey: identifier)
    }
}