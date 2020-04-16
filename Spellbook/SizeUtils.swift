//
//  SizeUtils.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

class SizeUtils {

    static let nativeScreenWidth = UIScreen.main.nativeBounds.size.width

    static func pickerFontSize() -> CGFloat {
        let nativeWidth = SizeUtils.nativeScreenWidth
        if nativeWidth <= 640 { return 17 }
        else if nativeWidth <= 750 { return 20 }
        else if nativeWidth <= 1080 { return 20 }
        else if nativeWidth <= 1125 { return 20 }
        return 23
    }
    
    static func unitTextGetter<U:Unit>(_ type: U.Type) -> (U) -> String {
        return (SizeUtils.nativeScreenWidth == 640) ? { return $0.abbreviation } : { $0.pluralName }
    }

}
