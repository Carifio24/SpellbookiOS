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
    
    @IBOutlet weak var searchButton: SearchButton!
    
    @IBOutlet weak var searchField: UITextField!
    
    static let searchIcon = UIImage(named: "search_icon.png")?.withRenderingMode(.alwaysOriginal)
    
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
    
    // The vertical heights of the search elements
    let searchButtonVertFraction = CGFloat(0.75)
    let searchFieldVertFraction = CGFloat(0.75)
    
    // The font for the pickers
    let pickerFont = UIFont.systemFont(ofSize: pickerFontSize())
    let searchFont = UIFont.systemFont(ofSize: CGFloat(20))
    
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
        
        // Set the search button image
        searchButton.setImage(PickerViewController.searchIcon, for: .normal)
        searchButton.imageView?.contentMode = .scaleAspectFit
        
        // Set the search field font
        searchField.font = searchFont
        
        // Set the element dimensions and positions
        setViewDimensions()
        
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
        
        // Determine the sizes of the elements
        let sort1Width = sort1Fraction * viewWidth
        let arrow1Width = arrow1Fraction * viewWidth
        let padding1Width = padding1Fraction * viewWidth
        let sort2Width = sort2Fraction * viewWidth
        let arrow2Width = arrow2Fraction * viewWidth
        let padding2Width = padding2Fraction * viewWidth
        let classWidth = classFraction * viewWidth
        let searchWidth = viewWidth - sort1Width - arrow1Width - sort2Width - arrow2Width - classWidth
        let searchFieldHeight = searchFieldVertFraction * viewHeight
        let searchButtonHeight = searchButtonVertFraction * viewHeight
        
        // Set the element dimensions
        var currentX = CGFloat(0)
        
        let sort1Frame = CGRect(x: currentX, y: 0, width: sort1Width, height: viewHeight)
        sortPicker1.frame = sort1Frame
        currentX += sort1Width
        
        let arrow1Frame = CGRect(x: currentX, y: 0, width: arrow1Width, height: viewHeight)
        sortArrow1.frame = arrow1Frame
        currentX += arrow1Width + padding1Width
        
        let sort2Frame = CGRect(x: currentX, y: 0, width: sort2Width, height: viewHeight)
        sortPicker2.frame = sort2Frame
        currentX += sort2Width
        
        let arrow2Frame = CGRect(x: currentX, y: 0, width: arrow2Width, height: viewHeight)
        sortArrow2.frame = arrow2Frame
        currentX += arrow2Width + padding2Width
        
        let classFrame = CGRect(x: currentX, y: 0, width: classWidth, height: viewHeight)
        classPicker.frame = classFrame
        currentX += classWidth
        
        let searchFrame = CGRect(x: currentX, y: (viewHeight - searchButtonHeight)/2, width: searchWidth, height: searchButtonHeight)
        searchButton.frame = searchFrame
        
        // The search field is initially hidden, but it takes up the same space as the three pickers
        // The search field is vertically centered within the view
        let searchFieldFrame = CGRect(x: 0, y: (viewHeight - searchFieldHeight)/2, width: sort1Width + sort2Width + classWidth, height: searchFieldHeight)
        searchField.frame = searchFieldFrame
        
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
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            label.text = sortPickerData[row]
        } else {
            label.text = classPickerData[row]
        }
        return label
    }
    
    func getSortValues() -> (Int,Int,Bool,Bool) {
        let index1 = sortPicker1.selectedRow(inComponent: 0)
        let index2 = sortPicker2.selectedRow(inComponent: 0)
        let reverse1 = sortArrow1.pointingUp()
        let reverse2 = sortArrow2.pointingUp()
        return ( index1, index2, reverse1, reverse2 )
    }
    
    // When an option is changed
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
            classPicker.selectRow(caster!.rawValue-1, inComponent: 0, animated: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
