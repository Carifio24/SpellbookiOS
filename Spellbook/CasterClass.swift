enum CasterClass: Int {
	case Bard=0, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
    
    private static let nameMap: [CasterClass:String] = [
        Bard : "Bard",
        Cleric : "Cleric",
        Druid : "Druid",
        Paladin : "Paladin",
        Ranger : "Ranger",
        Sorcerer : "Sorcerer",
        Warlock : "Warlock",
        Wizard : "Wizard"
    ]
    
    func name() -> String {
        return CasterClass.nameMap[self]!
    }
    
    static func fromName(_ s: String) -> CasterClass? {
        return getOneKey(dict: CasterClass.nameMap, value: s)
    }
    
    static let count = CasterClass.allCases.count
}

// So we can iterate over all values
extension CasterClass: CaseIterable {}
