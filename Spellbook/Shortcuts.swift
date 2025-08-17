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

struct ShortcutInfo: Codable {
    let type: String
    let title: String
}

func getOrderedShortcuts() -> [ShortcutInfo] {
    guard let shortcuts = UserDefaults.standard.array(forKey: SHORTCUT_STORAGE_KEY) as? [Data] else {
        return []
    }
    return shortcuts.compactMap { data in return try? PropertyListDecoder().decode(ShortcutInfo.self, from: data) }
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
    
    order.removeAll { $0.title == title }
    
    if order.count >= MAX_SHORTCUTS {
        order.removeFirst(order.count - MAX_SHORTCUTS + 1)
    }
    
    order.append(ShortcutInfo(type: type, title: title))
    
    let orderedInfo = order.compactMap { try? PropertyListEncoder().encode($0) }
    UserDefaults.standard.set(orderedInfo, forKey: SHORTCUT_STORAGE_KEY)
    
    
    let existingShortcuts = order.map { shortcutInfo in
        // Try to reuse the existing shortcut’s data if it exists in current list
        if let current = application.shortcutItems?.first(where: { $0.localizedTitle == shortcutInfo.title }) {
            return current
        }
        
        let info = userInfo as [String: NSSecureCoding]?
        
        if shortcutInfo.title == title {
            return UIApplicationShortcutItem(
                type: shortcutInfo.type,
                localizedTitle: title,
                localizedSubtitle: subtitle,
                icon: UIApplicationShortcutIcon(type: iconType),
                userInfo: info
            )
        }
        
        return UIApplicationShortcutItem(
            type: shortcutInfo.type,
            localizedTitle: shortcutInfo.title,
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
    let replacements = [
        "\\'" : "\'",
        "\\\\" : "\\",
    ]
    fixEscapeCharacters(&jsonString, replacements: replacements)
    
    // The "type" is what is displayed on the home screen context menu
    // so we make the type be the spell name, and store our own type info
    // in the userInfo
    let type = spell.name
    
    addShortcut(
        type: type,
        title: type,
        subtitle: nil,
        userInfo: [
            "spell": jsonString as NSString,
            "type": "SpellView"
        ]
    )
}
