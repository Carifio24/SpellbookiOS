enum CasterClass: Int, NameConstructible {
	case Artificer=0, Bard, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
    
    internal static var displayNameMap = EnumMap<CasterClass,String> { e in
        switch(e) {
        case .Artificer:
            return "Artificer"
        case .Bard:
            return "Bard"
        case .Cleric:
            return "Cleric"
        case .Druid:
            return "Druid"
        case .Paladin:
            return "Paladin"
        case .Ranger:
            return "Ranger"
        case .Sorcerer:
            return "Sorcerer"
        case .Warlock:
            return "Warlock"
        case .Wizard:
            return "Wizard"
        }
    }

    static let count = CasterClass.allCases.count
}
