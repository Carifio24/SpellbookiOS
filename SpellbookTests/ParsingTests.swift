//
//  ParsingTests.swift
//  SpellbookTests
//
//  Created by Jonathan Carifio on 2/7/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import Foundation
import XCTest
@testable import Spellbook

class ParsingTests: XCTestCase {
    func testParseSpellList() {
        let state = SpellbookAppState()
        XCTAssert(state.spellList.count == 941)
    }
}
