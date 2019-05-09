enum SubClass: Int {
	case Land, Lore, Draconic, Hunter, Life, Devotion, Berserker, Evocation, Fiend, Thief, OpenHand
}

// So we can iterate over all values
extension SubClass: CaseIterable {}
