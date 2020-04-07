//
//  LevelTextFieldDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/6/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation

class LevelTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    typealias LevelBoundSetter = (CharacterProfile, Int) -> Void
    
    static let maxCharacters = 1
    let setter: LevelBoundSetter
    
    init(setter: @escaping LevelBoundSetter) {
        self.setter = setter
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLength = textField.text?.count ?? 0
        
        // Prevent a bug dealing with pasting/undo
        if range.length + range.location > currentLength {
            return false
        }
        
        let newLength = currentLength + string.count - range.length
        return newLength <= LevelTextFieldDelegate.maxCharacters
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let level = Int(textField.text ?? "") else { return }
        setter(Controllers.mainController.characterProfile, level)
    }
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            textView.selectAll(nil)
        }
    }
    
}
