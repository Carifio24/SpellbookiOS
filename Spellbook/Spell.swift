public class Spell {

	// Member values
    let name: String
	let description: String
	let higherLevel: String
	let page: Int
	let range: Range
	let components: Array<Bool>
	let material: String
	let ritual: Bool
	let duration: Duration
    let concentration: Bool
	let castingTime: String
	let level: Int
	let school: School
	let classes: Array<CasterClass>
	let subclasses: Array<SubClass>
    let sourcebook: Sourcebook

	// Constructor
    init(name: String, description: String, higherLevel: String, page: Int, range: Range, components: Array<Bool>, material: String, ritual: Bool, duration: Duration, concentration: Bool, castingTime: String, level: Int, school: School, classes: Array<CasterClass>, subclasses: Array<SubClass>, sourcebook: Sourcebook) {
        self.name = name; self.description = description; self.higherLevel = higherLevel;
        self.page = page; self.range = range; self.components = components; self.material = material;
        self.ritual = ritual; self.duration = duration; self.concentration = concentration;
        self.castingTime = castingTime; self.level = level; self.school = school;
        self.classes = classes; self.subclasses = subclasses; self.sourcebook = sourcebook;
    }
    
    // Default constructor (for convenience, when necessary)
    convenience init() {
        self.init(name: "", description: "", higherLevel: "", page: 0, range: Range(), components: [false,false,false], material: "", ritual: false, duration: Duration(), concentration: false, castingTime: "", level: 0, school: School.Abjuration, classes: [], subclasses: [], sourcebook: Sourcebook.PlayersHandbook)
    }
    

	// Components as a string
	func componentsString() -> String {
		var compStr = String();
		if components[0] {compStr += "V"}
		if components[1] {compStr += "S"}
		if components[2] {compStr += "M"}
		return compStr
	}

	// Classes as a string
	func classesString() -> String {
		var classStrings: Array<String> = []
		for i in 0...classes.count-1 {
			classStrings.append(Spellbook.casterNames[classes[i].rawValue])
		}
		return classStrings.joined(separator: ", ")
	}

	// Other member functions
	func usableByClass(_ cc: CasterClass) -> Bool {
		return classes.contains(cc)
	}

	func usableBySubclass(_ sub: SubClass) -> Bool {
		return subclasses.contains(sub)
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
		return lhs.name == rhs.name
	}

}

// So that we can use Spell as a dictionary key
extension Spell: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}
