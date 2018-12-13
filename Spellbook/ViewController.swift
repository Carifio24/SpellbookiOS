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
    
    // The UIViews that hold the child controllers
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var tableView: UIView!
    
    // Dimensions
    let sortFraction = CGFloat(0.1)
    let labelFraction = CGFloat(0.1)
    // The table will take up the rest of the space
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setContainerDimensions()
    }
    
    func setContainerDimensions() {
        print("MAIN VIEW DIMENSIONS")
        // Get the screen dimensions
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        // Set the dimensions for the child containers
        let sortHeight = max(min(sortFraction * screenHeight, 100), 70)
        let labelHeight = min(labelFraction * screenHeight, 70)
        let tableHeight = screenHeight - sortHeight - labelHeight
        print("ScreenHeight:")
        print(screenHeight)
        print("sortHeight:")
        print(sortHeight)
        print("labelHeight:")
        print(labelHeight)
        print("tableHeight:")
        print(tableHeight)
        
        // Set the relevant dimensions to the elements
        // First the PickerViewController
        let pickerFrame = CGRect(x: 0, y: 0, width: screenWidth, height: sortHeight)
        pickerView.frame = pickerFrame
        pickerController!.view!.frame = pickerFrame
        
        // Then the LabelViewController
        // We need to set the labelController's view to have y = 0 (so that it's at the top of the view)
        labelView.frame = CGRect(x: 0, y: sortHeight, width: screenWidth, height: labelHeight)
        labelController!.view!.frame = CGRect(x: 0, y: 0, width: screenWidth, height: labelHeight)
        
        // Finally, the SpellTableViewController
        // Note that we don't need to adjust the tableController's view differently - the TableViewController seems to be able to handle this part itself
        let tableFrame = CGRect(x: 0, y: sortHeight + labelHeight, width: screenWidth, height: tableHeight)
        tableView.frame = tableFrame
        tableController!.view!.frame = tableFrame
        
        pickerController?.setViewDimensions()
        labelController?.setViewDimensions()
        tableController?.setTableDimensions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
