//
//  SpellCodec.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 5/31/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

class SpellCodec {
    private static let ID_KEY = "id"
    private static let NAME_KEY = "name"
    private static let PAGE_KEY = "page"
    private static let DURATION_KEY = "duration"
    private static let RANGE_KEY = "range"
    private static let RITUAL_KEY = "ritual"
    private static let CONCENTRATION_KEY = "concentration"
    private static let LEVEL_KEY = "level"
    private static let CASTING_TIME_KEY = "casting_time"
    private static let MATERIAL_KEY = "material"
    private static let ROYALTY_KEY = "royalty"
    private static let COMPONENTS_KEY = "components"
    private static let DESCRIPTION_KEY = "desc"
    private static let HIGHER_LEVEL_KEY = "higher_level"
    private static let SCHOOL_KEY = "school"
    private static let CLASSES_KEY = "classes"
    private static let SUBCLASSES_KEY = "subclasses"
    private static let TCE_EXPANDED_CLASSES_KEY = "tce_expanded_classes"
    private static let SOURCEBOOK_KEY = "sourcebook"
    private static let LOCATIONS_KEY = "locations"
    private static let RULESET_KEY = "ruleset"
    
    private static let COMPONENT_STRINGS = ["V", "S", "M", "R"]
    
    private static let CONCENTRATION_PREFIX = "Up to"
    private static let RITUAL_SUFFIX = " or Ritual"

    func parseSpell(sion: SION, b: SpellBuilder) -> Spell {

        // Set the values that need no/trivial parsing
        b.setID(intGetter(sion, key: SpellCodec.ID_KEY))
            .setName(sion[SpellCodec.NAME_KEY].string!)
            .setLevel(intGetter(sion, key: SpellCodec.LEVEL_KEY))
            .setSchool(School.fromName(sion[SpellCodec.SCHOOL_KEY].string!))
        
        let locations = sion[SpellCodec.LOCATIONS_KEY]
        if let array = locations.array {
            for location in array {
                if let sb = Sourcebook.fromCode(location[SpellCodec.SOURCEBOOK_KEY].string) {
                    b.addLocation(sourcebook: sb, page: intGetter(location, key: SpellCodec.PAGE_KEY))
                }
            }
        }
        let durationString = sion[SpellCodec.DURATION_KEY].string! // Use this again later for the concentration part
        do {
            try b.setDuration(Duration.fromString(durationString))
        } catch {
            b.setDuration(Duration())
        }
        
        do {
            try b.setRange(Range.fromString(sion[SpellCodec.RANGE_KEY].string!))
        } catch {
            b.setRange(Range())
        }
        
        if (durationString.starts(with: SpellCodec.CONCENTRATION_PREFIX)) {
            b.setConcentration(true)
        } else {
            b.setConcentration(sion[SpellCodec.CONCENTRATION_KEY].bool ?? false)
        }
        
        var castingTimeString = sion[SpellCodec.CASTING_TIME_KEY].string!
        let endsWithRitual = castingTimeString.hasSuffix(SpellCodec.RITUAL_SUFFIX)
        if (endsWithRitual) {
            let finalIndex = castingTimeString.count - SpellCodec.RITUAL_SUFFIX.count - 1
            castingTimeString = castingTimeString[...finalIndex]
        }
        
        do {
            try b.setCastingTime(CastingTime.fromString(castingTimeString))
        } catch {
            b.setCastingTime(CastingTime())
        }
        
        b.setRitual(sion[SpellCodec.RITUAL_KEY].bool ?? endsWithRitual)
        
        b.setMaterials(sion[SpellCodec.MATERIAL_KEY].string ?? "")
        b.setRoyalties(sion[SpellCodec.ROYALTY_KEY].string ?? "")
        
        // components
        let components = sion[SpellCodec.COMPONENTS_KEY]
        for (_, v) in components {
            if v == "V" { b.setVerbal(true); continue }
            if v == "S" { b.setSomatic(true); continue }
            if v == "M" { b.setMaterial(true); continue }
            if v == "R" { b.setRoyalty(true); continue }
        }
        
        // Description
        b.setDescription(sion[SpellCodec.DESCRIPTION_KEY].string!)
        
        // Higher level description
        let hlString = sion[SpellCodec.HIGHER_LEVEL_KEY].string ?? ""
        b.setHigherLevelDesc(hlString)
        
        let classes = sion[SpellCodec.CLASSES_KEY]
        if let array = classes.array {
            for cls in array {
                b.addClass(CasterClass.fromName(cls.string!))
            }
        }
        
        let subclasses = sion[SpellCodec.SUBCLASSES_KEY]
        if let array = subclasses.array {
            for subclass in array {
                b.addSubclass(SubClass.fromName(subclass.string!))
            }
        }
        
        let tceExpandedClasses = sion[SpellCodec.TCE_EXPANDED_CLASSES_KEY]
        if let array = tceExpandedClasses.array {
            for cls in array {
                b.addTashasExpandedClass(CasterClass.fromName(cls.string!))
            }
        }

        let rulesetName = sion[SpellCodec.RULESET_KEY].string
        let ruleset = Ruleset.fromName(rulesetName) ?? Ruleset.Rules2014
        b.setRuleset(ruleset)
        
        return b.buildAndReset()
    }
}
