//
//  Keychain.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 05/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//  copied from https://swift.unicorn.tv/articles/dead-simple-keychain-access
//

import Foundation
import Security

public class Keychain
{
    public class func set(key: String, value: String) -> Bool
    {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding)
        {
            return set(key, value: data)
        }
        
        return false
    }
    
    public class func set(key: String, value: NSData) -> Bool
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecValueData as String)   : value
        ]
        
        SecItemDelete(query as CFDictionaryRef)
        
        return SecItemAdd(query as CFDictionaryRef, nil) == noErr
    }
    
    public class func get(key: String) -> NSString?
    {
        if let data = getData(key)
        {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        
        return nil
    }
    
    public class func getData(key: String) -> NSData?
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String)  : kCFBooleanTrue,
            (kSecMatchLimit as String)  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr && dataTypeRef != nil
        {
            return dataTypeRef as? NSData
        }
        
        return nil
    }
    
    public class func delete(key: String) -> Bool
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
    
    public class func clear() -> Bool
    {
        let query = [
            (kSecClass as String): kSecClassGenericPassword
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
}
