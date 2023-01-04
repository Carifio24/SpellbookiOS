//
//  LevelTextFieldDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/6/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import Foundation
import ReSwift

class NumberFieldDelegate<ActionType: Action>: NSObject, UITextFieldDelegate {
    
    typealias ActionCreator = (Int) -> ActionType
    
    let maxCharacters: Int
    let actionCreator: ActionCreator
    
    init(maxCharacters: Int, actionCreator: @escaping ActionCreator) {
        self.maxCharacters = maxCharacters
        self.actionCreator = actionCreator
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
        store.dispatch(self.actionCreator(value))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
}
