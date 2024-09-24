//import SION
import Foundation

func intGetter(_ sion: SION, key: String) -> Int {
    if let _ = sion[key].int {
        return sion[key].int!
    } else {
        return Int(sion[key].double!)
    }
}

func has_key(obj: SION, key: String) -> Bool {
	for (k, _) in obj {
		if k.string! == key {
			return true
		}
	}
	return false
}

func load_file(filepath: String) -> String {
	let text = try! String(contentsOf: URL(fileURLWithPath: filepath))
    //print(text)
	return text
}

fileprivate let CONCENTRATION_PREFIX = "Up to "
fileprivate let RITUAL_SUFFIX = " or Ritual"

func parseSpell(obj: SION, b: SpellBuilder) -> Spell {

	// Objects to reuse
	var jstr: String
	var jso: SION
	
	// Set the values that need no/trivial parsing
    b.setID(intGetter(obj, key: "id"))
        .setName(obj["name"].string!)
        .setLevel(intGetter(obj, key: "level"))
        .setSchool(School.fromName(obj["school"].string!))
    
    let locations = obj["locations"]
    if !locations.isNil {
        for location in locations.array! {
            b.addLocation(sourcebook: Sourcebook.fromCode(location["sourcebook"].string!)!, page: location["page"].int!)
        }
    } else {
        b.setLocations([:])
    }
    let durationString = obj["duration"].string! // Use this again later for the concentration part
    do {
        try b.setDuration(Duration.fromString(durationString))
    } catch {
        b.setDuration(Duration())
    }
    do {
        try b.setRange(Range.fromString(obj["range"].string!))
    } catch let e {
        print("\(e)")
        //print("Defaulted to empty distance")
        b.setRange(Range())
    }
    
    if (durationString.starts(with: CONCENTRATION_PREFIX)) {
        b.setConcentration(true)
    } else if has_key(obj: obj, key: "concentration") {
        b.setConcentration(obj["concentration"].bool!)
	} else {
		b.setConcentration(false)
	}

    var castingTimeString = obj["casting_time"].string!
    let endsWithRitual = castingTimeString.hasSuffix(RITUAL_SUFFIX)
    if (endsWithRitual) {
        let finalIndex = castingTimeString.count - RITUAL_SUFFIX.count
        castingTimeString = castingTimeString[...finalIndex]
    }
    do {
        try b.setCastingTime(CastingTime.fromString(castingTimeString))
    } catch {
        b.setCastingTime(CastingTime())
    }
    
    if has_key(obj: obj, key: "ritual") {
        b.setRitual(obj["ritual"].bool!)
    } else {
        b.setRitual(endsWithRitual)
    }

	// Material, if necessary
	if has_key(obj: obj, key: "material") {
		b.setMaterials(obj["material"].string!)
	}
    
    // Royalties, if necessary
    if has_key(obj: obj, key: "royalty") {
        b.setRoyalties(obj["royalty"].string!)
    }

	// components
	var jarr = obj["components"]
	for (_, v) in jarr {
        if v == "V" { b.setVerbal(true); continue }
        if v == "S" { b.setSomatic(true); continue }
        if v == "M" { b.setMaterial(true); continue }
        if v == "R" { b.setRoyalty(true); continue }
	}

	// Description
    b.setDescription(obj["desc"].string!)

	// Higher level description
	var hlString = ""
	if has_key(obj: obj, key: "higher_level") {
        hlString = obj["higher_level"].string!
	}
    b.setHigherLevelDesc(hlString)

	// Classes
	jarr = obj["classes"]
	for (_, name) in jarr {
        b.addClass(CasterClass.fromName(name.string!))
	}

	// Subclasses
	if has_key(obj: obj, key: "subclasses") {
		jarr = obj["subclasses"]
		for (_, name) in jarr {
            b.addSubclass(SubClass.fromName(name.string!))
		}
	}
    
    // Classes
    if has_key(obj: obj, key: "tce_expanded_classes") {
        jarr = obj["tce_expanded_classes"]
        for (_, name) in jarr {
            b.addTashasExpandedClass(CasterClass.fromName(name.string!))
        }
    }
    
    let rulesetName = obj["ruleset"].string
    let ruleset = Ruleset.fromName(rulesetName) ?? Ruleset.Rules2014
    b.setRuleset(ruleset)
    
	return b.buildAndReset()
}

func parseSpellList(jsonStr: String) -> Array<Spell> {
    
    // Create the SpellBuilder
    let builder = SpellBuilder()

    var i = 0
	var spells: Array<Spell> = []
	var jarr = SION(json: jsonStr)
	for (_, obj) in jarr {
        let nextSpell = parseSpell(obj: obj, b: builder)
		spells.append(nextSpell)
        i += 1
	}
    spells.sort(by: { $0.name < $1.name })
	return spells

}
