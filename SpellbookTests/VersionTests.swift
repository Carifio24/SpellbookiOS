//
//  VersionTests.swift
//  SpellbookTests
//
//  Created by Mac Pro on 5/9/21.
//  Copyright © 2021 Jonathan Carifio. All rights reserved.
//

import Foundation
import XCTest
@testable import Spellbook

class VersionTests: XCTestCase {
    
    func testCorrectParse1() {
        let string = "2.11.0"
        let version = Version.fromString(string)
        XCTAssert(version == Version(major: 2,minor: 11, patch: 0))
    }
    
    func testCorrectParse2() {
        let string = "30.1.2"
        let version = Version.fromString(string)
        XCTAssert(version == Version(major: 30, minor: 1, patch: 2))
    }
    
    func testIncorrectParse1() {
        let string = "2.11.0.5"
        let version = Version.fromString(string)
        XCTAssert(version == nil)
    }
    
    func testIncorrectParse2() {
        let string = "garbage"
        let version = Version.fromString(string)
        XCTAssert(version == nil)
    }
}
