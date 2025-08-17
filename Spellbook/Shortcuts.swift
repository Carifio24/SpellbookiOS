//
//  Shortcuts.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 8/13/25.
//  Copyright © 2025 Jonathan Carifio. All rights reserved.
//

import UIKit

fileprivate let MAX_SHORTCUTS = 4
fileprivate let SHORTCUT_STORAGE_KEY = "dynamicShortcutOrder"

func getOrderedShortcuts() -> [String] {
    return UserDefaults.standard.stringArray(forKey: SHORTCUT_STORAGE_KEY) ?? []
}

func addShortcut(
    type: String,
    title: String,
    subtitle: String? = nil,
    iconType: UIApplicationShortcutIcon.IconType = .favorite,
    userInfo: [String: NSSecureCoding]? = nil
) {
    let application = UIApplication.shared
    var order = getOrderedShortcuts()
    
    order.removeAll { $0 == title }
    
    if order.count >= MAX_SHORTCUTS {
        order.removeFirst(order.count - MAX_SHORTCUTS + 1)
    }
    
    order.append(type)
   
    UserDefaults.standard.set(order, forKey: SHORTCUT_STORAGE_KEY)
    
    
    let existingShortcuts = order.map { shortcutTitle in
        // Try to reuse the existing shortcut’s data if it exists in current list
        if let current = application.shortcutItems?.first(where: { $0.localizedTitle == shortcutTitle }) {
            return current
        }
        
        let info = userInfo as [String: NSSecureCoding]?
        
        if shortcutTitle == title {
            return UIApplicationShortcutItem(
                type: type,
                localizedTitle: title,
                localizedSubtitle: subtitle,
                icon: UIApplicationShortcutIcon(type: iconType),
                userInfo: info
            )
        }
        
        return UIApplicationShortcutItem(
            type: type,
            localizedTitle: shortcutTitle,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: iconType),
            userInfo: info
        )
    }
            
    application.shortcutItems = existingShortcuts
}

func addSpellShortcut(spell: Spell) {
    let codec = SpellCodec()
    let sion = codec.toSION(spell)
    
    var jsonString = String(sion.json)
    fixEscapeCharacters(&jsonString)
    let type = "Open \(spell.name)"
    
    addShortcut(
        type: type,
        title: spell.name,
        subtitle: nil,
        userInfo: [
            "spell": jsonString as NSString
        ]
    )
}
