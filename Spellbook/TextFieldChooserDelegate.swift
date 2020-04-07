//
//  TextFieldChooserDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/5/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class TextFieldChooserDelegate<T:NameConstructible>: NSObject, UITextFieldDelegate {
    
    typealias ProfileSetter = (CharacterProfile, T) -> Void
    typealias ProfileGetter = (CharacterProfile) -> T
    
    let pickerData = T.allCases.map({ $0.displayName })
    let title = String(describing: T.self)
    let main = Controllers.mainController
    let setter: ProfileSetter
    let getter: ProfileGetter
    
    init(getter: @escaping ProfileGetter, setter: @escaping ProfileSetter) {
        self.setter = setter
        self.getter = getter
    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        openPickerWindow(sender: textField)
        return false
    }
    
    func openPickerWindow(sender: UITextField) {
        
        // Get the index of the selected option
        let selectedItem = getter(self.main.characterProfile)
        let selectedIndex = T.allCases.firstIndex(of: selectedItem) as! Int
        
        // Create the action sheet picker
        let actionSheetPicker = ActionSheetStringPicker(title: title,
                 rows: pickerData,
                 initialSelection: selectedIndex,
                 doneBlock: {
                     picker, index, value in
                     let valueStr = value as! String
                     let item = T.fromName(valueStr)
                     self.setter(self.main.characterProfile, item)
                     self.main.saveCharacterProfile()
                     sender.text = item.displayName
                     sender.endEditing(true)
                     return
                     },
                     cancel: { picker in return },
                     origin: sender)
        actionSheetPicker?.show()
        
    }
    
    
    
}
