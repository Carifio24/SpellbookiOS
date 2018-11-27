//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    
    
    // Spellbook
    var spellbook = Spellbook()
    
    // Child controllers
    var pickerController: PickerViewController?
    var labelController: LabelViewController?
    var tableController: SpellTableViewController?
    
    let spellsFile = Bundle.main.url(forResource: "Spells", withExtension: "json")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Picker settings
        //self.sortPicker1.dataSource = self as? UIPickerViewDataSource
        //self.sortPicker1.delegate = self as? UIPickerViewDelegate
        //self.sortPicker2.dataSource = self as? UIPickerViewDataSource
        //self.sortPicker2.delegate = self as? UIPickerViewDelegate
        //self.classPicker.dataSource = self as? UIPickerViewDataSource
        //self.classPicker.delegate = self as? UIPickerViewDelegate
        
        // Load the spell data and parse the spells
        let spellData = try! String(contentsOf: spellsFile!)
        spellbook = Spellbook(jsonStr: spellData)
        print(spellbook.spells.count)
        
        // Populate the list of spells
        spellTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sortSegue" {
            pickerController = segue.destination as! PickerViewController
        }
        if segue.identifier == "labelSegue" {
            labelController = segue.destination as! LabelViewController
        }
        if segue.identifier == "tableSegue" {
            tableController = segue.destination as! SpellTableViewController
        }
    }
    
}
