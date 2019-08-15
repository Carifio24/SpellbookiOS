func intToTruthValue(_ x: Int) -> Bool {
	return x > 0
}

// The default spell comparator (in our case, name)
func defaultSpellComparison(_ s1: Spell, _ s2: Spell) {
    return s1.name < s2.name
}

// Returns -1 if t1 > t2, 0 if t1 == t2, 1 if t1 < t2
func triComp<T:Comparable>(_ t1: T, _ t2: T) -> Int {
    if (t1 > t2) {
        return -1
    }
    return Int(t1 != t2)
}

// Given a property P, this returns a function with inputs t1, t2 that evaluates triComp( P(t1), P(t2) )
func propertyTriComp<T,R>(_ getter: (T) -> R) -> (T,T) -> Int {
    return { (_ t1: T, _ t2: T) in
        return triComp<R>(getter(t1), getter(t2))
    }
}

// Create the single-comparator function with a property
func singleComparator<T>(property: (Spell) -> T) -> ((Spell,Spell)->Bool) {
    
    // The tri-comparer
    let propTC = propertyTriComp(property)
    
    // The comparator function that we're returning
    let comparator = { (s1, s2) -> Bool in
        let r = propTC(s1, s2)
        if (r != 0) {
            return intToTruthValue(r)
        }
        return defaultSpellComparison(s1,s2)
    }
    
    return comparator
}


// Create the single-comparator function by index
func singleComparator(index: Int) -> ((Spell,Spell) -> Bool) {
    let comparisonProperties = [
        Spell::name, Spell::school, Spell::level, Spell::Range, Spell::Duration
    ]
    
    // Set the index to zero if it's too high
    if (index > comparators.count) {
        index = 0
    }
    
    // Call the property version of the function
    return singleComparator(property: comparisonProperties[index])
}


// Create the double-comparator function with a property
func doubleComparator<T1,T2>(property1: (Spell) -> T1, property2: (Spell) -> T2)  -> ((Spell,Spell)->Bool) {
    
    // The tri-comparers
    let prop1TC = propertyTriComp(property1)
    let prop2TC = propertyTriComp(property2)
    
    // The comparator function that we're returning
    let comparator = { (s1, s2) -> Bool in
        let r1 = prop1TC(s1, s2)
        if (r1 != 0) {
            return intToTruthValue(r1)
        }
        let r2 = prop2TC(s1, s2)
        if (r2 != 0) {
            return intToTruthValue(r2)
        }
        return defaultSpellComparison(s1, s2)
    }
    
    return comparator
}


// Create the double-comparator function by index
func doubleComparator(index:Int) -> ((Spell,Spell)->Bool) {

    // Set each index to zero if it's too high
    if (index1 > comparators.count) { index1 = 0 }
    if (index2 > comparators.count) { index2 = 0 }
    
    // If the indices are the same, fall back to singleComparator
    if (index1 == index2) { return singleComparator(index: index1) }
    
    // The comparison properties
    let comparisonProperties = [
        Spell::name, Spell::school, Spell::level, Spell::Range, Spell::Duration
    ]
    
    // Get the properties
    let prop1 = comparisonProperties[index1]
    let prop2 = comparisonProperties[index2]
    
    // Call the property version of this function
    return doubleComparator(property1: prop1, property2: prop2)
}
