//
//  PickerViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sortPicker1: UIPickerView!
    
    @IBOutlet var sortArrow1: SortDirectionButton!
    
    @IBOutlet weak var sortPicker2: UIPickerView!
    
    @IBOutlet var sortArrow2: SortDirectionButton!
    
    @IBOutlet weak var classPicker: UIPickerView!
    
    @IBOutlet var clearButton: UIButton!
    
    @IBOutlet var searchButton: UIButton!
    
    @IBOutlet weak var searchField: UITextField!
    
    static let searchIcon = UIImage(named: "search_icon.png")?.withRenderingMode(.alwaysOriginal)
    static let xIcon = UIImage(named: "x_icon.png")?.withRenderingMode(.alwaysOriginal)
    
    var boss: ViewController?
    
    // The data for the sort pickers is the names of the sort fields
    // Create this via an IICE
    // This way, doesn't need modification if sort fields are added/removed/reordered
    let sortPickerData: [String] = {
        var data: [String] = []
        for i in 0...(SortField.count-1) {
            data.append(SortField(rawValue: i)!.name())
        }
        return data
    }()
    
    // The data for the class picker is "None" plus the names of the caster classes
    let classPickerData: [String] = ["None"] + {
        var data: [String] = []
        for i in 0...(CasterClass.count-1) {
            data.append(CasterClass(rawValue: i)!.name())
        }
        return data
    }()
    
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
    
    // Whether to use default values
    var sort1Default = false
    var sort2Default = false
    var classDefault = false
    
    // The default values
    let sort1DefaultText = "Sort 1"
    let sort2DefaultText = "Sort 2"
    let classDefaultText = "Class"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates and data sources for the pickers
        sortPicker1.delegate = self as UIPickerViewDelegate
        sortPicker2.delegate = self as UIPickerViewDelegate
        classPicker.delegate = self as UIPickerViewDelegate
        sortPicker1.dataSource = self as UIPickerViewDataSource
        sortPicker2.dataSource = self as UIPickerViewDataSource
        classPicker.dataSource = self as UIPickerViewDataSource
        
        // Set the callback function for the text field
        searchField.addTarget(self, action: #selector(searchFieldDidChange(textField:)), for: .editingChanged)
        
        // Set the callback function for the search button
        searchButton.addTarget(self, action: #selector(searchButtonClicked(sender:)), for: .touchUpInside)
        
        // Set the callback functions for the sort arrows
        sortArrow1.addTarget(self, action: #selector(sortArrowClicked(sender:)), for: .touchUpInside)
        sortArrow2.addTarget(self, action: #selector(sortArrowClicked(sender:)), for: .touchUpInside)
        
        // Set the callback function for the clear button
        clearButton.addTarget(self, action: #selector(clearButtonClicked(sender:)), for: .touchUpInside)
        
        // Set the search button image
        searchButton.setImage(PickerViewController.searchIcon, for: .normal)
        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.imageView?.clipsToBounds = true
        
        // Set the clear button image
        clearButton.setImage(PickerViewController.xIcon, for: .normal)
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.imageView?.clipsToBounds = true
        
        // Set the search field font
        searchField.font = searchFont
        
        // Set up the picker listener to remove default text state if needed
        
        
        // Set the element dimensions and positions
        //setViewDimensions()
        //print("searchButton's height is: \(searchButton.frame.height)")
        //print("clearButton's height is: \(clearButton.frame.height)")
        
        // For testing only
        //sortPicker1.backgroundColor = UIColor.blue
        //sortArrow1.backgroundColor = UIColor.orange
        //sortPicker2.backgroundColor = UIColor.red
        //sortArrow2.backgroundColor = UIColor.green
        //classPicker.backgroundColor = UIColor.yellow
        //searchButton.backgroundColor = UIColor.purple
        //let pickerFS = pickerFontSize()
        //print("The picker font size is: \(pickerFS)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boss = self.parent as? ViewController
    }
    
    func setViewDimensions() {

        // Get the view dimensions
        let viewRect = self.view.bounds
        let viewWidth = viewRect.size.width
        let viewHeight = viewRect.size.height
        
        // Padding amounts
        let searchButtonLeftPadding = CGFloat(5)
        
        // Factors used in calculating heights
        let pickerHeightFactor = CGFloat(1)
        let pickerHeight = pickerHeightFactor * viewHeight
        let searchButtonFactor = CGFloat(0.6)
        let searchFieldFactor = CGFloat(0.7)
        let clearButtonFactor = CGFloat(0.5)
        
        // Detrmine the sizes of the elements
        let sort1Width = sort1Fraction * viewWidth
        let arrow1Width = arrow1Fraction * viewWidth
        let padding1Width = padding1Fraction * viewWidth
        let sort2Width = sort2Fraction * viewWidth
        let arrow2Width = arrow2Fraction * viewWidth
        let padding2Width = padding2Fraction * viewWidth
        let classWidth = classFraction * viewWidth
        let searchButtonWidth = searchButtonFactor * (viewWidth - sort1Width - arrow1Width - sort2Width - arrow2Width - classWidth)
        let searchButtonHeight = searchButtonWidth
        let searchFieldHeight = searchFieldFactor * viewHeight
        let clearButtonHeight = clearButtonFactor * viewHeight
        let clearButtonWidth = clearButtonHeight
        let searchFieldWidth = viewWidth - searchButtonWidth - clearButtonWidth - searchButtonLeftPadding - padding1Width - padding2Width
        
        //print("searchFieldWidth is: \(searchFieldWidth)")
        //print("clearButtonWidth is: \(clearButtonWidth)")
        //print("searchButtonWidth is: \(searchButtonWidth)")
        //print("viewWidth is: \(viewWidth)")
        
        //sortPicker1.backgroundColor = UIColor.yellow
        //searchButton.backgroundColor = UIColor.green
        //sortArrow1.backgroundColor = UIColor.orange
        //clearButton.backgroundColor = UIColor.purple
        
        // Set the element dimensions
        var currentX = CGFloat(0)
        let pickerY = (viewHeight - pickerHeight) / 2
        
        let sort1Frame = CGRect(x: currentX, y: pickerY, width: sort1Width, height: pickerHeight)
        sortPicker1.frame = sort1Frame
        currentX += sort1Width
        
        let arrow1Frame = CGRect(x: currentX, y: pickerY, width: arrow1Width, height: pickerHeight)
        sortArrow1.frame = arrow1Frame
        currentX += arrow1Width + padding1Width
        
        let sort2Frame = CGRect(x: currentX, y: pickerY, width: sort2Width, height: pickerHeight)
        sortPicker2.frame = sort2Frame
        currentX += sort2Width
        
        let arrow2Frame = CGRect(x: currentX, y: pickerY, width: arrow2Width, height: pickerHeight)
        sortArrow2.frame = arrow2Frame
        currentX += arrow2Width + padding2Width
        
        let classFrame = CGRect(x: currentX, y: pickerY, width: classWidth, height: pickerHeight)
        classPicker.frame = classFrame
        currentX += classWidth + searchButtonLeftPadding
        
        let searchFieldY = (viewHeight - searchFieldHeight) / 2
        let searchButtonY = 1.2 * (viewHeight - searchButtonHeight) / 2
        let clearButtonY = (viewHeight - clearButtonHeight) / 2
        //print("searchButton x is: \(currentX)")
        let searchButtonFrame = CGRect(x: currentX, y: searchButtonY, width: searchButtonWidth, height: searchButtonHeight)
        searchButton.frame = searchButtonFrame
        
        // The clear button and the search field are initially hidden, but take up the same space as the three pickers and the two search arrows
        // The search field is vertically centered within the view
        let searchFieldFrame = CGRect(x: 0, y: searchFieldY, width: searchFieldWidth, height: searchFieldHeight)
        searchField.frame = searchFieldFrame
        
        let clearFrame = CGRect(x: searchFieldWidth, y: clearButtonY, width: clearButtonWidth, height: clearButtonHeight)
        clearButton.frame = clearFrame
        
        //print("searchHeight is: \(searchButtonHeight)")
        //print("searchFieldHeight is: \(searchFieldHeight)")
        //print("searchButton's height is: \(searchButton.frame.height)")
        //print("clearButton's height is: \(clearButton.frame.height)")
        
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            return sortPickerData.count
        } else {
            return classPickerData.count
        }
    }
    
    // Title for each row
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = pickerFont
        
        // For entries other than the first
        if (row != 0) {
            let sort = (pickerView.tag <= 1)
            label.text = sort ? sortPickerData[row] : classPickerData[row]
        
        // For the first entry
        } else {
            switch (pickerView.tag) {
            case 0:
                label.text = sort1Default ? sort1DefaultText : sortPickerData[row]
                break
            case 1:
                label.text = sort2Default ? sort2DefaultText : sortPickerData[row]
                break
            case 2:
                label.text = classDefault ? classDefaultText : classPickerData[row]
                break
            default: // Shouldn't ever get here
                print("Picker view tag error")
            }
        }
        return label
    }
    
    // Get the current state of the widgets that affect sorting
    // Namely, the two sort picker and the direction arrows
    func getSortValues() -> (Int,Int,Bool,Bool) {
        let index1 = sortPicker1.selectedRow(inComponent: 0)
        let index2 = sortPicker2.selectedRow(inComponent: 0)
        let reverse1 = sortArrow1.pointingUp()
        let reverse2 = sortArrow2.pointingUp()
        return ( index1, index2, reverse1, reverse2 )
    }
    
    // When the selected onption on one of the pickers is changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // If one of the sort field pickers is changed
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            
            // Get the indices of the currently selected entry in each picker
            var index1 = 0
            var index2 = 0
            if pickerView.tag == 0 {
                index1 = row
                index2 = sortPicker2.selectedRow(inComponent: 0)
            } else {
                index1 = sortPicker1.selectedRow(inComponent: 0)
                index2 = row
            }
            
            // Get the direction of the sort arrows
            let reverse1 = sortArrow1.pointingUp()
            let reverse2 = sortArrow2.pointingUp()
            
            if (index2 == 0) || (index1 == 0) {
                boss!.tableController!.singleSort(index: index1, reverse: reverse1)
            } else {
                boss!.tableController!.doubleSort(index1: index1, index2: index2, reverse1: reverse1, reverse2: reverse2)
            }
            
            //Update the character profile
            boss!.characterProfile.setFirstSortField(SortField(rawValue: index1)!)
            boss!.characterProfile.setSecondSortField(SortField(rawValue: index2)!)
            
        // If the class filter picker is changed
        } else {
            let caster: CasterClass? = (row != 0) ? CasterClass(rawValue: row - 1) : nil
            boss!.characterProfile.setFilterClass(caster)
            boss!.tableController!.filter()
        }
        
        // Either way, we want to save the character profile
        boss!.saveCharacterProfile()
        
    }
        
    // What happens when the search button is clicked
    @objc func searchButtonClicked(sender: UIButton) {
        sortPicker1.isHidden = !sortPicker1.isHidden
        sortArrow1.isHidden = !sortArrow1.isHidden
        sortPicker2.isHidden = !sortPicker2.isHidden
        sortArrow2.isHidden = !sortArrow2.isHidden
        classPicker.isHidden = !classPicker.isHidden
        searchField.isHidden = !searchField.isHidden
        clearButton.isHidden = !clearButton.isHidden
    }
    
    @objc func searchFieldDidChange(textField: UITextField) {
        boss!.tableController!.filter()
    }
    
    // What happens when one of the sort arrows is clicked
    @objc func sortArrowClicked(sender: SortDirectionButton) {
        sender.onPress()
        let ( index1, index2, reverse1, reverse2 ) = getSortValues()
        //print("The sort values are \(index1), \(index2), \(reverse1), \(reverse2)")
        boss!.tableController!.doubleSort(index1: index1, index2: index2, reverse1: reverse1, reverse2: reverse2)
        boss!.characterProfile.setFirstSortReverse(reverse1)
        boss!.characterProfile.setSecondSortReverse(reverse2)
        boss!.saveCharacterProfile()
    }
    
    @objc func clearButtonClicked(sender: UIButton) {
        searchField.text = ""
        searchFieldDidChange(textField: searchField)
    }
    
    func setSortStatus(sort1: SortField, sort2: SortField, reverse1: Bool, reverse2: Bool) {
        // Set the pickers
        sortPicker1.selectRow(sort1.rawValue, inComponent: 0, animated: false)
        sortPicker2.selectRow(sort2.rawValue, inComponent: 0, animated: false)
        
        // Set the arrow directions
        if (reverse1) {
            sortArrow1.setUp()
        } else {
            sortArrow1.setDown()
        }
        
        if (reverse2) {
            sortArrow2.setUp()
        } else {
            sortArrow2.setDown()
        }
    }
    
    func setFilterStatus(caster: CasterClass?) {
        if caster == nil {
            classPicker.selectRow(0, inComponent: 0, animated: false)
        } else {
            classPicker.selectRow(caster!.rawValue + 1, inComponent: 0, animated: false)
        }
    }

}
