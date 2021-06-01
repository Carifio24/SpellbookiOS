public class Spell {

	// Member values
    let id: Int
    let name: String
	let description: String
	let higherLevel: String
	let range: Range
    let verbal: Bool
    let somatic: Bool
    let material: Bool
    let royalty: Bool
	let materials: String
    let royalties: String
	let ritual: Bool
	let duration: Duration
    let concentration: Bool
	let castingTime: CastingTime
	let level: Int
	let school: School
	let classes: Array<CasterClass>
	let subclasses: Array<SubClass>
    let tashasExpandedClasses: Array<CasterClass>
    let locations: [Sourcebook:Int]

	// Constructor
    init(id: Int, name: String, description: String, higherLevel: String, range: Range, verbal: Bool, somatic: Bool, material: Bool, royalty: Bool, materials: String, royalties: String, ritual: Bool, duration: Duration, concentration: Bool, castingTime: CastingTime, level: Int, school: School, classes: Array<CasterClass>, subclasses: Array<SubClass>, tashasExpandedClasses: Array<CasterClass>, locations: [Sourcebook:Int]) {
        self.id = id; self.name = name; self.description = description; self.higherLevel = higherLevel;
        self.range = range;
        self.verbal = verbal; self.somatic = somatic; self.material = material; self.royalty = royalty;
        self.materials = materials; self.royalties = royalties;
        self.ritual = ritual; self.duration = duration; self.concentration = concentration;
        self.castingTime = castingTime; self.level = level; self.school = school;
        self.classes = classes; self.subclasses = subclasses;
        self.tashasExpandedClasses = tashasExpandedClasses; self.locations = locations;
    }
    
    // Default constructor (for convenience, when necessary)
    convenience init() {
        self.init(id: 0, name: "", description: "", higherLevel: "", range: Range(), verbal: false, somatic: false, material: false, royalty: false, materials: "", royalties: "", ritual: false, duration: Duration(), concentration: false, castingTime: CastingTime(), level: 0, school: School.Abjuration, classes: [], subclasses: [], tashasExpandedClasses: [], locations: [:])
    }
    

	// Components as a string
	func componentsString() -> String {
		var compStr = String();
		if verbal {compStr += "V"}
		if somatic {compStr += "S"}
		if material {compStr += "M"}
        if royalty { compStr += "R" }
		return compStr
	}

	// Classes as a string
	func classesString() -> String {
        return classes.map({ cc in cc.displayName }).joined(separator: ", ")
	}
    
    func tashasExpandedClassesString() -> String {
        return tashasExpandedClasses.map({ cc in cc.displayName }).joined(separator: ", ")
    }

	// Other member functions
    func usableByClass(_ cc: CasterClass, expanded: Bool = false) -> Bool {
        let regularUsable = classes.contains(cc)
        return regularUsable || (expanded && tashasExpandedClasses.contains(cc))
	}

	func usableBySubclass(_ sub: SubClass) -> Bool {
		return subclasses.contains(sub)
	}
    
    func isIn(sourcebook: Sourcebook) -> Bool {
        return locations[sourcebook] != nil
    }
    
    func sourcebooksString() -> String {
        return locations.map{$0.key.code.uppercased()}.joined(separator: ", ")
    }
    
    // School and level as a String
    func levelSchoolString() -> String {
        var text = String(level)
        switch (level) {
        case 0:
            text = school.displayName + " cantrip"
            return text
        case 1:
            text.append("st-level ")
            break
        case 2:
            text.append("nd-level ")
            break
        case 3:
            text.append("rd-level ")
            break
        default:
            text.append("th-level ")
        }
        text = text + school.displayName.lowercased()
        if ritual {
            text = text + " (ritual)"
        }
        return text
    }
    

}


// To test if two spells are the same
extension Spell : Equatable {

	static public func == (lhs: Spell, rhs: Spell) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
	}

}

// So that we can use Spell as a dictionary key
extension Spell: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}
