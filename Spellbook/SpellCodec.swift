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
    
    private static let COMPONENT_STRINGS = ["V", "S", "M", "R"]
    
    private static let CONCENTRATION_PREFIX = "Up to"
    
    func parseSpell(sion: SION, b: SpellBuilder) -> Spell {
        
        // Set the values that need no/trivial parsing
        b.setID(intGetter(sion, key: SpellCodec.ID_KEY))
            .setName(sion[SpellCodec.NAME_KEY].string!)
            .setLevel(intGetter(sion, key: SpellCodec.LEVEL_KEY))
            .setSchool(School.fromName(sion[SpellCodec.SCHOOL_KEY].string!))
        
        let locations = sion["locations"]
        if !locations.isNil {
            if let array = locations.array {
                for location in array {
                    if let sb = Sourcebook.fromCode(location[SpellCodec.SOURCEBOOK_KEY].string) {
                        b.addLocation(sourcebook: sb, page: intGetter(location, key: SpellCodec.PAGE_KEY))
                    }
                }
            }
        }
        
        let durationString = sion["duration"].string ?? ""
        do {
            try b.setDuration(Duration.fromString(durationString))
        } catch {
            b.setDuration(Duration())
        }
        
        do {
            try b.setRange(Range.fromString(sion["range"].string ?? ""))
        } catch {
            b.setRange(Range())
        }
        
        let ritual = hasKey(sion, key: "ritual") && (sion["ritual"].bool ?? false)
        b.setRitual(ritual)
        
        let concentration = durationString.starts(with: "Up to")
        && (sion["concentration"].bool ?? false)
        b.setConcentration(concentration)
        
        let castingTimeString = sion["casting_time"].string ?? ""
        do {
            try b.setCastingTime(CastingTime.fromString(castingTimeString))
            
        } catch {
            b.setCastingTime(CastingTime())
        }
        
        if hasKey(sion, key: "material") {
            b.setMaterials(sion["material"].string ?? "")
        }
        
        if hasKey(obj, key: "royalty") {
            b.setRoyalties(sion["royalty"].string ?? "")
        }
        
        
        
        
        return b.buildAndReset()
        
    }
}
