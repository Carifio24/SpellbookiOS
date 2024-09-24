//
//  BidirectionalMAp.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 9/22/24.
//  Copyright © 2024 Jonathan Carifio. All rights reserved.
//

import Foundation

class BidirectionalMap<K: Hashable, V: Hashable> {
    private var valueByKey: [K:V] = [:]
    private var keyByValue: [V:K] = [:]
    
    func put(_ s: K, _ t: V) {
        valueByKey[s] = t
        keyByValue[t] = s
    }
    
    func getValue(_ key: K) -> V? {
        return valueByKey[key]
    }
    
    func getKey(_ value: V) -> K? {
        return keyByValue[value]
    }
    
    func removeByKey(_ key: K) {
        let toRemove = valueByKey.removeValue(forKey: key)
        guard let remove = toRemove else { return }
        keyByValue.removeValue(forKey: remove)
    }
    
    func removeByValue(_ value: V) {
        let toRemove = keyByValue.removeValue(forKey: value)
        guard let remove = toRemove else { return }
        valueByKey.removeValue(forKey: remove)
    }
    
    func removeIfMatch(_ key: K, _ value: V) {
        valueByKey.removeValue(forKey: key)
        keyByValue.removeValue(forKey: value)
    }
    
    func linkExists(_ key: K, _ value: V) -> Bool {
        return (getValue(key) == value) || (getKey(value) == key)
    }
}
