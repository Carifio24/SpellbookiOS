//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    var sortPickerData: [String] = ["Name", "Level", "School"]
    
    @IBOutlet weak var sortLabel1: UILabel!
    
    @IBOutlet weak var sortLabel2: UILabel!
    
    @IBOutlet weak var classLabel: UILabel!
    
    @IBOutlet weak var sortPicker1: UIPickerView!
    
    @IBOutlet weak var sortPicker2: UIPickerView!
    
    @IBOutlet weak var classPicker: UIPickerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sortPicker1.dataSource = self
        self.sortPicker1.delegate = self
        self.sortPicker2.dataSource = self
        sortPicker2.delegate = self as? UIPickerViewDelegate
        classPicker.dataSource = self as? UIPickerViewDataSource
        classPicker.delegate = self as? UIPickerViewDelegate
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            return sortPickerData.count
        } else {
            return Spellbook.casterNames.count
        }
    }
    
    // Title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView.tag == 0) || (pickerView.tag == 1) {
            return sortPickerData[row]
        } else {
            return Spellbook.casterNames[row]
        }
    }
    

}

