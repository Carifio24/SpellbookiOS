//
//  VersionInfo.swift
//  Spellbook
//
//  Created by Mac Pro on 5/13/21.
//  Copyright © 2021 Jonathan Carifio. All rights reserved.
//

import Foundation
import SWXMLHash

class VersionInfo {
    
    static let version = Version(major: 2, minor: 13, patch: 0)
    static let previousVersion = Version(major: 2, minor: 12, patch: 0)
    
    static let currentVersionKey = "v_" + version.string(separator: "_")
    
    static let (updateTitle, updateText): (String, String) = {
        let infoFile = Bundle.main.url(forResource: "UpdateInfo", withExtension: "xml")!
        let data = try! String(contentsOf: infoFile)
        let xmlDoc = SWXMLHash.parse(data)
        do {
            let updateSection = try xmlDoc["root"]["section"].withAttribute("name", VersionInfo.currentVersionKey)
            let updateTitleText = try updateSection["item"].withAttribute("name", "title").element!.text
            let updateDescriptionText = try updateSection["item"].withAttribute("name", "description").element!.text
            
            return (updateTitleText, updateDescriptionText)
        } catch let e {
            print(e.localizedDescription)
            return ("", "")
        }
    }()
    
}
