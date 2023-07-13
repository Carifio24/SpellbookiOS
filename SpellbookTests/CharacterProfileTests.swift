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
        let jsonString = "{\"VersionCode\":\"3.0.0\",\"SpellFilterStatus\":{\"spells\":[{\"known\":false,\"favorite\":true,\"spellID\":299,\"prepared\":true},{\"known\":false,\"favorite\":false,\"prepared\":true,\"spellID\":1},{\"spellID\":363,\"prepared\":true,\"favorite\":false,\"known\":false},{\"known\":true,\"favorite\":false,\"spellID\":215,\"prepared\":true},{\"spellID\":6,\"known\":false,\"prepared\":true,\"favorite\":false},{\"spellID\":362,\"favorite\":true,\"known\":true,\"prepared\":true},{\"known\":true,\"spellID\":250,\"prepared\":false,\"favorite\":true},{\"prepared\":true,\"favorite\":false,\"known\":true,\"spellID\":351}]},\"SpellSlotStatus\":{\"usedSlotsKey\":[2,1,1,0,0,0,0,0,0],\"totalSlots\":[7,2,1,0,0,0,0,0,0]},\"SortFilterStatus\":{\"RangeTypes\":[\"Special\",\"Sight\",\"Ranged\",\"Unlimited\"],\"ApplyFiltersToSearch\":false,\"Sourcebooks\":[\"phb\",\"ai\",\"aag\"],\"UseTCEExpandedLists\":true,\"MaxSpellLevel\":8,\"CastingTimeBounds\":{\"MaxUnit\":\"hour\",\"MaxValue\":22,\"MinUnit\":\"second\",\"MinValue\":2},\"Reverse1\":false,\"NotRitual\":false,\"NotComponentsFilters\":[true,true,false],\"NotConcentration\":true,\"Schools\":[\"Conjuration\",\"Divination\",\"Enchantment\",\"Illusion\",\"Transmutation\"],\"Classes\":[\"Artificer\",\"Druid\",\"Paladin\",\"Ranger\",\"Sorcerer\",\"Warlock\",\"Wizard\"],\"SortField2\":\"Range\",\"MinSpellLevel\":2,\"StatusFilter\":\"Favorites\",\"Ritual\":true,\"ComponentsFilters\":[false,true,true],\"Reverse2\":true,\"CastingTimeTypes\":[\"1 action\",\"1 reaction\",\"Other\"],\"DurationBounds\":{\"MinUnit\":\"round\",\"MaxUnit\":\"hour\",\"MaxValue\":30,\"MinValue\":6},\"RangeBounds\":{\"MinValue\":0,\"MaxValue\":1,\"MaxUnit\":\"mile\",\"MinUnit\":\"foot\"},\"ApplyFiltersToSpellLists\":true,\"SortField1\":\"Level\",\"DurationTypes\":[\"Special\",\"Finite duration\",\"Until dispelled\"],\"Concentration\":true},\"CharacterName\":\"test\"}"
        
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
        XCTAssertEqual(durationBounds.0, 6)
        XCTAssertEqual(durationBounds.1, TimeUnit.round)
        XCTAssertEqual(durationBounds.2, 30)
        XCTAssertEqual(durationBounds.3, TimeUnit.hour)

        let rangeBounds = sortFilterStatus.getRangeBounds()
        XCTAssertEqual(rangeBounds.0, 0)
        XCTAssertEqual(rangeBounds.1, LengthUnit.foot)
        XCTAssertEqual(rangeBounds.2, 1)
        XCTAssertEqual(rangeBounds.3, LengthUnit.mile)

        
        let favoriteSpellIDs = [250, 299, 362]
        let preparedSpellIDs = [1, 6, 215, 299, 351, 362, 363]
        let knownSpellIDs = [215, 250, 351, 362]
        let oneTrueSpellIDs = [1, 6, 215, 250, 299, 351, 362, 363]
        XCTAssertEqual(spellFilterStatus.favoriteSpellIDs().sorted(), favoriteSpellIDs)
        XCTAssertEqual(spellFilterStatus.preparedSpellIDs().sorted(), preparedSpellIDs)
        XCTAssertEqual(spellFilterStatus.knownSpellIDs().sorted(), knownSpellIDs)
        XCTAssertEqual(spellFilterStatus.spellsWithOneProperty().sorted(), oneTrueSpellIDs)


        XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: 1), 7)
        XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: 1), 2)
        XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: 1), 5)
        XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: 2), 2)
        XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: 2), 1)
        XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: 2), 1)
        XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: 3), 1)
        XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: 3), 1)
        XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: 3), 0)
        for level in 4...Spellbook.MAX_SPELL_LEVEL {
            XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: level), 0)
        }
    }
}
