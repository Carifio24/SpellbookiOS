enum School: Int {
	case Abjuration, Conjuration, Divination, Enchantment, Evocation, Illusion, Necromancy, Transmutation
}

// So we can iterate over all values
extension School: CaseIterable {}