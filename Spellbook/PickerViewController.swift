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
    
    @IBOutlet weak var sortPicker2: UIPickerView!
    
    @IBOutlet weak var classPicker: UIPickerView!
    
    @IBOutlet weak var searchButton: SearchButton!
    
    var boss: ViewController?
    var sortPickerData: [String] = ["Name", "School", "Level"]
    var classPickerData: [String] = ["None"] + Spellbook.casterNames
    
    let sort1Fraction = CGFloat(0.33)
    let sort2Fraction = CGFloat(0.33)
    // The rest will be for the class picker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates and data sources for the pickers
        sortPicker1.delegate = self as UIPickerViewDelegate
        sortPicker2.delegate = self as UIPickerViewDelegate
        classPicker.delegate = self as UIPickerViewDelegate
        sortPicker1.dataSource = self as UIPickerViewDataSource
        sortPicker2.dataSource = self as UIPickerViewDataSource
        classPicker.dataSource = self as UIPickerViewDataSource
        
        // Set the picker dimensions and positions
        setViewDimensions()
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
        let sort2Width = sort2Fraction * viewWidth
        let classWidth = viewWidth - sort1Width - sort2Width
        
        // Set the element dimensions
        let sort1Frame = CGRect(x: 0, y: 0, width: sort1Width, height: viewHeight)
        sortPicker1.frame = sort1Frame
        
        let sort2Frame = CGRect(x: sort1Width, y: 0, width: sort2Width, height: viewHeight)
        sortPicker2.frame = sort2Frame
        
        let classFrame = CGRect(x: sort1Width + sort2Width, y: 0, width: classWidth, height: viewHeight)
        classPicker.frame = classFrame
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            return sortPickerData[row]
        } else {
            return classPickerData[row]
        }
    }
    
    // When an option is changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // If one of the sort field pickers is changed
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            var index1 = 0
            var index2 = 0
            if pickerView.tag == 0 {
                index1 = row
                index2 = sortPicker2.selectedRow(inComponent: 0)
            } else {
                index1 = sortPicker1.selectedRow(inComponent: 0)
                index2 = row
            }
            print(index1)
            print(index2)
            
            if (index2 == 0) || (index1 == 0) {
                boss!.tableController!.singleSort(index: index1)
            } else {
                boss!.tableController!.doubleSort(index1: index1, index2: index2)
            }
            
        // If the class filter picker is changed
        } else {
            boss!.tableController!.filter()
        }
        
        // What happens when the search button is clicked
        func searchButtonClicked(sender: UIButton) {
            
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
