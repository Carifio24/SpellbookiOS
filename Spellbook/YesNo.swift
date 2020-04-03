//
//  YesNo.swift
//  Spellbook
//
//  Created by Mac Pro on 4/1/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

enum YesNo: Int, NameConstructible {
    case Yes=0, No

    internal static var displayNameMap = EnumMap<YesNo, String> { e in
        switch (e) {
        case Yes:
            return "Yes"
        case No:
            return "No"
        }
    }
    
    var bool: Bool {
        switch (self) {
        case .Yes:
            return true
        case .No:
            return false
        }
    }
}
