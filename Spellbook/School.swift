enum School: Int, Comparable, NameDisplayable {
	case Abjuration=0, Conjuration, Divination, Enchantment, Evocation, Illusion, Necromancy, Transmutation
    
    static let displayNameMap: EnumMap<School,String> {
        switch (self) {
        case .Abjuration: 
            return "Abjuration"
        case .Conjuration: 
            return "Conjuration"
        case .Divination:
            return "Divination"
        case .Enchantment:
            return "Enchantment"
        case .Evocation:
            return "Evocation"
        case .Illusion:
            return "Illusion"
        case .Necromancy:
            return  "Necromancy"
        case .Transmutation:
            return "Transmutation"
        }
    }
}

// So we can iterate over all values
extension School: CaseIterable {}
