func intToTruthValue(x: Int) -> Bool {
	return x > 0
}

func compareName(s1: Spell, s2: Spell) -> Int {
	if s2.name > s1.name {
		return 1
	} else if s2.name == s1.name {
		return 0
	} else {
		return -1
	}
}

func compareSchool(s1: Spell, s2: Spell) -> Int {
	return s1.school.rawValue - s2.school.rawValue
}

func compareLevel(s1: Spell, s2: Spell) -> Int {
	return s1.level - s2.level
}

func singleCompare(s1: Spell, s2: Spell, index: Int) -> Int {
	if index == 0 {
		return compareName(s1: s1, s2: s2)
	} else if index == 1 {
		return compareSchool(s1: s1, s2: s2)
	} else {
		return compareLevel(s1: s1, s2: s2)
	}
}

func compareOne(s1: Spell, s2: Spell, index: Int) -> Bool {
	var r = singleCompare(s1: s1, s2: s2, index: index)
	if r != 0 {
		return intToTruthValue(x: r)
	} else {
		return intToTruthValue(x: singleCompare(s1: s1, s2: s2, index: 0)) // If the primary comparator is the same, sort by name
	}
}

func compareTwo(s1: Spell, s2: Spell, index1: Int, index2: Int) -> Bool {
	var r = singleCompare(s1: s1, s2: s2, index: index1)
	if r != 0 {
		return intToTruthValue(x: r)
	}
	
	r = singleCompare(s1: s1, s2: s2, index: index2)	
	if r != 0 {
		return intToTruthValue(x: r)
	} else {
		return intToTruthValue(x: singleCompare(s1: s1, s2: s2, index: 0)) // If the other two fields are the same, sort by name
	}
}