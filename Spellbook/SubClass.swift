enum SubClass: Int, NameConstructible {
	case Land, Lore, Draconic, Hunter, Life, Devotion, Berserker, Evocation, Fiend, Thief, OpenHand
    
    internal static var displayNameMap = EnumMap<SubClass,String> { e in
        switch(e) {
        case .Land:
            return "Land"
        case .Lore:
            return "Lore"
        case .Draconic:
            return "Draconic"
        case .Hunter:
            return "Hunter"
        case .Life:
            return "Life"
        case .Devotion:
            return "Devotion"
        case .Berserker:
            return "Berserker"
        case .Evocation:
            return "Evocation"
        case .Fiend:
            return "Fiend"
        case .Thief:
            return "Thief"
        case .OpenHand:
            return "OpenHand"
        }
    }
}

// So we can iterate over all values
extension SubClass: CaseIterable {}
