//
//  SpellTableViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/27/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class SpellTableViewController: UITableViewController {
    
    var boss: ViewController?
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    var spells: [(Spell, Bool)] = []
    var spellArray: [Spell] = []
    
    @IBOutlet weak var spellTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the list of spells
        //spellTable.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View did appear")
        boss = (self.parent as! ViewController)
        for spell in spellbook.spells {
            spells.append((spell,true))
            spellArray.append(spell)
            print(spellArray.count)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellArray.count
    }
    
    // Function for adding SpellDataCell to table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SpellDataCell
        let spell = spellArray[indexPath.row]
        cell.spell = spell
        cell.nameLabel.text = spell.name
        cell.schoolLabel.text = Spellbook.schoolNames[spell.school.rawValue]
        cell.levelLabel.text = String(spell.level)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Function to get the spells to currently display
    func getSpellArray() -> [Spell] {
        spellArray = []
        for tpl in spells {
            //print(tpl.0.name)
            //print(tpl.1)
            if tpl.1 {
                spellArray.append(tpl.0)
            }
        }
        return spellArray
    }
    
    
    // Function to sort the data by one field
    func singleSort(index: Int) {
        
        // Do the sorting
        spells.sort {return compareOne(s1: $0.0, s2: $1.0, index: index)}
        
        // Get the array
        spellArray = getSpellArray()

        // Repopulate the table
        print("Reloading")
        print(index)
        tableView.reloadData()
        print("Done reloading")
    }
    
    // Function to sort the data by two fields
    func doubleSort(index1: Int, index2: Int) {
        
        // Do the sorting
        spells.sort {return compareTwo(s1: $0.0, s2: $1.0, index1: index1, index2: index2)}
        
        // Get the array
        spellArray = getSpellArray()
        
        // Repopulate the table
        print("Reloading")
        print(index1)
        print(index2)
        tableView.reloadData()
        print("Done reloading")
    }
    
    // Function to entirely unfilter - i.e., display everything
    func unfilter() {
        for i in 0...spells.count-1 {
            spells[i] = (spells[i].0, true)
        }
        spellArray = getSpellArray()
        tableView.reloadData()
    }
    
    // Determine whether or not a single row should be filtered
    func filterItem(isClass: Bool, isFav: Bool, isText: Bool, s: Spell, cc: CasterClass, text: String) -> Bool {
        //print(s.name)
        //print(Spellbook.casterNames[cc.rawValue])
        let spname = s.name.lowercased()
        var toHide = (isClass && !s.usableByClass(cc: cc))
        toHide = toHide || (isFav && !s.favorite)
        toHide = toHide || (isText && !spname.starts(with: text))
        return toHide
    }
    
    // Function to filter the table data
    func filter(isFav: Bool) {
        
        // First, we filter the data
        let classIndex = boss?.pickerController?.classPicker.selectedRow(inComponent: 0)
        let isClass = (classIndex != 0)
        var cc: CasterClass = CasterClass(rawValue: 0)!
        let isText = false // Placeholder for now, until the search field is added
        let searchText = "" // Placeholder for now, until the search field is added
        if isClass {
            cc = CasterClass(rawValue: classIndex!-1)!
        }
        
        if ( !(isText || isFav || isClass) ) {
            unfilter()
        } else {
            for i in 0...spells.count-1 {
                let filter = filterItem(isClass: isClass, isFav: isFav, isText: isText, s: spells[i].0, cc: cc, text: searchText)
                spells[i] = (spells[i].0, !filter)
            }
        }
            
        // Get the new spell array
        spellArray = getSpellArray()
            
        // Repopulate the table
        tableView.reloadData()
    }
        
    // Filter function
    func filter() {
        let isFav = false // Just a placeholder until favoriting is implemented
        filter(isFav: isFav)
    }
    
    // Set what happens when a cell is selected
    // For us, that's creating a segue to a view with the spell info
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(boss!)
        //print(boss!.spellWindowController!)
        //boss?.spellWindowController!.spell = spellArray[indexPath.row]
        //boss?.performSegue(withIdentifier: spellWindowSegueIdentifier, sender: nil)
        let storyboard = self.storyboard
        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        self.present(spellWindowController, animated:true, completion: nil)
        spellWindowController.spell = spellArray[indexPath.row]
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
