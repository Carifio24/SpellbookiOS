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
    
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    // Child controllers
    var pickerController: PickerViewController?
    var labelController: LabelViewController?
    var tableController: SpellTableViewController?
    var spellWindowController: SpellWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier == "sortSegue" {
            pickerController = (segue.destination as! PickerViewController)
        }
        if segue.identifier == "labelSegue" {
            labelController = (segue.destination as! LabelViewController)
        }
        if segue.identifier == "tableSegue" {
            tableController = (segue.destination as! SpellTableViewController)
        }
    }
    
}
