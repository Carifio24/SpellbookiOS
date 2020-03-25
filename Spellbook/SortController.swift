//
//  SortController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class SortController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var firstLevelLabel: UILabel!
    @IBOutlet weak var firstLevelChoice: UITextField!
    @IBOutlet weak var firstLevelArrow: SortDirectionButton!
    @IBAction func firstLevelChoiceEntered(_ sender: Any) {
        openFirstLevelPicker(sender: sender)
    }
    @IBAction func firstLevelChoiceClicked(_ sender: Any) {
        print("First level choice clicked")
        openSecondLevelPicker(sender: sender)
    }
    
    @IBOutlet weak var secondLevelLabel: UILabel!
    @IBOutlet weak var secondLevelChoice: UITextField!
    @IBOutlet weak var secondLevelArrow: SortDirectionButton!
    @IBAction func secondLevelChoiceEntered(_ sender: Any) {
        openPickerWindow(sender: sender as! UITextField, level: 2)
    }
    
    static let searchIcon = UIImage(named: "search_icon.png")?.withRenderingMode(.alwaysOriginal)
    static let xIcon = UIImage(named: "x_icon.png")?.withRenderingMode(.alwaysOriginal)
    
    private let main = Controllers.mainController
    
    // Create the pickers
    private let firstLevelPicker = UIPickerView()
    private let secondLevelPicker = UIPickerView()
    
    // The data for the sort pickers is the names of the sort fields
    static let sortPickerData = SortField.allNames()
    
    
    // The fractional widths of the sort/filter elements
    // The rest will be for the search button
    let sort1Fraction = CGFloat(0.22)
    let arrow1Fraction = CGFloat(0.07)
    let padding1Fraction = CGFloat(0.01)
    let sort2Fraction = CGFloat(0.22)
    let arrow2Fraction = CGFloat(0.07)
    let padding2Fraction = CGFloat(0.01)
    let classFraction = CGFloat(0.25)
    
    // The font for the pickers
    let pickerFont = UIFont.systemFont(ofSize: pickerFontSize())
    let searchFont = UIFont.systemFont(ofSize: CGFloat(20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text field delegates
        firstLevelChoice.delegate = self
        secondLevelChoice.delegate = self
    
        // Set the callback functions for the sort arrows
        firstLevelArrow.addTarget(self, action: #selector(sortArrowClicked(sender:)), for: .touchUpInside)
        secondLevelArrow.addTarget(self, action: #selector(sortArrowClicked(sender:)), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SortController.sortPickerData.count
    }
    
    // Title for each row
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = pickerFont
        label.text = SortController.sortPickerData[row]
        return label
    }
    
    // Get the current state of the widgets that affect sorting
    // Namely, the two sort picker and the direction arrows
    func getSortValues() -> (Int,Int,Bool,Bool) {
        let index1 = firstLevelPicker.selectedRow(inComponent: 0)
        let index2 = secondLevelPicker.selectedRow(inComponent: 0)
        let reverse1 = firstLevelArrow.pointingUp()
        let reverse2 = secondLevelArrow.pointingUp()
        return ( index1, index2, reverse1, reverse2 )
    }
    
    // When the selected onption on one of the pickers is changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        // Get the indices of the currently selected entry in each picker
        var index1 = 0
        var index2 = 0
        if pickerView.tag == 0 {
            index1 = row
            index2 = secondLevelPicker.selectedRow(inComponent: 0)
        } else {
            index1 = firstLevelPicker.selectedRow(inComponent: 0)
            index2 = row
        }
        
        // Get the direction of the sort arrows
        let reverse1 = firstLevelArrow.pointingUp()
        let reverse2 = secondLevelArrow.pointingUp()
        
        if (index2 == 0) || (index1 == 0) {
            main.tableController!.singleSort(sortField: SortField.Name, reverse: reverse1)
        } else {
            main.tableController!.doubleSort(sortField1: SortField.Name, sortField2: SortField.Name, reverse1: reverse1, reverse2: reverse2)
        }
        
        //Update the character profile
        main.characterProfile.setFirstSortField(SortField(rawValue: index1)!)
        main.characterProfile.setSecondSortField(SortField(rawValue: index2)!)
            
    
        // Either way, we want to save the character profile
        main.saveCharacterProfile()
        
    }
    
    // What happens when one of the sort arrows is clicked
    @objc func sortArrowClicked(sender: SortDirectionButton) {
        sender.onPress()
        let ( index1, index2, reverse1, reverse2 ) = getSortValues()
        //print("The sort values are \(index1), \(index2), \(reverse1), \(reverse2)")
        main.tableController!.doubleSort(sortField1: SortField.Name, sortField2: SortField.Name, reverse1: reverse1, reverse2: reverse2)
        main.characterProfile.setFirstSortReverse(reverse1)
        main.characterProfile.setSecondSortReverse(reverse2)
        main.saveCharacterProfile()
    }
    
    
    func setSortStatus(sort1: SortField, sort2: SortField, reverse1: Bool, reverse2: Bool) {
        // Set the text for the choice labels
        firstLevelChoice.text = main.characterProfile.getFirstSortField().displayName
        secondLevelChoice.text = main.characterProfile.getSecondSortField().displayName
        
        // Set the arrow directions
        if (reverse1) {
            firstLevelArrow.setUp()
        } else {
            firstLevelArrow.setDown()
        }
        
        if (reverse2) {
            secondLevelArrow.setUp()
        } else {
            secondLevelArrow.setDown()
        }
    }
    
//    func openPickerWindow(sender: UILabel, level: Int) {
//
//        // Create the view
//        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
//        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
//        let picker = (level == 1) ? firstLevelPicker : secondLevelPicker
//        picker.tintColor = tintColor
//        picker.center.x = inputView.center.x
//        let doneButton = UIButton(frame: CGRect(x: 100/2, y: 0, width: 100, height: 50))
//        doneButton.setTitle("Done", for: UIControl.State.normal)
//        doneButton.setTitle("Done", for: UIControl.State.highlighted)
//        doneButton.setTitleColor(tintColor, for: UIControl.State.normal)
//        doneButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
//        inputView.addSubview(doneButton) // add Button to UIView
//        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControl.Event.TouchUpInside) // set button click event
//
//        let cancelButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 3*(100/2), y: 0, width: 100, height: 50))
//        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
//        cancelButton.setTitle("Cancel", for: UIControl.State.highlighted)
//        cancelButton.setTitleColor(tintColor, for: UIControl.State.normal)
//        cancelButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
//        inputView.addSubview(cancelButton) // add Button to UIView
//        cancelButton.addTarget(self, action: "cancelPicker:", forControlEvents: UIControl.Event.TouchUpInside) // set button click event
//        sender.inputView = inputView
//    }
    
    func sortLabelClicked(sender: Any, level: Int) {
        openPickerWindow(sender: sender, level: level)
    }
    
    // Selector functions for each of the two labels
    @objc func openFirstLevelPicker(sender: Any) { sortLabelClicked(sender: sender, level: 1) }
    @objc func openSecondLevelPicker(sender: Any) { sortLabelClicked(sender: sender, level: 2) }
    
    // The function to open the picker window
    func openPickerWindow(sender: Any, level: Int) {
        let titleNumber = (level == 2) ? "Second" : "First"
        let title = titleNumber + " level sorting"
        let actionSheetPicker = ActionSheetStringPicker.show(withTitle: title, rows: SortController.sortPickerData, initialSelection: 0,
            doneBlock: {
                picker, index, value in
                let valueStr = value as! String
                let sf = SortField.fromName(valueStr)
                self.main.characterProfile.setFirstSortField(sf)
                self.main.saveCharacterProfile()
                
            },
            cancel: { picker in return },
            origin: sender)
        actionSheetPicker?.show()
    }
    
    private func textFieldShouldReturn(_ textField: Any) -> Bool {
        self.view.endEditing(true)
        return true
    }

    private func textFieldShouldBeginEditing(_ textField: Any) -> Bool {
        return true
    }
    
    @objc func iWasTouched(sender: Any) {
        print("I was touched: \(sender)")
    }


}
