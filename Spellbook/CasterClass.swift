enum CasterClass: Int {
	case Bard, Cleric, Druid, Paladin, Ranger, Sorcerer, Warlock, Wizard
}

// So we can iterate over all values
extension CasterClass: CaseIterable {}