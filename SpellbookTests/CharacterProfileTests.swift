//
//  CharacterProfileTests.swift
//  SpellbookTests
//
//  Created by Mac Pro on 6/14/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation
import XCTest
@testable import Spellbook

class CharacterProfileTests: XCTestCase {
    func testV3_0_0_loadFromJSON() {
        let jsonString = "{\"VersionCode\":\"3.0.0\",\"SpellSlotStatus\":{\",\"\"usedSlotsKey\":[2,0,0,0,0,0,0,0,0],\"totalSlots\":[7,0,0,0,0,0,0,0,0]},\"CharacterName\":\"test\",\"SpellFilterStatus\":{\"spells\":[{\"favorite\":true,\"spellID\":250,\"prepared\":false,\"known\":false},{\"favorite\":true,\"prepared\":true,\"spellID\":6,\"known\":true},{\"known\":false,\"prepared\":true,\"favorite\":false,\"spellID\":351},{\"prepared\":true,\"favorite\":true,\"known\":false,\"spellID\":272},{\"spellID\":215,\"favorite\":false,\"prepared\":false,\"known\":true},{\"prepared\":false,\"favorite\":true,\"known\":true,\"spellID\":352},{\"spellID\":299,\"prepared\":true,\"favorite\":false,\"known\":true},{\"prepared\":false,\"spellID\":364,\"known\":true,\"favorite\":true}]},\"SortFilterStatus\":{\"StatusFilter\":\"Favorites\",\"NotRitual\":false,\"RangeBounds\":{\"MaxValue\":1,\"MaxUnit\":\"mile\",\"MinUnit\":\"foot\",\"MinValue\":0},\"MinSpellLevel\":2,\"Ritual\":true,\"CastingTimeTypes\":[\"1 action\",\"1 reaction\",\"Other\"],\"DurationBounds\":{\"MaxValue\":30,\"MinUnit\":\"round\",\"MinValue\":0,\"MaxUnit\":\"hour\"},\"MaxSpellLevel\":8,\"CastingTimeBounds\":{\"MinUnit\":\"second\",\"MinValue\":2,\"MaxValue\":22,\"MaxUnit\":\"hour\"},\"Classes\":[\"Artificer\",\"Druid\",\"Paladin\",\"Ranger\",\"Sorcerer\",\"Warlock\",\"Wizard\"],\"UseTCEExpandedLists\":true,\"DurationTypes\":[\"Special\",\"Finite duration\",\"Until dispelled\"],\"ApplyFiltersToSpellLists\":true,\"Sourcebooks\":[\"phb\",\"ai\",\"aag\"],\"Reverse1\":false,\"Concentration\":true,\"NotComponentsFilters\":[true,true,false],\"ComponentsFilters\":[false,true,true],\"Schools\":[\"Conjuration\",\"Divination\",\"Enchantment\",\"Evocation\",\"Illusion\",\"Transmutation\"],\"SortField1\":\"Level\",\"NotConcentration\":true,\"SortField2\":\"Range\",\"RangeTypes\":[\"Special\",\"Sight\",\"Ranged\",\"Unlimited\"],\"ApplyFiltersToSearch\":false,\"Reverse2\":true}}"
        
        let sion = SION(json: jsonString)
        guard let profile = try? CharacterProfile.fromSION(sion) else {
            XCTFail("Couldn't parse profile")
            return
        }
        let sortFilterStatus = profile.sortFilterStatus
        let spellFilterStatus = profile.spellFilterStatus
        let spellSlotsStatus = profile.spellSlotStatus
        
        XCTAssertEqual(profile.name, "test")
        XCTAssertEqual(sortFilterStatus.minSpellLevel, 2)
        XCTAssertEqual(sortFilterStatus.maxSpellLevel, 8)
        XCTAssertEqual(sortFilterStatus.statusFilterField, StatusFilterField.Favorites)
        XCTAssertEqual(sortFilterStatus.firstSortField, SortField.Level)
        XCTAssertEqual(sortFilterStatus.secondSortField, SortField.Range)
        XCTAssertEqual(sortFilterStatus.firstSortReverse, false)
        XCTAssertEqual(sortFilterStatus.secondSortReverse, true)
        XCTAssertEqual(sortFilterStatus.applyFiltersToSearch, false)
        XCTAssertEqual(sortFilterStatus.applyFiltersToLists, true)
        XCTAssertEqual(sortFilterStatus.useTashasExpandedLists, true)
        XCTAssertEqual(sortFilterStatus.getVerbalFilter(true), false)
        XCTAssertEqual(sortFilterStatus.getSomaticFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getMaterialFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getVerbalFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getSomaticFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getMaterialFilter(false), false)
        XCTAssertEqual(sortFilterStatus.getConcentrationFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getConcentrationFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getRitualFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getRitualFilter(false), false)

        let visibleClasses = [CasterClass.Artificer, CasterClass.Druid, CasterClass.Paladin, CasterClass.Ranger, CasterClass.Sorcerer, CasterClass.Warlock, CasterClass.Wizard]
        XCTAssertEqual(sortFilterStatus.getVisibleClasses(true), visibleClasses)
        XCTAssertEqual(sortFilterStatus.getVisibleClasses(false), complement(items: visibleClasses))

        let visibleSchools = [School.Conjuration, School.Divination, School.Enchantment, School.Illusion, School.Transmutation]
        XCTAssertEqual(sortFilterStatus.getVisibleSchools(true), visibleSchools)
        XCTAssertEqual(sortFilterStatus.getVisibleSchools(false), complement(items: visibleSchools))

        let visibleSources = [Sourcebook.PlayersHandbook, Sourcebook.AcquisitionsInc, Sourcebook.AstralAG]
        XCTAssertEqual(sortFilterStatus.getVisibleSources(true), visibleSources)
        XCTAssertEqual(sortFilterStatus.getVisibleSources(false), complement(items: visibleSources))

        let visibleCastingTimeTypes = [CastingTimeType.Action, CastingTimeType.Reaction, CastingTimeType.Time]
        XCTAssertEqual(sortFilterStatus.getVisibleCastingTimeTypes(true), visibleCastingTimeTypes)
        XCTAssertEqual(sortFilterStatus.getVisibleCastingTimeTypes(false), complement(items: visibleCastingTimeTypes))

        let visibleDurationTypes = [DurationType.Special, DurationType.Spanning, DurationType.UntilDispelled]
        XCTAssertEqual(sortFilterStatus.getVisibleDurationTypes(true), visibleDurationTypes)
        XCTAssertEqual(sortFilterStatus.getVisibleDurationTypes(false), complement(items: visibleDurationTypes))
        
        let visibleRangeTypes = [RangeType.Special, RangeType.Sight, RangeType.Ranged, RangeType.Unlimited]
        XCTAssertEqual(sortFilterStatus.getVisibleRangeTypes(true), visibleRangeTypes)
        XCTAssertEqual(sortFilterStatus.getVisibleRangeTypes(false), complement(items: visibleRangeTypes))

        let castingTimeBounds = sortFilterStatus.getCastingTimeBounds()
        XCTAssertEqual(castingTimeBounds.0, 2)
        XCTAssertEqual(castingTimeBounds.1, TimeUnit.second)
        XCTAssertEqual(castingTimeBounds.2, 22)
        XCTAssertEqual(castingTimeBounds.3, TimeUnit.hour)

        let durationBounds = sortFilterStatus.getDurationBounds()
        XCTAssertEqual(durationBounds.0, 0)
        XCTAssertEqual(durationBounds.1, TimeUnit.round)
        XCTAssertEqual(durationBounds.2, 30)
        XCTAssertEqual(durationBounds.3, TimeUnit.hour)

        let rangeBounds = sortFilterStatus.getRangeBounds()
        XCTAssertEqual(rangeBounds.0, 0)
        XCTAssertEqual(rangeBounds.1, LengthUnit.foot)
        XCTAssertEqual(rangeBounds.2, 1)
        XCTAssertEqual(rangeBounds.3, LengthUnit.mile)

        // {\"spells\":[{\"favorite\":true,\"spellID\":250,\"prepared\":false,\"known\":false},{\"favorite\":true,\"prepared\":true,\"spellID\":6,\"known\":true},{\"known\":false,\"prepared\":true,\"favorite\":false,\"spellID\":351},{\"prepared\":true,\"favorite\":true,\"known\":false,\"spellID\":272},{\"spellID\":215,\"favorite\":false,\"prepared\":false,\"known\":true},{\"prepared\":false,\"favorite\":true,\"known\":true,\"spellID\":352},{\"spellID\":299,\"prepared\":true,\"favorite\":false,\"known\":true},{\"prepared\":false,\"spellID\":364,\"known\":true,\"favorite\":true}]}
        let favoriteSpellIDs = [6, 250, 272, 352, 364]
        let preparedSpellIDs = [6, 272, 299, 351]
        let knownSpellIDs = [6, 215, 299, 352, 364]
        let oneTrueSpellIDs = [6, 215, 250, 272, 299, 351, 352, 364]
        XCTAssertEqual(spellFilterStatus.favoriteSpellIDs().sorted(), favoriteSpellIDs)
        XCTAssertEqual(spellFilterStatus.preparedSpellIDs().sorted(), preparedSpellIDs)
        XCTAssertEqual(spellFilterStatus.knownSpellIDs().sorted(), knownSpellIDs)
        XCTAssertEqual(spellFilterStatus.spellsWithOneProperty().sorted(), oneTrueSpellIDs)
        
        for level in 1...Spellbook.MAX_SPELL_LEVEL {
            XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: level), 0)
        }
    }
}
