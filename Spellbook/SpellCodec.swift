//
//  SpellCodec.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/13/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//


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

    func parseSpell(sion: SION, builder spellBuilder: SpellBuilder? = nil) -> Spell {
        
        let builder = spellBuilder ?? SpellBuilder()

        // Set the values that need no/trivial parsing
        builder.setID(intGetter(sion, key: SpellCodec.ID_KEY))
            .setName(sion[SpellCodec.NAME_KEY].string!)
            .setLevel(intGetter(sion, key: SpellCodec.LEVEL_KEY))
            .setSchool(School.fromName(sion[SpellCodec.SCHOOL_KEY].string!))
        
        let locations = sion[SpellCodec.LOCATIONS_KEY]
        if let array = locations.array {
            for location in array {
                if let sb = Sourcebook.fromCode(location[SpellCodec.SOURCEBOOK_KEY].string) {
                    builder.addLocation(sourcebook: sb, page: intGetter(location, key: SpellCodec.PAGE_KEY))
                }
            }
        }
        let durationString = sion[SpellCodec.DURATION_KEY].string! // Use this again later for the concentration part
        do {
            try builder.setDuration(Duration.fromString(durationString))
        } catch {
            builder.setDuration(Duration())
        }
        
        do {
            try builder.setRange(Range.fromString(sion[SpellCodec.RANGE_KEY].string!))
        } catch {
            builder.setRange(Range())
        }
        
        if (durationString.starts(with: SpellCodec.CONCENTRATION_PREFIX)) {
            builder.setConcentration(true)
        } else {
            builder.setConcentration(sion[SpellCodec.CONCENTRATION_KEY].bool ?? false)
        }
        
        var castingTimeString = sion[SpellCodec.CASTING_TIME_KEY].string!
        let endsWithRitual = castingTimeString.hasSuffix(SpellCodec.RITUAL_SUFFIX)
        if (endsWithRitual) {
            let finalIndex = castingTimeString.count - SpellCodec.RITUAL_SUFFIX.count - 1
            castingTimeString = castingTimeString[...finalIndex]
        }
        
        do {
            try builder.setCastingTime(CastingTime.fromString(castingTimeString))
        } catch {
            builder.setCastingTime(CastingTime())
        }
        
        builder.setRitual(sion[SpellCodec.RITUAL_KEY].bool ?? endsWithRitual)
        
        builder.setMaterials(sion[SpellCodec.MATERIAL_KEY].string ?? "")
        builder.setRoyalties(sion[SpellCodec.ROYALTY_KEY].string ?? "")
        
        // components
        let components = sion[SpellCodec.COMPONENTS_KEY]
        for (_, v) in components {
            if v == "V" { builder.setVerbal(true); continue }
            if v == "S" { builder.setSomatic(true); continue }
            if v == "M" { builder.setMaterial(true); continue }
            if v == "R" { builder.setRoyalty(true); continue }
        }
        
        // Description
        builder.setDescription(sion[SpellCodec.DESCRIPTION_KEY].string!)
        
        // Higher level description
        let hlString = sion[SpellCodec.HIGHER_LEVEL_KEY].string ?? ""
        builder.setHigherLevelDesc(hlString)
        
        let classes = sion[SpellCodec.CLASSES_KEY]
        if let array = classes.array {
            for cls in array {
                builder.addClass(CasterClass.fromName(cls.string!))
            }
        }
        
        let subclasses = sion[SpellCodec.SUBCLASSES_KEY]
        if let array = subclasses.array {
            for subclass in array {
                builder.addSubclass(SubClass.fromName(subclass.string!))
            }
        }
        
        let tceExpandedClasses = sion[SpellCodec.TCE_EXPANDED_CLASSES_KEY]
        if let array = tceExpandedClasses.array {
            for cls in array {
                builder.addTashasExpandedClass(CasterClass.fromName(cls.string!))
            }
        }

        let rulesetName = sion[SpellCodec.RULESET_KEY].string
        let ruleset = rulesetName != nil ? Ruleset.fromName(rulesetName!) : Ruleset.Rules2014
        builder.setRuleset(ruleset)
        
        return builder.buildAndReset()
    }
    
    func toSION(_ spell: Spell) -> SION {
        var sion: SION = [:]
        
        sion[SpellCodec.ID_KEY].int = spell.id
        sion[SpellCodec.NAME_KEY].string = spell.name
        sion[SpellCodec.DESCRIPTION_KEY].string = spell.description
        sion[SpellCodec.HIGHER_LEVEL_KEY].string = spell.higherLevel
        sion[SpellCodec.LEVEL_KEY].int = spell.level
        sion[SpellCodec.SCHOOL_KEY].string = spell.school.displayName

        sion[SpellCodec.RANGE_KEY].string = spell.range.string()
        sion[SpellCodec.DURATION_KEY].string = spell.duration.string()
        sion[SpellCodec.CASTING_TIME_KEY].string = spell.castingTime.string()

        sion[SpellCodec.RITUAL_KEY].bool = spell.ritual
        sion[SpellCodec.CONCENTRATION_KEY].bool = spell.concentration

        sion[SpellCodec.MATERIAL_KEY].string = spell.materials
        sion[SpellCodec.ROYALTY_KEY].string = spell.royalties

        var components: [String] = []
        if spell.verbal { components.append("V") }
        if spell.somatic { components.append("S") }
        if spell.material { components.append("M") }
        if spell.royalty { components.append("R") }

        sion[SpellCodec.CLASSES_KEY].array = spell.classes.map { SION($0.displayName) }
        sion[SpellCodec.SUBCLASSES_KEY].array = spell.subclasses.map { SION($0.displayName) }
        sion[SpellCodec.TCE_EXPANDED_CLASSES_KEY].array = spell.tashasExpandedClasses.map { SION($0.displayName) }

        sion[SpellCodec.RULESET_KEY].string = spell.ruleset.displayName

        sion[SpellCodec.LOCATIONS_KEY].array = spell.locations.map {
            entry in
            return [
                SION.Key(SpellCodec.SOURCEBOOK_KEY): SION(entry.key.displayName),
                SION.Key(SpellCodec.PAGE_KEY): SION(entry.value),
            ]
        }

        return sion
    }
}
