//
//  PickerViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    
    @IBOutlet weak var sortPicker1: UIPickerView!
    
    @IBOutlet weak var sortPicker2: UIPickerView!
    
    @IBOutlet weak var classPicker: UIPickerView!
    
    var boss: ViewController?
    var sortPickerData: [String] = ["Name", "Level", "School"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
