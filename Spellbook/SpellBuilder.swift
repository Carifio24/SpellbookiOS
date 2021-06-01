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
    private(set) var id: Int = 0
    private(set) var name: String = ""
    private(set) var description: String = ""
    private(set) var higherLevel: String = ""
    private(set) var range: Range = Range()
    private(set) var verbal: Bool = false
    private(set) var somatic: Bool = false
    private(set) var material: Bool = false
    private(set) var royalty: Bool = false
    private(set) var materials: String = ""
    private(set) var royalties: String = ""
    private(set) var ritual: Bool = false
    private(set) var duration: Duration = Duration()
    private(set) var concentration: Bool = false
    private(set) var castingTime: CastingTime = CastingTime()
    private(set) var level: Int = -1
    private(set) var school: School = School.Abjuration
    private(set) var classes: Array<CasterClass> = []
    private(set) var subclasses: Array<SubClass> = []
    private(set) var tashasExpandedClasses: Array<CasterClass> = []
    private(set) var locations: [Sourcebook:Int] = [:]
    
    // Setters
    func setID(_ id: Int) -> SpellBuilder { self.id = id; return self }
    func setName(_ name: String) -> SpellBuilder { self.name = name; return self }
    func setDescription(_ desc: String) -> SpellBuilder { self.description = desc; return self }
    func setHigherLevelDesc(_ higherLevel: String) -> SpellBuilder { self.higherLevel = higherLevel; return self }
    func setRange(_ range: Range) -> SpellBuilder { self.range = range; return self }
    func setVerbal(_ verbal: Bool) -> SpellBuilder { self.verbal = verbal; return self }
    func setSomatic(_ somatic: Bool) -> SpellBuilder { self.somatic = somatic; return self }
    func setMaterial(_ material: Bool) -> SpellBuilder { self.material = material; return self }
    func setRoyalty(_ royalty: Bool) -> SpellBuilder { self.royalty = royalty; return self }
    func setMaterials(_ materials: String) -> SpellBuilder { self.materials = materials; return self }
    func setRoyalties(_ royalties: String) -> SpellBuilder { self.royalties = royalties; return self }
    func setRitual(_ ritual: Bool) -> SpellBuilder { self.ritual = ritual; return self }
    func setDuration(_ duration: Duration) -> SpellBuilder { self.duration = duration; return self }
    func setConcentration(_ concentration: Bool) -> SpellBuilder { self.concentration = concentration; return self }
    func setCastingTime(_ castingTime: CastingTime) -> SpellBuilder { self.castingTime = castingTime; return self }
    func setLevel(_ level: Int) -> SpellBuilder { self.level = level; return self }
    func setSchool(_ school: School) -> SpellBuilder { self.school = school; return self }
    func setClasses(_ classes: Array<CasterClass>) -> SpellBuilder { self.classes = classes; return self }
    func setSubclasses(_ subclasses: Array<SubClass>) -> SpellBuilder { self.subclasses = subclasses; return self }
    func setTashasExpandedClasses(_ classes: Array<CasterClass>) -> SpellBuilder { self.tashasExpandedClasses = classes; return self }
    func setLocations(_ locations: [Sourcebook:Int]) -> SpellBuilder { self.locations = locations; return self }
    
    func addClass(_ cc: CasterClass) -> SpellBuilder { self.classes.append(cc); return self }
    func addSubclass(_ sc: SubClass) -> SpellBuilder { self.subclasses.append(sc); return self }
    func addTashasExpandedClass(_ cc: CasterClass) -> SpellBuilder { self.tashasExpandedClasses.append(cc); return self }
    func addLocation(sourcebook: Sourcebook, page: Int) -> SpellBuilder { self.locations[sourcebook] = page; return self }
    
    
    // Build
    func build() -> Spell {
        return Spell(id: id, name: name, description: description, higherLevel: higherLevel, range: range, verbal: verbal, somatic: somatic, material: material, royalty: royalty, materials: materials, royalties: royalties, ritual: ritual, duration: duration, concentration: concentration, castingTime: castingTime, level: level, school: school, classes: classes, subclasses: subclasses, tashasExpandedClasses: tashasExpandedClasses, locations: locations)
    }
    
    // Reset to default values
    func reset() {
        id = 0; name = ""; description = ""; higherLevel = "";
        range = Range(); verbal = false; somatic = false; material = false; royalty = false;
        materials = ""; royalties = ""; ritual = false; duration = Duration();
        concentration = false; castingTime = CastingTime(); level = 0;
        school = School.Abjuration; classes = []; subclasses = [];
        tashasExpandedClasses = []; locations = [:]
    }
    
    // Build and reset
    func buildAndReset() -> Spell {
        let spell: Spell = build()
        reset()
        return spell
    }
    
}
