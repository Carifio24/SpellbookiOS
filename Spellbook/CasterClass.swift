enum CasterClass: Int {
	case Bard=0, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
}

// So we can iterate over all values
extension CasterClass: CaseIterable {}
