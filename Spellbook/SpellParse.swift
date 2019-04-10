//import SION
import Foundation

func has_key(obj: SION, key: String) -> Bool {
	for (k, _) in obj {
		if k.string! == key {
			return true
		}
	}
	return false
}

func schoolFromName(name: String) -> School? {
	return School(rawValue: Spellbook.schoolNames.firstIndex(of: name)!)
}

func casterFromName(name: String) -> CasterClass? {
	return CasterClass(rawValue: Spellbook.casterNames.firstIndex(of: name)!)
}

func subclassFromName(name: String) -> SubClass? {
	return SubClass(rawValue: Spellbook.subclassNames.firstIndex(of: name)!)
}

func sourcebookFromCode(name: String) -> Sourcebook? {
	return Sourcebook(rawValue: Spellbook.sourcebookCodes.firstIndex(of: name)!)
}

func load_file(filepath: String) -> String {
	let text = try! String(contentsOf: URL(fileURLWithPath: filepath))
    print(text)
	return text
}

func parseSpell(obj: SION) -> Spell {

	// Create the Spell
	let s = Spell()

	// Objects to reuse
	var jstr: String
	var jso: SION
	
	// Set the values that need no/trivial parsing
	s.setName(nameIn: obj["name"].string!)
	jstr = obj["page"].string!
    let locationPieces = jstr.components(separatedBy: " ")
	let page = Int(locationPieces[1])!
	s.setPage(pageIn: page)
    let sourcebook = sourcebookFromCode(name: locationPieces[0])!
    s.setSourcebook(sourcebookIn: sourcebook)
    let durationString = obj["duration"].string! // Use this again later for the concentration part
	s.setDuration(durationIn: durationString)
	s.setRange(rangeIn: obj["range"].string!)

	if has_key(obj: obj, key: "ritual") {
		let ritualString = try! yn_to_bool(yn: obj["ritual"].string!)
		s.setRitual(ritualIn: ritualString)
	} else {
		s.setRitual(ritualIn: false)
	}
    if (durationString.starts(with: "Up to")) {
        s.setConcentration(concentrationIn: true)
    } else if has_key(obj: obj, key: "concentration") {
        let concentrationString = obj["concentration"].string!
        s.setConcentration(concentrationIn: try! yn_to_bool(yn: concentrationString))
	} else {
		s.setConcentration(concentrationIn: false)
	}

    //print(obj["level"].double)
    var isInt: Bool = false
    if let _ = obj["level"].int {
        isInt = true
    }
    if isInt {
        s.setLevel(levelIn: Int(obj["level"].int!))
    } else {
        s.setLevel(levelIn: Int(obj["level"].double!))
    }

    s.setCastingTime(castingTimeIn: obj["casting_time"].string!)

	// Material, if necessary
	if has_key(obj: obj, key: "material") {
		s.setMaterial(materialIn: obj["material"].string!)
	}

	// components
	var components = [false, false, false]
	var jarr = obj["components"]
	for (_, v) in jarr {
		if v == "V" {components[0] = true; continue}
		if v == "S" {components[1] = true; continue}
		if v == "M" {components[2] = true; continue}
	}
	s.setComponents(componentsIn: components)

	// Description
	jstr = String()
	var firstAdded = false
	jarr = obj["desc"]
	for (_, v) in jarr {
		if !firstAdded {
			firstAdded = true
		} else {
			jstr += "\n"
		}
		jstr += v.string!
	}
	s.setDescription(descriptionIn: jstr)

	// Higher level description
	jstr = String()
	firstAdded = false
	if has_key(obj: obj, key: "higher_level") {
        jarr = obj["higher_level"]
		for (_, v) in jarr {
			if !firstAdded {
				firstAdded = true
			} else {
				jstr += "\n"
			}
			jstr += v.string!
		}
	}
    s.setHigherLevelDesc(higherLevelIn: jstr)

	// School
	jso = obj["school"]
	var name: String = jso["name"].string!
	s.setSchool(schoolIn: schoolFromName(name: name)!)

	// Classes
	var classes: Array<CasterClass> = []
	jarr = obj["classes"]
	for (_, v) in jarr {
        var name = v["name"].string
        if name != nil {
            classes.append(casterFromName(name: name!)!)
        } else {
            name = v.string!
            classes.append(casterFromName(name: name!)!)
        }
	}
	s.setClasses(classesIn: classes)

	// Subclasses
	var subclasses: Array<SubClass> = []
	if has_key(obj: obj, key: "subclasses") {
		jarr = obj["subclasses"]
		for (_, v) in jarr {
			name = v["name"].string!
			subclasses.append(subclassFromName(name: name)!)
		}
		s.setSubclasses(subclassesIn: subclasses)
	}

	// Return
	return s
}

func parseSpellList(jsonStr: String) -> Array<Spell> {

    var i = 0
	var spells: Array<Spell> = []
	var jarr = SION(json: jsonStr)
	for (_, v) in jarr {
        //print("\(v)")
        //print("=====")
		let nextSpell = parseSpell(obj: v)
		spells.append(nextSpell)
        i += 1
	}
    spells.sort(by: { $0.name < $1.name })
	return spells

}
