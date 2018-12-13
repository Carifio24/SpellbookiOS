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
    let labelFraction = CGFloat(0.08)
    // The table will take up the rest of the space
    
    // Extreme padding amounts
    let maxHorizPadding = CGFloat(5)
    let maxTopPadding = CGFloat(5)
    let maxBotPadding = CGFloat(3)
    let minHorizPadding = CGFloat(1)
    let minTopPadding = CGFloat(1)
    let minBotPadding = CGFloat(1)
    
    // Padding amounts
    let leftPaddingFraction = CGFloat(0.01)
    let rightPaddingFraction = CGFloat(0.01)
    let topPaddingFraction = CGFloat(0.01)
    let bottomPaddingFraction = CGFloat(0.01)
    
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
        
        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * screenHeight, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * screenHeight, maxBotPadding), minBotPadding)
        
        // Account for padding
        let usableHeight = screenHeight - topPadding - bottomPadding
        let usableWidth = screenWidth - leftPadding - rightPadding
        
        // Set the dimensions for the child containers
        let sortHeight = max(min(sortFraction * usableHeight, 100), 70)
        let labelHeight = min(labelFraction * usableHeight, 70)
        let tableHeight = usableHeight - sortHeight - labelHeight
        
        print("Padding:")
        print(leftPadding)
        print(rightPadding)
        print(topPadding)
        print(bottomPadding)
        
        // Set the relevant dimensions to the elements
        // First the PickerViewController
        pickerView.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: sortHeight)
        pickerController!.view!.frame = CGRect(x: leftPadding, y: topPadding, width: usableWidth, height: sortHeight)
        
        // Then the LabelViewController
        // We need to set the labelController's view to have y = 0 (so that it's at the top of the view)
        labelView.frame = CGRect(x: leftPadding, y: sortHeight, width: usableWidth, height: labelHeight)
        labelController!.view!.frame = CGRect(x: leftPadding, y: 0, width: usableWidth, height: labelHeight)
        
        // Finally, the SpellTableViewController
        // Note that we don't need to adjust the tableController's view differently - the TableViewController seems to be able to handle this part itself
        let tableFrame = CGRect(x: leftPadding, y: sortHeight + labelHeight, width: usableWidth, height: tableHeight)
        tableView.frame = tableFrame
        tableController!.view!.frame = tableFrame
        
        pickerController?.setViewDimensions()
        labelController?.setViewDimensions()
        tableController?.setTableDimensions(leftPadding: leftPadding, bottomPadding: bottomPadding, usableHeight: usableHeight, usableWidth: usableWidth)
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
