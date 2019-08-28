//
//  SizeUtils.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/17/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import Foundation

func pickerFontSize() -> CGFloat {
    let nativeWidth = UIScreen.main.nativeBounds.size.width
    if nativeWidth <= 640 { return 17 }
    else if nativeWidth <= 750 { return 20 }
    else if nativeWidth <= 1080 { return 20 }
    else if nativeWidth <= 1125 { return 20 }
    return 23
}
