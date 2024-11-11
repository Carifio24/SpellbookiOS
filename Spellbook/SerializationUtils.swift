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
    static let createdSpellsDirectoryName = "CreatedSpells"
    static let createdSpellsExtension = ".json"
    static let settingsFile = "Settings.json"
    
    static let documentsDirectory: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    static func getDirectory(directoryName: String) -> URL {
        let dir = documentsDirectory.appendingPathComponent(directoryName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dir.path) {
            do {
                try fileManager.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                print("\(e)")
            }
        }
        return dir
    }
    
    static let profilesDirectory = getDirectory(directoryName: profilesDirectoryName)
    static let createdSpellsDirectory = getDirectory(directoryName: createdSpellsDirectoryName)
    
    private static func nameFileLocation(name: String, ext: String, directory: URL) -> URL {
        let filename = name + ext
        return directory.appendingPathComponent(filename)
    }
    
    static func profileLocation(name: String) -> URL {
        return nameFileLocation(name: name, ext: profilesExtension, directory: profilesDirectory)
    }
    
    static func profileLocation(profile: CharacterProfile) -> URL {
        return profileLocation(name: profile.name)
    }
    
    static func createdSpellLocation(name: String) -> URL {
        return nameFileLocation(name: name, ext: createdSpellsExtension, directory: createdSpellsDirectory)
    }
    
    static func createdSpellLocation(spell: Spell) -> URL {
        return createdSpellLocation(name: spell.name)
    }
    
    static func saveCharacterProfile(profile: CharacterProfile) -> Bool {
        let location = profileLocation(profile: profile)
        return profile.save(filename: location)
    }
    
    static func loadItemFromJSON<T, E: Error>(name: String,
                                    locationGetter: (String) -> URL,
                                    itemCreator: (SION) throws -> T,
                                    errorCreator: () -> E
    ) throws -> T {
        let location = locationGetter(name)
        if var jsonText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&jsonText)
                let sion = SION(json: jsonText)
                let item = try itemCreator(sion)
                return item
            } catch _ {
                throw errorCreator()
            }
        } else {
            throw errorCreator()
        }
    }
    
    static func loadCharacterProfile(name: String) throws -> CharacterProfile {
        return try loadItemFromJSON(name: name,
                                locationGetter: self.profileLocation,
                                itemCreator: CharacterProfile.fromSION,
                                errorCreator: { return SpellbookError.BadCharacterProfileError })
    }
    
    private static func deleteFile(location: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: location)
            return true
        } catch let e {
            return false
        }
    }
    
    static func deleteCharacterProfile(profile: CharacterProfile) -> Bool {
        return deleteFile(location: profileLocation(profile: profile))
    }
    
    static func deleteCreatedSpell(spell: Spell) -> Bool {
        return deleteFile(location: createdSpellLocation(spell: spell))
    }
    
    static func loadSettings() -> Settings {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        if let settingsText = try? String(contentsOf: settingsLocation) {
            do {
                let settingsJSON = SION(json: settingsText)
                let settings = Settings(json: settingsJSON)
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
    
    static func itemNameList(directory: URL, ext: String) -> [String] {
        var names: [String] = []
        let fileManager = FileManager.default
        let extLen = ext.count
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        for path in enumerator.allObjects {
            let url = path as! URL
            let element = url.lastPathComponent
            if (element.hasSuffix(ext)) {
                var name = element
                name.removeLast(extLen)
                names.append(name)
            }
        }
        names.sort(by: { $0.lowercased() < $1.lowercased() })
        return names
    }
    
    static func characterNameList() -> [String] {
        return itemNameList(directory: profilesDirectory, ext: profilesExtension)
    }
    
    static func createdSpellNameList() -> [String] {
        return itemNameList(directory: createdSpellsDirectory, ext: createdSpellsExtension)
    }
}
