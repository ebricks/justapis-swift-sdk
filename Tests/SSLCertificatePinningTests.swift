//
//  SSLCertificatePinningTests.swift
//  JustApisSwiftSDK
//
//  Created by Andrew Palumbo on 1/6/16.
//  Copyright © 2016 AnyPresence. All rights reserved.
//

import XCTest

class SSLCertificatePinningTests: XCTestCase {

    private let validDerCertificate:NSData? = nil
    private let validTrimmedPemCertificate:NSString? = nil
    private let validPaddedPemCertificate:NSString? = nil
    private let invalidCertificate:NSData? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testValidDerCertificate() {
        
    }
    
    func testValidTrimmedPemCertificate() {
        
    }
    
    func testValidPaddedPemCertificate() {
        
    }
    
    func testInvalidCertificate() {
        
    }
    
    func testMatchedServerCertificate() {
        
    }
    
    func testUnmatchedServerCertificate() {
        
    }
    
    func testInsecureConnectionWithPinnedCertificate() {
        
    }
}
