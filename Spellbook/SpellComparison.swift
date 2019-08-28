typealias Getter<T,R> = (T) -> R
typealias IntComparatorFunc<T> = (T,T) -> Int
typealias ComparatorFunc<T> = (T,T) -> Bool


func intToTruthValue(_ x: Int) -> Bool {
	return x > 0
}

func boolSign(_ b: Bool) -> Int {
    return b ? -1 : 1
}

// The default spell comparator (in our case, name)
func defaultSpellComparison(_ s1: Spell, _ s2: Spell) -> Bool {
    return s1.name < s2.name
}

// Returns -1 if t1 > t2, 0 if t1 == t2, 1 if t1 < t2
func triComp<T:Comparable>(_ t1: T, _ t2: T) -> Int {
    if (t1 > t2) {
        return -1
    }
    return NSNumber(value: t1 != t2).intValue
}

// Given a property P, this returns a function with inputs t1, t2 that evaluates triComp( P(t1), P(t2) )
func propertyTriComp<T,R>(_ getter: @escaping Getter<T,R>) -> IntComparatorFunc<T> where R:Comparable {
    return { (_ t1: T, _ t2: T) in
        return triComp(getter(t1), getter(t2))
    }
}

// Create the single-comparator function with a property
func singleComparator(propertyTC: @escaping IntComparatorFunc<Spell>, reverse: Bool) -> ComparatorFunc<Spell> {
    
    // The comparator function that we're returning
    let comparator = { (s1: Spell, s2: Spell) -> Bool in
        let r = boolSign(reverse) * propertyTC(s1, s2)
        if (r != 0) {
            return intToTruthValue(r)
        }
        return defaultSpellComparison(s1, s2)
    }
    
    return comparator
}

// Create the single-comparator function by SortField
func spellComparator(sortField: SortField, reverse: Bool) -> ComparatorFunc<Spell> {
    return singleComparator(propertyTC: sortField.comparator(), reverse: reverse)
}

// Create the single-comparator function by index
func spellComparator(index: Int, reverse: Bool) -> ComparatorFunc<Spell> {
    
    // Set the index to zero if it's too high
    let idx = (index >= SortField.count) ? 0 : index
    
    // Call the SortField version of the function
    return spellComparator(sortField: SortField(rawValue: idx)!, reverse: reverse)
}


// Create the double-comparator function with a property
func doubleComparator(propertyTC1: @escaping IntComparatorFunc<Spell>, propertyTC2: @escaping IntComparatorFunc<Spell>, reverse1: Bool, reverse2: Bool)  -> ComparatorFunc<Spell> {
    
    // The comparator function that we're returning
    let comparator = { (s1: Spell, s2: Spell) -> Bool in
        let r1 = boolSign(reverse1) * propertyTC1(s1, s2)
        if (r1 != 0) {
            return intToTruthValue(r1)
        }
        let r2 = boolSign(reverse2) * propertyTC2(s1, s2)
        if (r2 != 0) {
            return intToTruthValue(r2)
        }
        return defaultSpellComparison(s1, s2)
    }
    
    return comparator
}

// Create the double-comparator function by SortField
func spellComparator(sortField1: SortField, sortField2: SortField, reverse1: Bool, reverse2: Bool) -> ComparatorFunc<Spell> {
    return doubleComparator(propertyTC1: sortField1.comparator(), propertyTC2: sortField2.comparator(), reverse1: reverse1, reverse2: reverse2)
}


// Create the double-comparator function by index
func spellComparator(index1: Int, index2: Int, reverse1: Bool, reverse2: Bool) -> ComparatorFunc<Spell> {

    // Set each index to zero if it's too high
    let idx1 = (index1 >= SortField.count) ? 0 : index1
    let idx2 = (index2 >= SortField.count) ? 0 : index2
    
    // If the indices are the same, fall back to singleComparator
    if (idx1 == idx2) { return spellComparator(index: idx1, reverse: reverse1) }
    
    // Call the SortField version of the function
    return spellComparator(sortField1: SortField(rawValue: idx1)!, sortField2: SortField(rawValue: idx2)!, reverse1: reverse1, reverse2: reverse2)
}
