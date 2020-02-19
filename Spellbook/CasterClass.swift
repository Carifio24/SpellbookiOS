enum CasterClass: Int, NameDisplayable {
	case Bard=0, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
    
    internal static let displayNameMap: EnumMap<CasterClass,String> {
        switch(self) {
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

// So we can iterate over all values
extension CasterClass: CaseIterable {}
