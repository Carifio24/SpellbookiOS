//
//  SIONUtils.swift
//  Spellbook
//
//  Created by Mac Pro on 8/29/22.
//  Copyright © 2022 Jonathan Carifio. All rights reserved.
//

import Foundation

func intFromSION(_ sion: SION, defaultValue: Int = 0) -> Int {
    return sion.int ?? (sion.double != nil ? Int(sion.double!) : defaultValue)
//    switch (sion.type) {
//    case SION.ContentType.int:
//        return sion.int!
//    case SION.ContentType.double:
//        return Int(sion.double!)
//    default:
//        return defaultValue
//    }
}

func intArrayToSION(_ intArray: [Int]) -> SION {
    var array: SION = []
    var i: Int = 0
    for name in intArray {
        array[i] = SION(name)
        i += 1
    }
    return array
}

// For converting an array of Strings to a SION array
func stringArrayToSION(_ stringArray: [String]) -> SION {
    var array: SION = []
    var i: Int = 0
    for name in stringArray {
        array[i] = SION(name)
        i += 1
    }
    return array
}

func arrayToSION<T>(collection: [T], serializer: (T) -> SION) -> SION {
    let arr = collection.map { serializer($0) }
    return SION(arr)
}

func nameDisplayableArrayToSION<T: NameDisplayable>(collection: [T]) -> SION {
    return arrayToSION(collection: collection, serializer: { t in return SION(t.displayName)})
}

func optionalArrayFromSION<T>(sion: SION, creator: (SION) -> T?, defaultArray: [T] = [], filter: ((T?) -> Bool)? = nil) -> [T?] {
    guard let sionArray = sion.array else { return defaultArray }
    let arr = sionArray.map{ creator($0) }
    if (filter != nil) {
        return arr.filter{ filter!($0) }
    } else {
        return arr
    }
    
}

func arrayFromSION<T>(sion: SION, creator: (SION) -> T?, defaultValue: T? = nil, defaultArray: [T] = [], filter: ((T?) -> Bool)? = nil) -> [T] {
    guard let sionArray = sion.array else { return defaultArray }
    let arr = sionArray.compactMap{ creator($0) ?? defaultValue }
    if (filter != nil) {
        return arr.filter{ filter!($0) }
    } else {
        return arr
    }
}
