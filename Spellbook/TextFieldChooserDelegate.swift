//
//  TextFieldChooserDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/5/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class TextFieldChooserDelegate<T:CaseIterable & Equatable>: NSObject, UITextFieldDelegate {
    
    typealias ProfileSetter = (CharacterProfile, T) -> Void
    typealias ProfileGetter = (CharacterProfile) -> T
    typealias StringGetter = (T) -> String
    typealias StringConstructor = (String) -> T
    
    let title: String
    let main = Controllers.mainController
    
    let pickerData: [String]
    let profileSetter: ProfileSetter
    let profileGetter: ProfileGetter
    let nameGetter: StringGetter
    let textSetter: StringGetter
    let nameConstructor: StringConstructor
    
    init(profileGetter: @escaping ProfileGetter, profileSetter: @escaping ProfileSetter, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, title: String) {
        self.profileSetter = profileSetter
        self.profileGetter = profileGetter
        self.nameGetter = nameGetter
        self.textSetter = textSetter
        self.nameConstructor = nameConstructor
        self.title = title
        pickerData = T.allCases.map({ nameGetter($0) })
    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        openPickerWindow(sender: textField)
        return false
    }
    
    func openPickerWindow(sender: UITextField) {
        
        // Get the index of the selected option
        let selectedItem = profileGetter(self.main.characterProfile)
        let selectedIndex = T.allCases.firstIndex(of: selectedItem) as! Int
        
        // Create the action sheet picker
        let actionSheetPicker = ActionSheetStringPicker(title: title,
                 rows: pickerData,
                 initialSelection: selectedIndex,
                 doneBlock: {
                     picker, index, value in
                     let valueStr = value as! String
                     let item = self.nameConstructor(valueStr)
                     self.profileSetter(self.main.characterProfile, item)
                     self.main.saveCharacterProfile()
                     self.main.sort()
                     sender.text = self.textSetter(item)
                     sender.endEditing(true)
                     return
                     },
                     cancel: { picker in return },
                     origin: sender)
        actionSheetPicker?.show()
        
    }
    
}

// Specific cases for types that implement NameConstructible and Unit protocols
// These didn't seem worth their own files, since all that needs to be overwritten is the constructor
// because the name getter and constructor come directly from the protocol


class NameConstructibleChooserDelegate<T:NameConstructible>: TextFieldChooserDelegate<T> {
    
    init(getter: @escaping ProfileGetter, setter: @escaping ProfileSetter, title: String) {
        super.init(profileGetter: getter, profileSetter: setter,
                   nameGetter: { $0.displayName },
                   textSetter: { $0.displayName },
                   nameConstructor: { return T.fromName($0) },
                   title: title)
    }
}

class UnitChooserDelegate<U:Unit> : TextFieldChooserDelegate<U> {
    init(getter: @escaping ProfileGetter, setter: @escaping ProfileSetter, title: String) {
        super.init(profileGetter: getter, profileSetter: setter,
                   nameGetter: { $0.pluralName },
                   textSetter: SizeUtils.unitTextGetter(U.self),
               nameConstructor: {
                do {
                    return try U.fromString($0)
                } catch {
                    return U.defaultUnit
                }
            },
               title: title)
    }
}
