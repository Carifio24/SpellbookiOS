enum School: Int {
	case Abjuration=0, Conjuration, Divination, Enchantment, Evocation, Illusion, Necromancy, Transmutation
    
    static let nameMap: [School:String] = [
        Abjuration : "Abjuration",
        Conjuration : "Conjuration",
        Divination : "Divination",
        Enchantment : "Enchantment",
        Evocation : "Evocation",
        Illusion : "Illusion",
        Necromancy : "Necromancy",
        Transmutation : "Transmutation"
    ]
    
    static func fromName(_ s: String) -> School? {
        return getOneKey(dict: School.nameMap, value: s)
    }
}

// So we can iterate over all values
extension School: CaseIterable {}

// For sorting purposes
extension School: Comparable {}

extension School: NameDisplayable {
    
    var displayName: String {
        return School.nameMap[self]!
    }
    
}
