//
//  Version.swift
//  Spellbook
//
//  Created by Mac Pro on 5/8/21.
//  Copyright © 2021 Jonathan Carifio. All rights reserved.
//

import Foundation

class Version: Comparable {
    
    private static let pattern = try! NSRegularExpression(pattern: "^(\\d+)\\.(\\d+)\\.(\\d+)$")
    
    let major: Int
    let minor: Int
    let patch: Int
    
    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    func string(separator: String = ".") -> String {
        return "\(major)\(separator)\(minor)\(separator)\(patch)"
    }
    
    static func fromString(_ str: String) -> Version? {
        let nsrange = NSRange(str.startIndex..<str.endIndex,
                              in: str)
        var version: Version?
        pattern.enumerateMatches(in: str, options: .anchored, range: nsrange)  { (match, _, stop) in
        guard let match = match else { return }
            if match.numberOfRanges == 4,
                let majorRange = Swift.Range(match.range(at: 1), in: str),
                let minorRange = Swift.Range(match.range(at: 2), in: str),
                let patchRange = Swift.Range(match.range(at: 3), in: str),
                let major = Int(str[majorRange]),
                let minor = Int(str[minorRange]),
                let patch = Int(str[patchRange])
            {
                version = Version(major: major, minor: minor, patch: patch)
            } else {
                version = nil
            }
        }
        return version
    }
    
    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if (lhs.major != rhs.major) {
            return lhs.major < rhs.major
        }
        if (lhs.minor != rhs.minor) {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
    
    
    
}
