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

class TextFieldChooserDelegate<T: Equatable>: NSObject, UITextFieldDelegate {
    
    typealias ItemProvider = () -> T
    typealias StringGetter = (T) -> String
    typealias StringConstructor = (String) -> T
    typealias ItemFilter = (T) -> Bool
    typealias Completion = (ActionSheetStringPicker?, T) -> ()
    
    let title: String
    let main = Controllers.mainController
    
    let itemProvider: ItemProvider
    let items: [T]
    let completion: Completion?
    let nameGetter: StringGetter
    let textSetter: StringGetter
    let nameConstructor: StringConstructor
    let itemFilter: ItemFilter?
    
    init(items: [T], title: String, itemProvider: @escaping ItemProvider, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, completion: Completion? = nil, itemFilter: ItemFilter? = nil) {
        self.items = items
        self.itemProvider = itemProvider
        self.completion = completion
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
        
        var itemsToUse = self.items
        if (self.itemFilter != nil) {
            itemsToUse = self.items.filter(self.itemFilter!)
        }
        let selectedIndex: Int = itemsToUse.firstIndex(of: selectedItem) ?? 0
        let pickerData = itemsToUse.map(self.nameGetter)
        
        // Create the action sheet picker
        let actionSheetPicker = ActionSheetStringPicker(title: title,
                 rows: pickerData,
                 initialSelection: selectedIndex,
                 doneBlock: {
                     picker, index, value in
                     let valueStr = value as! String
                     let item = self.nameConstructor(valueStr)
                     if let completion = self.completion {
                        completion(picker, item)
                     }
                     sender.text = self.textSetter(item)
                     sender.endEditing(true)
                     return
                     },
                     cancel: { picker in return },
                     origin: sender)
        actionSheetPicker?.show()
        
    }
}

class TextFieldChooserActionDelegate<A: Action, T:Equatable>: TextFieldChooserDelegate<T> {
    
    typealias ActionCreator = (T) -> A
    
    let actionCreator: ActionCreator?
    
    init(items: [T], title: String, itemProvider: @escaping ItemProvider, actionCreator: ActionCreator? = nil, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, itemFilter: ItemFilter? = nil) {
        self.actionCreator = actionCreator
        let completion: Completion = {
            picker, item in
            if let creator = actionCreator {
                store.dispatch(creator(item))
            }
        }
        super.init(items: items, title: title, itemProvider: itemProvider, nameGetter: nameGetter, textSetter: textSetter, nameConstructor: nameConstructor, completion: completion, itemFilter: itemFilter)
    }
    
}

class TextFieldIterableChooserDelegate<A:Action, T:CaseIterable & Equatable>: TextFieldChooserActionDelegate<A,T> {
    
    init(title: String, itemProvider: @escaping ItemProvider, actionCreator: ActionCreator? = nil, nameGetter: @escaping StringGetter, textSetter: @escaping StringGetter, nameConstructor: @escaping StringConstructor, itemFilter: ItemFilter? = nil) {
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
    
    init(itemProvider: @escaping ItemProvider, actionCreator: ActionCreator? = nil, title: String) {
        super.init(title: title,
                   itemProvider: itemProvider,
                   actionCreator: actionCreator,
                   nameGetter: { $0.displayName },
                   textSetter: { $0.displayName },
                   nameConstructor: { return N.fromName($0) })
    }
}

class UnitChooserDelegate<A:Action, U:Unit> : TextFieldIterableChooserDelegate<A,U> {
    init(itemProvider: @escaping ItemProvider, actionCreator: ActionCreator? = nil, title: String) {
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
