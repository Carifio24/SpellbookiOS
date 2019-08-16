typealias Getter<T,R> = (T) -> R
typealias IntComparatorFunc<T> = (T,T) -> Int
typealias ComparatorFunc<T> = (T,T) -> Bool

let spellPropertyComparators: [(Spell,Spell)->Int] = [
    propertyTriComp({ (_ s: Spell) -> String in
        return s.name }),
    propertyTriComp({ (_ s: Spell) -> School in
        return s.school }),
    propertyTriComp({ (_ s:Spell) -> Int in
        return s.level }),
    propertyTriComp({ (_ s:Spell) -> Distance in
        return s.range }),
    propertyTriComp({ (_ s:Spell) -> Duration in
        return s.duration })
]

func intToTruthValue(_ x: Int) -> Bool {
	return x > 0
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
func singleComparator(propertyTC: @escaping IntComparatorFunc<Spell>) -> ComparatorFunc<Spell> {
    
    // The comparator function that we're returning
    let comparator = { (s1: Spell, s2: Spell) -> Bool in
        let r = propertyTC(s1, s2)
        if (r != 0) {
            return intToTruthValue(r)
        }
        return defaultSpellComparison(s1,s2)
    }
    
    return comparator
}


// Create the single-comparator function by index
func spellComparator(_ index: Int) -> ComparatorFunc<Spell> {
    
    // Set the index to zero if it's too high
    let idx = (index > spellPropertyComparators.count) ? 0 : index
    
    // Call the property version of the function
    //return singleComparator(property: spellComparisons(idx))
    
    return singleComparator(propertyTC: spellPropertyComparators[idx])
}


// Create the double-comparator function with a property
func doubleComparator(propertyTC1: @escaping IntComparatorFunc<Spell>, propertyTC2: @escaping IntComparatorFunc<Spell>)  -> ComparatorFunc<Spell> {
    
    // The comparator function that we're returning
    let comparator = { (s1: Spell, s2: Spell) -> Bool in
        let r1 = propertyTC1(s1, s2)
        if (r1 != 0) {
            return intToTruthValue(r1)
        }
        let r2 = propertyTC2(s1, s2)
        if (r2 != 0) {
            return intToTruthValue(r2)
        }
        return defaultSpellComparison(s1, s2)
    }
    
    return comparator
}


// Create the double-comparator function by index
func spellComparator(_ index1: Int, _ index2: Int) -> ComparatorFunc<Spell> {

    // Set each index to zero if it's too high
    let idx1 = (index1 > spellPropertyComparators.count) ? 0 : index1
    let idx2 = (index2 > spellPropertyComparators.count) ? 0 : index2
    
    // If the indices are the same, fall back to singleComparator
    if (idx1 == idx2) { return spellComparator(idx1) }
    
    // Get the properties
    let propertyTC1 = spellPropertyComparators[idx1]
    let propertyTC2 = spellPropertyComparators[idx2]
    
    // Call the property version of this function
    return doubleComparator(propertyTC1: propertyTC1, propertyTC2: propertyTC2)
}
