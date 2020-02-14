enum School: Int, NameDisplayable {
	case Abjuration=0, Conjuration, Divination, Enchantment, Evocation, Illusion, Necromancy, Transmutation
    
    static let displayNameMap: [School:String] = [
        Abjuration : "Abjuration",
        Conjuration : "Conjuration",
        Divination : "Divination",
        Enchantment : "Enchantment",
        Evocation : "Evocation",
        Illusion : "Illusion",
        Necromancy : "Necromancy",
        Transmutation : "Transmutation"
    ]
}

// So we can iterate over all values
extension School: CaseIterable {}

// For sorting purposes
extension School: Comparable {}
