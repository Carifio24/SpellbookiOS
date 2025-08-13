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
    
    order.removeAll { $0 == type }
    
    if order.count >= MAX_SHORTCUTS {
        order.removeFirst(order.count - MAX_SHORTCUTS + 1)
    }
    
    order.append(type)
   
    UserDefaults.standard.set(order, forKey: SHORTCUT_STORAGE_KEY)
    
    let existingShortcuts = order.map { shortcutType in
        // Try to reuse the existing shortcut’s data if it exists in current list
        if let current = application.shortcutItems?.first(where: { $0.type == shortcutType }),
           shortcutType != type {
            return current
        }
        
        if shortcutType == type {
            return UIApplicationShortcutItem(
                type: type,
                localizedTitle: title,
                localizedSubtitle: subtitle,
                icon: UIApplicationShortcutIcon(type: iconType),
                userInfo: userInfo as [String: NSSecureCoding]?
            )
        }
        
        return UIApplicationShortcutItem(
            type: shortcutType,
            localizedTitle: shortcutType,
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .compose),
            userInfo: nil
        )
    }
            
    application.shortcutItems = existingShortcuts
}

func addSpellShortcut(spell: Spell) {
    addShortcut(
        type: "spellView",
        title: spell.name,
        subtitle: nil,
        userInfo: [
            "spell": spell
        ]
    )
}
