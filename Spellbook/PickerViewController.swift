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
    
    var boss: ViewController?
    var sortPickerData: [String] = ["Name", "Level", "School"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates and data sources for the pickers
        sortPicker1.delegate = self as? UIPickerViewDelegate
        sortPicker2.delegate = self as? UIPickerViewDelegate
        classPicker.delegate = self as? UIPickerViewDelegate
        sortPicker1.dataSource = self as? UIPickerViewDataSource
        sortPicker2.dataSource = self as? UIPickerViewDataSource
        classPicker.dataSource = self as? UIPickerViewDataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boss = self.parent as? ViewController
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
            return Spellbook.casterNames.count
        }
    }
    
    // Title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            print(sortPickerData[row])
            return sortPickerData[row]
        } else {
            print(Spellbook.casterNames[row])
            return Spellbook.casterNames[row]
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
