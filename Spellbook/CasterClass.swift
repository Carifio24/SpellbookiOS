enum CasterClass: Int, NameDisplayable {
	case Bard=0, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
    
    internal static let displayNameMap: EnumMap<CasterClass,String> = {
        switch(self) {
        case .Bard:
            return "Bard"
        case .Cleric:
            return "Cleric"
        }
        
        Bard : "Bard",
        Cleric : "Cleric",
        Druid : "Druid",
        Paladin : "Paladin",
        Ranger : "Ranger",
        Sorcerer : "Sorcerer",
        Warlock : "Warlock",
        Wizard : "Wizard"
    }
    
    static let count = CasterClass.allCases.count
}

// So we can iterate over all values
extension CasterClass: CaseIterable {}
