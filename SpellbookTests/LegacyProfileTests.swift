//
//  CharacterProfileTests.swift
//  SpellbookTests
//
//  Created by Mac Pro on 5/7/21.
//  Copyright © 2021 Jonathan Carifio. All rights reserved.
//

import Foundation

import XCTest
@testable import Spellbook

class LegacyProfileTests: XCTestCase {
    
    func testV2_13_1_loadFromJSON() {
        let jsonString = "{\"MinSpellLevel\":2,\"StatusFilter\":\"All spells\",\"NotRitual\":true,\"NotConcentration\":true,\"Somatic\":true,\"HiddenCastingTimeTypes\":[\"1 bonus action\"],\"HiddenRangeTypes\":[\"Ranged\"],\"MaxSpellLevel\":6,\"VersionCode\":\"v_2_13_1\",\"Ritual\":true,\"CastingTimeFilters\":{\"MaxText\":24,\"MinText\":0,\"MaxUnit\":\"hours\",\"MinUnit\":\"seconds\"},\"Verbal\":true,\"CharacterName\":\"gg\",\"reverse2\":false,\"ApplyFiltersToLists\":true,\"HiddenCasters\":[],\"NotSomatic\":true,\"HiddenSchools\":[],\"NotMaterial\":true,\"DurationFilters\":{\"MinUnit\":\"rounds\",\"MaxUnit\":\"years\",\"MaxText\":5,\"MinText\":2},\"NotVerbal\":true,\"HiddenDurationTypes\":[\"Until dispelled\"],\"HiddenSourcebooks\":[\"Xanathar\'s Guide to Everything\",\"Sword Coast Adv. Guide\",\"Tasha\'s Cauldron of Everything\",\"Lost Laboratory of Kwalish\",\"Rime of the Frostmaiden\",\"Explorer\'s Guide to Wildemount\",\"Strixhaven: A Curriculum of Chaos\",\"Astral Adventurer\'s Guide\"],\"SortField1\":\"Level\",\"SortField2\":\"School\",\"ApplyFiltersToSearch\":false,\"UseTCEExpandedLists\":false,\"RangeFilters\":{\"MinText\":0,\"MaxUnit\":\"miles\",\"MinUnit\":\"feet\",\"MaxText\":1},\"Spells\":[{\"Favorite\":false,\"Prepared\":true,\"SpellName\":\"Jim\'s Glowing Coin\",\"Known\":true},{\"Known\":false,\"SpellName\":\"Fast Friends\",\"Prepared\":true,\"Favorite\":false},{\"SpellName\":\"Gift of Gab\",\"Known\":true,\"Prepared\":true,\"Favorite\":true},{\"SpellName\":\"Raulothim\'s Psychic Lance\",\"Favorite\":false,\"Known\":false,\"Prepared\":true},{\"Favorite\":true,\"Known\":false,\"SpellName\":\"Distort Value\",\"Prepared\":true},{\"Known\":false,\"SpellName\":\"Ashardalon\'s Stride\",\"Favorite\":true,\"Prepared\":false},{\"Prepared\":true,\"Known\":false,\"SpellName\":\"Draconic Transformation\",\"Favorite\":false},{\"Known\":true,\"SpellName\":\"Incite Greed\",\"Prepared\":false,\"Favorite\":false},{\"Known\":false,\"Favorite\":true,\"SpellName\":\"Rime\'s Binding Ice\",\"Prepared\":false},{\"SpellName\":\"Fizban\'s Platinum Shield\",\"Favorite\":true,\"Prepared\":true,\"Known\":true},{\"Prepared\":true,\"Favorite\":true,\"Known\":false,\"SpellName\":\"Summon Draconic Spirit\"}],\"Material\":true,\"Concentration\":false,\"reverse1\":true}"
        
        let sion = SION(json: jsonString)
        let profile = CharacterProfile.fromLegacySION(sion: sion)
        let sortFilterStatus = profile.sortFilterStatus
        let spellFilterStatus = profile.spellFilterStatus
        let spellSlotsStatus = profile.spellSlotStatus
        
        XCTAssertEqual(profile.name, "gg")
        XCTAssertEqual(sortFilterStatus.minSpellLevel, 2)
        XCTAssertEqual(sortFilterStatus.maxSpellLevel, 6)
        XCTAssertEqual(sortFilterStatus.statusFilterField, StatusFilterField.All)
        XCTAssertEqual(sortFilterStatus.firstSortField, SortField.Level)
        XCTAssertEqual(sortFilterStatus.secondSortField, SortField.School)
        XCTAssertEqual(sortFilterStatus.applyFiltersToSearch, false)
        XCTAssertEqual(sortFilterStatus.applyFiltersToLists, true)
        XCTAssertEqual(sortFilterStatus.useTashasExpandedLists, false)
        XCTAssertEqual(sortFilterStatus.getVerbalFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getVerbalFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getSomaticFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getSomaticFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getMaterialFilter(true), true)
        XCTAssertEqual(sortFilterStatus.getMaterialFilter(false), true)
        XCTAssertEqual(sortFilterStatus.getVisibleClasses(true), CasterClass.allCases)
        XCTAssertEqual(sortFilterStatus.getVisibleClasses(false), [])
        XCTAssertEqual(sortFilterStatus.getVisibleSchools(true), School.allCases)
        XCTAssertEqual(sortFilterStatus.getVisibleSchools(false), [])
        
        let hiddenSources = [
            Sourcebook.XanatharsGTE, Sourcebook.SwordCoastAG, Sourcebook.TashasCOE, Sourcebook.LostLabKwalish,
            Sourcebook.RimeOTFrostmaiden, Sourcebook.ExplorersGTW, Sourcebook.StrixhavenCOC, Sourcebook.AstralAG
        ]
        XCTAssertEqual(sortFilterStatus.getVisibleSources(true), complement(items: hiddenSources))
        XCTAssertEqual(sortFilterStatus.getVisibleSources(false), hiddenSources)
        
        let hiddenCTTypes = [CastingTimeType.BonusAction]
        XCTAssertEqual(sortFilterStatus.getVisibleCastingTimeTypes(true), complement(items: hiddenCTTypes))
        XCTAssertEqual(sortFilterStatus.getVisibleCastingTimeTypes(false), hiddenCTTypes)
        
        let hiddenDurationTypes = [DurationType.UntilDispelled]
        XCTAssertEqual(sortFilterStatus.getVisibleDurationTypes(true), complement(items: hiddenDurationTypes))
        XCTAssertEqual(sortFilterStatus.getVisibleDurationTypes(false), hiddenDurationTypes)
        
        let hiddenRangeTypes = [RangeType.Ranged]
        XCTAssertEqual(sortFilterStatus.getVisibleRangeTypes(true), complement(items: hiddenRangeTypes))
        XCTAssertEqual(sortFilterStatus.getVisibleRangeTypes(false), hiddenRangeTypes)
        
        let castingTimeBounds = sortFilterStatus.getCastingTimeBounds()
        XCTAssertEqual(castingTimeBounds.0, 0)
        XCTAssertEqual(castingTimeBounds.1, TimeUnit.second)
        XCTAssertEqual(castingTimeBounds.2, 24)
        XCTAssertEqual(castingTimeBounds.3, TimeUnit.hour)
        
        let durationBounds = sortFilterStatus.getDurationBounds()
        XCTAssertEqual(durationBounds.0, 2)
        XCTAssertEqual(durationBounds.1, TimeUnit.round)
        XCTAssertEqual(durationBounds.2, 5)
        XCTAssertEqual(durationBounds.3, TimeUnit.year)
        
        let rangeBounds = sortFilterStatus.getRangeBounds()
        XCTAssertEqual(rangeBounds.0, 0)
        XCTAssertEqual(rangeBounds.1, LengthUnit.foot)
        XCTAssertEqual(rangeBounds.2, 1)
        XCTAssertEqual(rangeBounds.3, LengthUnit.mile)
        
        
        //spellFilterStatus.getStatus(id: <#T##Int#>)
        
        
        for level in 1...Spellbook.MAX_SPELL_LEVEL {
            XCTAssertEqual(spellSlotsStatus.getAvailableSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getUsedSlots(level: level), 0)
            XCTAssertEqual(spellSlotsStatus.getTotalSlots(level: level), 0)
        }
    }
}
