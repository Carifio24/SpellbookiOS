//
//  SpellTableViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

// Type aliases for making closures
typealias SpellStatusSetter = (Spell, Bool) -> Void
typealias SpellStatusGetter = (Spell) -> Bool

import UIKit

class SpellTableViewController: UITableViewController {
    
    var main: ViewController?
    
    var firstAppear: Bool = true
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    var spells: [(Spell, Bool)] = []
    var spellArray: [Spell] = []
    var paddedSpells: [(Spell, Bool)] = []
    var paddedArray: [Spell] = []
    let nBlankPadding = 4
    
    // Vertical position in main view
    var mainY = CGFloat(0)

    
    @IBOutlet var spellTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the list of spells
        //spellTable.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        
        //print("profilesDirectory is: \(profilesDirectory)")
        
        // Long press gesture recognizer
        let lpgr = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        //lpgr.delegate = self
        tableView.addGestureRecognizer(lpgr)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the main view
        main = self.parent as? ViewController
        
        // If this is the view's first appearance (i.e. when the app is opening), we initialize spellArray
        if firstAppear {
            spellArray = []
            for spell in spellbook.spells {
                spells.append((spell,true))
                spellArray.append(spell)
            }
            updatePaddedSpells()
            tableView.reloadData()
            firstAppear = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setTableDimensions(leftPadding: CGFloat, bottomPadding: CGFloat, usableHeight: CGFloat, usableWidth: CGFloat, tableTopPadding: CGFloat) {
        
        // Set the table dimensions
        let tableFrame = CGRect(x: leftPadding, y: tableTopPadding, width: usableWidth, height: usableHeight - bottomPadding)
        tableView.frame = tableFrame
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paddedArray.count
    }
    
    // Function for adding SpellDataCell to table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SpellDataCell
        let spell = paddedArray[indexPath.row]
        cell.spell = spell
        cell.selectionStyle = .none
        if spell.name != "" {
            cell.nameLabel.text = spell.name
            cell.schoolLabel.text = Spellbook.schoolNames[spell.school.rawValue]
            cell.levelLabel.text = String(spell.level)
            cell.nameLabel.textColor = UIColor.black
            cell.schoolLabel.textColor = UIColor.black
            cell.levelLabel.textColor = UIColor.black
        } else {
            cell.nameLabel.text = "XXX"
            cell.schoolLabel.text = "XXX"
            cell.levelLabel.text = "XXX"
            cell.nameLabel.textColor = UIColor.clear
            cell.schoolLabel.textColor = UIColor.clear
            cell.levelLabel.textColor = UIColor.clear
            cell.isUserInteractionEnabled = false
            //cell.selectionStyle = .none
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Function to get the spells to currently display
    func updateSpellArray() {
        spellArray = []
        for tpl in spells {
            if tpl.1 {
                spellArray.append(tpl.0)
            }
        }
    }
    
    
    // Function to sort the data by one field
    func singleSort(index: Int, reverse: Bool) {
        
        // Do the sorting
        let cmp = spellComparator(index: index, reverse: reverse)
        spells.sort { return cmp($0.0, $1.0) }
        
        // Get the array
        updateSpellArray()
        updatePaddedSpells()

        // Repopulate the table
        //print("Reloading")
        //print(index)
        tableView.reloadData()
        //print("Done reloading")
    }
    
    // Function to sort the data by two fields
    func doubleSort(index1: Int, index2: Int, reverse1: Bool, reverse2: Bool) {
        
        // Do the sorting
        let cmp = spellComparator(index1: index1, index2: index2, reverse1: reverse1, reverse2: reverse2)
        spells.sort { return cmp($0.0, $1.0) }
        
        // Get the array
        updateSpellArray()
        updatePaddedSpells()
        
        // Repopulate the table
        //print("Reloading")
        //print(index1)
        //print(index2)
        tableView.reloadData()
        //print("Done reloading")
    }
    
    // Function to entirely unfilter - i.e., display everything
    func unfilter() {
        for i in 0...spells.count-1 {
            spells[i] = (spells[i].0, true)
        }
        updateSpellArray()
        updatePaddedSpells()
    }
    
    // Determine whether or not a single row should be filtered
    func filterItem(isClass: Bool, isText: Bool, s: Spell, cc: CasterClass, text: String, profile: CharacterProfile) -> Bool {
        let spname = s.name.lowercased()
        var toHide = (isClass && !s.usableByClass(cc))
        toHide = toHide || (profile.knownSelected() && !profile.isKnown(s))
        toHide = toHide || (profile.preparedSelected() && !profile.isPrepared(s))
        toHide = toHide || (profile.favoritesSelected() && !profile.isFavorite(s))
        toHide = toHide || (isText && !spname.starts(with: text))
        toHide = toHide || (!(profile.getSourcebookFilter(s.sourcebook)))
        return toHide
    }
    
    // Function to filter the table data
    func filter() {
        
        // During initial setup
        if (spells.count == 0) { return }
        
        // First, we filter the data
        let classIndex = main?.pickerController?.classPicker.selectedRow(inComponent: 0)
        let isClass = (classIndex != 0) && (classIndex != nil)
        var cc: CasterClass = CasterClass(rawValue: 0)!
        let isText = !(main?.pickerController?.searchField.text?.isEmpty ?? true)
        let searchText = isText ? (main?.pickerController?.searchField.text)! : ""
        if isClass {
            cc = CasterClass(rawValue: classIndex!-1)!
        }
        let cp = main?.characterProfile
        for i in 0...spells.count-1 {
            let filter = filterItem(isClass: isClass, isText: isText, s: spells[i].0, cc: cc, text: searchText, profile: cp!)
            spells[i] = (spells[i].0, !filter)
        }
            
        // Get the new spell array
        updateSpellArray()
        updatePaddedSpells()
            
        // Repopulate the table
        tableView.reloadData()
    }
    
    // Set what happens when a cell is selected
    // For us, that's creating a segue to a view with the spell info
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(boss!)
        //print(boss!.spellWindowController!)
        //boss?.spellWindowController!.spell = spellArray[indexPath.row]
        //boss?.performSegue(withIdentifier: spellWindowSegueIdentifier, sender: nil)
        //print("spells.count is \(spellArray.count)")
        //print("indexPath.row is \(indexPath.row)")
        if indexPath.row >= spellArray.count { return }
        let storyboard = self.storyboard
        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        self.present(spellWindowController, animated: true, completion: nil)
        print("Selected row for spell: \(paddedArray[indexPath.row].name)")
        spellWindowController.spellIndex = indexPath.row
        spellWindowController.spell = paddedArray[indexPath.row]
    }
    
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: tableView)
        //let pAbs = gestureRecognizer.location(in: main?.view)
        //print("Long press at \(pAbs.x), \(pAbs.y)")
        let indexPath = tableView.indexPathForRow(at: p)
        if indexPath == nil {
            return
        } else if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            if indexPath!.row >= spellArray.count { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "statusPopup") as! StatusPopupController
            
            let popupHeight = CGFloat(52)
            let popupWidth = CGFloat(166)
            controller.width = popupWidth
            controller.height = popupHeight
            controller.main = main!
            let cell = tableView.cellForRow(at: indexPath!) as! SpellDataCell
            let positionX = CGFloat(0)
            let positionY = cell.frame.maxY
            let position = CGPoint(x: positionX, y: positionY)
            let absPosition = main!.view.convert(position, from: self.tableView)
            let popupPosition = PopupViewController.PopupPosition.topLeft(absPosition)
            controller.spell = paddedArray[indexPath!.row]
            let popupVC = PopupViewController(contentController: controller, position: popupPosition, popupWidth: popupWidth, popupHeight: popupHeight)
            popupVC.backgroundAlpha = 0
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    func updatePaddedSpells() {
        paddedSpells = spells
        for _ in 0...nBlankPadding-1 {
            paddedSpells.append((Spell(),true))
        }
        paddedArray = spellArray
        for _ in 0...nBlankPadding-1 {
            paddedArray.append(Spell())
        }
    }
    
    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
