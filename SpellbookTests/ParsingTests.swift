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
        let spells = state.spellList
        let countForSource: (Sourcebook) -> Int = { source in return spells.filter({ spell in return spell.isIn(sourcebook: source)}).count }
        XCTAssert(spells.count == 974)
        XCTAssert(countForSource(Sourcebook.PlayersHandbook) == 361)
        XCTAssert(countForSource(Sourcebook.PlayersHandbook2024) == 391)
        XCTAssert(countForSource(Sourcebook.XanatharsGTE) == 95)
        XCTAssert(countForSource(Sourcebook.TashasCOE) == 21)
        XCTAssert(countForSource(Sourcebook.SwordCoastAG) == 4)
        XCTAssert(countForSource(Sourcebook.AcquisitionsInc) == 7)
        XCTAssert(countForSource(Sourcebook.RimeOTFrostmaiden) == 2)
        XCTAssert(countForSource(Sourcebook.LostLabKwalish) == 3)
        XCTAssert(countForSource(Sourcebook.ExplorersGTW) == 15)
        XCTAssert(countForSource(Sourcebook.FizbansTOD) == 7)
        XCTAssert(countForSource(Sourcebook.StrixhavenCOC) == 5)
        XCTAssert(countForSource(Sourcebook.AstralAG) == 2)
        XCTAssert(countForSource(Sourcebook.GuildmastersGTR) == 1)
        XCTAssert(countForSource(Sourcebook.TalDoreiCSR) == 2)
        XCTAssert(countForSource(Sourcebook.SigilOutlands) == 2)
        XCTAssert(countForSource(Sourcebook.BookOfMT) == 3)
        XCTAssert(countForSource(Sourcebook.FRHeroesOfFaerun) == 19)
        XCTAssert(countForSource(Sourcebook.ArcanaUnleashed) == 33)
    }
}
