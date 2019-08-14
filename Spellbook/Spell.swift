public class Spell {

	// Member values
	private(set) var name: String = ""
	private(set) var description: String = ""
	private(set) var higherLevel: String = ""
	private(set) var page: Int = 0
	private(set) var range: String = ""
	private(set) var components: Array<Bool> = []
	private(set) var material: String = ""
	private(set) var ritual: Bool = false
	private(set) var duration: String = ""
	private(set) var concentration: Bool = false
	private(set) var castingTime: String = ""
	private(set) var level: Int = -1
	private(set) var school: School = School.Abjuration
	private(set) var classes: Array<CasterClass> = []
	private(set) var subclasses: Array<SubClass> = []
	private(set) var sourcebook: Sourcebook = Sourcebook.PlayersHandbook

	// Only the setters are private, so we don't need getter functions

	// Setters
	func setName(nameIn: String) {name = nameIn}
	func setDescription(descriptionIn: String) {description = descriptionIn}
	func setHigherLevelDesc(higherLevelIn: String) {higherLevel = higherLevelIn}
	func setPage(pageIn: Int) {page = pageIn}
	func setRange(rangeIn: String) {range = rangeIn}
	func setComponents(componentsIn: Array<Bool>) {components = componentsIn}
	func setMaterial(materialIn: String) {material = materialIn}
	func setRitual(ritualIn: Bool) {ritual = ritualIn}
	func setDuration(durationIn: String) {duration = durationIn}
	func setConcentration(concentrationIn: Bool) {concentration = concentrationIn}
	func setCastingTime(castingTimeIn: String) {castingTime = castingTimeIn}
	func setLevel(levelIn: Int) {level = levelIn}
	func setSchool(schoolIn: School) {school = schoolIn}
	func setClasses(classesIn: Array<CasterClass>) {classes = classesIn}
	func setSubclasses(subclassesIn: Array<SubClass>) {subclasses = subclassesIn}
    func setSourcebook(sourcebookIn: Sourcebook) {sourcebook = sourcebookIn}

	// Constructors

	// Empty constructor just uses default values
	init() {}

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
	func usableByClass(cc: CasterClass) -> Bool {
		return classes.contains(cc)
	}

	func usableBySubclass(sub: SubClass) -> Bool {
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
