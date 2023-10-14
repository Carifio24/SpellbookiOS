//
//  TextFieldChooserDelegate.swift
//  Spellbook
//
//  Created by Mac Pro on 4/5/20.
//  Copyright © 2020 Jonathan Carifio. All rights reserved.
//

import ReSwift
import UIKit
import CoreActionSheetPicker

class TextFieldChooserDelegate<A: Action, T:Equatable>: NSObject, UITextFieldDelegate {
    
    typealias ActionCreator = (T) -> A
    typealias ItemProvider = () -> T
    typealias StringGetter = (T) -> String
    typealias StringConstructor = (String) -> T
    typealias ItemFilter = (T) -> Bool
    
    let title: String
    let main = Controllers.mainController
    
    let itemProvider: ItemProvider
    let items: [T]
    let actionCreator: ActionCreator
    let nameGetter: StringGetter
    let textSetter: StringGetter
    let nameConstructor: StringConstructor
    let itemFilter: ItemFilter?
    
    init(items: [T], title: String, itemProvider: @escaping ItemProvider, actionCreator: @escaping ActionCreator, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, itemFilter: ItemFilter? = nil) {
        self.items = items
        self.itemProvider = itemProvider
        self.actionCreator = actionCreator
        self.nameGetter = nameGetter
        self.textSetter = textSetter
        self.nameConstructor = nameConstructor
        self.itemFilter = itemFilter
        self.title = title
    }


    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        openPickerWindow(sender: textField)
        return false
    }

    func openPickerWindow(sender: UITextField) {
        
        // Get the index of the selected option
        let selectedItem = self.itemProvider()
        let selectedIndex: Int = items.firstIndex(of: selectedItem) ?? 0
        
        var itemsToUse = self.items
        if (self.itemFilter != nil) {
            itemsToUse = self.items.filter(self.itemFilter!)
        }
        let pickerData = itemsToUse.map(self.nameGetter)
        
        
        // Create the action sheet picker
        let actionSheetPicker = ActionSheetStringPicker(title: title,
                 rows: pickerData,
                 initialSelection: selectedIndex,
                 doneBlock: {
                     picker, index, value in
                     let valueStr = value as! String
                     let item = self.nameConstructor(valueStr)
                     store.dispatch(self.actionCreator(item))
                     sender.text = self.textSetter(item)
                     sender.endEditing(true)
                     return
                     },
                     cancel: { picker in return },
                     origin: sender)
        actionSheetPicker?.show()
        
    }
    
}

class TextFieldIterableChooserDelegate<A:Action, T:CaseIterable & Equatable>: TextFieldChooserDelegate<A,T> {
    
    init(title: String, itemProvider: @escaping ItemProvider, actionCreator: @escaping ActionCreator, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, itemFilter: ItemFilter? = nil) {
        let items = T.allCases.map({ $0 })
        super.init(items: items,
                   title: title,
                   itemProvider: itemProvider,
                   actionCreator: actionCreator,
                   nameGetter: nameGetter,
                   textSetter: textSetter,
                   nameConstructor: nameConstructor,
                   itemFilter: itemFilter)
    }
    
}

// Specific cases for types that implement NameConstructible and Unit protocols
// These didn't seem worth their own files, since all that needs to be overwritten is the constructor
// because the name getter and constructor come directly from the protocol


class NameConstructibleChooserDelegate<A:Action, N:NameConstructible>: TextFieldIterableChooserDelegate<A,N> {
    
    init(itemProvider: @escaping ItemProvider, actionCreator: @escaping ActionCreator, title: String) {
        super.init(title: title,
                   itemProvider: itemProvider,
                   actionCreator: actionCreator,
                   nameGetter: { $0.displayName },
                   textSetter: { $0.displayName },
                   nameConstructor: { return N.fromName($0) })
    }
}

class UnitChooserDelegate<A:Action, U:Unit> : TextFieldIterableChooserDelegate<A,U> {
    init(itemProvider: @escaping ItemProvider, actionCreator: @escaping ActionCreator, title: String) {
        super.init(title: title,
                   itemProvider: itemProvider,
                   actionCreator: actionCreator,
                   nameGetter: { $0.pluralName },
                   textSetter: SizeUtils.unitTextGetter(U.self),
               nameConstructor: {
                do {
                    return try U.fromString($0)
                } catch {
                    return U.defaultUnit
                }
            })
    }
}
