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
    private(set) var verbal: Bool = false
    private(set) var somatic: Bool = false
    private(set) var material: Bool = false
    private(set) var materials: String = ""
    private(set) var ritual: Bool = false
    private(set) var duration: Duration = Duration()
    private(set) var concentration: Bool = false
    private(set) var castingTime: CastingTime = CastingTime()
    private(set) var level: Int = -1
    private(set) var school: School = School.Abjuration
    private(set) var classes: Array<CasterClass> = []
    private(set) var subclasses: Array<SubClass> = []
    private(set) var sourcebook: Sourcebook = Sourcebook.PlayersHandbook
    
    // Setters
    func setName(_ name: String) -> SpellBuilder { self.name = name; return self }
    func setDescription(_ desc: String) -> SpellBuilder { self.description = desc; return self }
    func setHigherLevelDesc(_ higherLevel: String) -> SpellBuilder { self.higherLevel = higherLevel; return self }
    func setPage(_ page: Int) -> SpellBuilder { self.page = page; return self }
    func setRange(_ range: Range) -> SpellBuilder { self.range = range; return self }
    func setVerbal(_ verbal: Bool) -> SpellBuilder { self.verbal = verbal; return self }
    func setSomatic(_ somatic: Bool) -> SpellBuilder { self.somatic = somatic; return self }
    func setMaterial(_ material: Bool) -> SpellBuilder { self.material = material; return self }
    func setMaterials(_ materials: String) -> SpellBuilder { self.materials = materials; return self }
    func setRitual(_ ritual: Bool) -> SpellBuilder { self.ritual = ritual; return self }
    func setDuration(_ duration: Duration) -> SpellBuilder { self.duration = duration; return self }
    func setConcentration(_ concentration: Bool) -> SpellBuilder { self.concentration = concentration; return self }
    func setCastingTime(_ castingTime: CastingTime) -> SpellBuilder { self.castingTime = castingTime; return self }
    func setLevel(_ level: Int) -> SpellBuilder { self.level = level; return self }
    func setSchool(_ school: School) -> SpellBuilder { self.school = school; return self }
    func setClasses(_ classes: Array<CasterClass>) -> SpellBuilder { self.classes = classes; return self }
    func setSubclasses(_ subclasses: Array<SubClass>) -> SpellBuilder { self.subclasses = subclasses; return self }
    func setSourcebook(_ sourcebook: Sourcebook) -> SpellBuilder { self.sourcebook = sourcebook; return self }
    
    
    // Build
    func build() -> Spell {
        return Spell(name: name, description: description, higherLevel: higherLevel, page: page, range: range, verbal: verbal, somatic: somatic, material: material, materials: materials, ritual: ritual, duration: duration, concentration: concentration, castingTime: castingTime, level: level, school: school, classes: classes, subclasses: subclasses, sourcebook: sourcebook)
    }
    
    // Reset to default values
    func reset() {
        name = ""; description = ""; higherLevel = "";
        page = 0; range = Range(); verbal = false; somatic = false; material = false;
        materials = ""; ritual = false; duration = Duration();
        concentration = false; castingTime = CastingTime(); level = 0;
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
