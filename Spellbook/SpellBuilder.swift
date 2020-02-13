//
//  SpellBuilder.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/14/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

public class SpellBuilder {
    
    // Constructor
    init() {}
    
    // Member values
    private(set) var name: String = ""
    private(set) var description: String = ""
    private(set) var higherLevel: String = ""
    private(set) var page: Int = 0
    private(set) var range: Range = Range()
    private(set) var components: Array<Bool> = [false,false,false]
    private(set) var material: String = ""
    private(set) var ritual: Bool = false
    private(set) var duration: Duration = Duration()
    private(set) var concentration: Bool = false
    private(set) var castingTime: String = ""
    private(set) var level: Int = -1
    private(set) var school: School = School.Abjuration
    private(set) var classes: Array<CasterClass> = []
    private(set) var subclasses: Array<SubClass> = []
    private(set) var sourcebook: Sourcebook = Sourcebook.PlayersHandbook
    
    // Setters
    func setName(_ nameIn: String) -> SpellBuilder { name = nameIn; return self }
    func setDescription(_ descIn: String) -> SpellBuilder { description = descIn; return self }
    func setHigherLevelDesc(_ higherLevelIn: String) -> SpellBuilder { higherLevel = higherLevelIn; return self }
    func setPage(_ pageIn: Int) -> SpellBuilder { page = pageIn; return self }
    func setRange(_ rangeIn: Range) -> SpellBuilder { range = rangeIn; return self }
    func setComponents(_ componentsIn: Array<Bool>) -> SpellBuilder { components = componentsIn; return self }
    func setMaterial(_ materialIn: String) -> SpellBuilder { material = materialIn; return self }
    func setRitual(_ ritualIn: Bool) -> SpellBuilder { ritual = ritualIn; return self }
    func setDuration(_ durationIn: Duration) -> SpellBuilder { duration = durationIn; return self }
    func setConcentration(_ concentrationIn: Bool) -> SpellBuilder { concentration = concentrationIn; return self }
    func setCastingTime(_ castingTimeIn: String) -> SpellBuilder { castingTime = castingTimeIn; return self }
    func setLevel(_ levelIn: Int) -> SpellBuilder { level = levelIn; return self }
    func setSchool(_ schoolIn: School) -> SpellBuilder { school = schoolIn; return self }
    func setClasses(_ classesIn: Array<CasterClass>) -> SpellBuilder { classes = classesIn; return self }
    func setSubclasses(_ subclassesIn: Array<SubClass>) -> SpellBuilder { subclasses = subclassesIn; return self }
    func setSourcebook(_ sourcebookIn: Sourcebook) -> SpellBuilder { sourcebook = sourcebookIn; return self }
    
    
    // Build
    func build() -> Spell {
        return Spell(name: name, description: description, higherLevel: higherLevel, page: page, range: range, components: components, material: material, ritual: ritual, duration: duration, concentration: concentration, castingTime: castingTime, level: level, school: school, classes: classes, subclasses: subclasses, sourcebook: sourcebook)
    }
    
    // Reset to default values
    func reset() {
        name = ""; description = ""; higherLevel = "";
        page = 0; range = Range(); components = [false,false,false];
        material = ""; ritual = false; duration = Duration();
        concentration = false; castingTime = ""; level = 0;
        school = School.Abjuration; classes = []; subclasses = [];
        sourcebook = Sourcebook.PlayersHandbook
    }
    
    // Build and reset
    func buildAndReset() -> Spell {
        let spell: Spell = build()
        reset()
        return spell
    }
    
}
