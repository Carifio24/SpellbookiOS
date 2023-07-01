//
//  SerializationUtils.swift
//  Spellbook
//
//  Created by Mac Pro on 2/26/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation

class SerializationUtils: NSObject {
    static let profilesDirectoryName = "Characters"
    static let profilesExtension = ".json"
    static let settingsFile = "Settings.json"
    
    static let documentsDirectory: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    static let profilesDirectory: URL = {
        let dir = documentsDirectory.appendingPathComponent(profilesDirectoryName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dir.path) {
            do {
                try fileManager.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                print("\(e)")
            }
        }
        return dir
    }()
    
    static func profileLocation(name: String) -> URL {
        let charFile = name + profilesExtension
        return profilesDirectory.appendingPathComponent(charFile)
    }
    
    static func profileLocation(profile: CharacterProfile) -> URL {
        return profileLocation(name: profile.name)
    }
    
    static func saveCharacterProfile(profile: CharacterProfile) -> Bool {
        let location = profileLocation(profile: profile)
        return profile.save(filename: location)
    }
    
    static func loadCharacterProfile(name: String) throws -> CharacterProfile {
        let location = profileLocation(name: name)
        if var profileText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&profileText)
                let profileSION = SION(json: profileText)
                let profile = try CharacterProfile.fromSION(profileSION)
                return profile
            } catch _ {
                throw SpellbookError.BadCharacterProfileError
            }
        } else {
            print("Error reading profile")
            let error = SpellbookError.BadCharacterProfileError
            print(error.description)
            throw error
        }
    }
    
    static func deleteCharacterProfile(profile: CharacterProfile) -> Bool {
        let location = profileLocation(profile: profile)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: location)
            return true
        } catch let e {
            print("\(e)")
            return false
        }
    }
    
    static func loadSettings() -> Settings {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        print(settingsLocation.path)
        if let settingsText = try? String(contentsOf: settingsLocation) {
            do {
                print(settingsText)
                let settingsJSON = SION(json: settingsText)
                let settings = Settings(json: settingsJSON)
                print(settings)
                return settings
            }
        } else {
            return Settings()
        }
    }
    
    static func saveSettings(_ settings: Settings) {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        settings.save(filename: settingsLocation)
    }
    
    static func characterNameList() -> [String] {
        var charNames: [String] = []
        let fileManager = FileManager.default
        let extLen = profilesExtension.count
        guard let enumerator = fileManager.enumerator(at: profilesDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        for path in enumerator.allObjects {
            let url = path as! URL
            let element = url.lastPathComponent
            if (element.hasSuffix(profilesExtension)) {
                var name = element
                name.removeLast(extLen)
                charNames.append(name)
            }
        }
        charNames.sort(by: { $0.lowercased() < $1.lowercased() })
        return charNames
    }
}
