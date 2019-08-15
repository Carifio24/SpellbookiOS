public class Spell {

	// Member values
	private(set) let name: String
	private(set) let description: String
	private(set) let higherLevel: String
	private(set) let page: Int
	private(set) let range: String
	private(set) let components: Array<Bool>
	private(set) let material: String
	private(set) let ritual: Bool
	private(set) let duration: Duration
    private(set) let concentration: Bool
	private(set) let castingTime: String
	private(set) let level: Int
	private(set) let school: School
	private(set) let classes: Array<CasterClass>
	private(set) let subclasses: Array<SubClass>
    private(set) let sourcebook: Sourcebook

	// Constructor
    init(name: String, description: String, higherLevel: String, page: Int, range: Distance, components: Array<Bool>, material: String, ritual: Bool, duration: Duration, concentration: Bool, castingTime: String, level: Int, school: School, classes: Array<CasterClass>, subclasses: Array<SubClass>, sourcebook: Sourcebook) {
        self.name = name; self.description = description; self.higherLevel = higherLevel;
        self.page = page; self.range = range; self.components = components; self.material = material;
        self.ritual = ritual; self.duration = duration; self.concentration = concentration;
        self.castingTime = castingTime; self.level = level; self.school = school;
        self.classes = classes; self.subclasses = subclasses; self.sourcebook = sourcebook;
    }
    
    // Default constructor (for convenience, when necessary)
    convenience init() {
        name = ""; description = ""; higherLevel = ""; page = 0; range = Distance();
        components = []; material = ""; ritual = false; duration = ""; concentration = false;
        castingTime = ""; level = 0; school = School.Abjuration; classes = []; subclasses = [];
        sourcebook = Sourcebook.PlayersHandbook
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
