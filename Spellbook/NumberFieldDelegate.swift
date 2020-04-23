//
//  LevelTextFieldDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/6/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

class NumberFieldDelegate: NSObject, UITextFieldDelegate {
    
    typealias IntSetter = (CharacterProfile, Int) -> Void
    
    let maxCharacters: Int
    let setter: IntSetter
    
    init(maxCharacters: Int, setter: @escaping IntSetter) {
        self.maxCharacters = maxCharacters
        self.setter = setter
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLength = textField.text?.count ?? 0
        
        // Prevent a bug dealing with pasting/undo
        if range.length + range.location > currentLength {
            return false
        }
        
        let newLength = currentLength + string.count - range.length
        return newLength <= maxCharacters
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let value = Int(textField.text ?? "") else { return }
        setter(Controllers.mainController.characterProfile, value)
        Controllers.mainController.saveCharacterProfile()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
}
