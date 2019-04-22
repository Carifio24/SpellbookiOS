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
    var settings = Settings()
    var characterProfile = CharacterProfile()
    
    let nBlankPadding = 4

    
    @IBOutlet var spellTable: UITableView!
    
    let cellReuseIdentifier = "cell"
    let spellWindowSegueIdentifier = "spellWindowSegue"
    let spellWindowIdentifier = "spellWindow"
    
    // Storage files
    let favoritesFile = "Favorites.txt"
    let preparedFile = "Prepared.txt"
    let knownFile = "Known.txt"
    let settingsFile = "Settings.json"
    
    // Documents directory
    let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let profilesDirectoryName = "Characters"
    var profilesDirectory = URL(fileURLWithPath: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the list of spells
        //spellTable.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SpellDataCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .none
        
        // Create the profiles directory if it doesn't already exist
        let fileManager = FileManager.default
        profilesDirectory = documentsDirectory.appendingPathComponent(profilesDirectoryName)
        if !fileManager.fileExists(atPath: profilesDirectory.path) {
            do {
                try fileManager.createDirectory(atPath: profilesDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                print("\(e)")
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Get the main view
        main = self.parent as! ViewController
        
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
            
            // Load the settings
            loadSettings()
            
        }
        
        // Do an initial filtering
        filter()
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
    func singleSort(index: Int) {
        
        // Do the sorting
        spells.sort {return compareOne(s1: $0.0, s2: $1.0, index: index)}
        
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
    func doubleSort(index1: Int, index2: Int) {
        
        // Do the sorting
        spells.sort {return compareTwo(s1: $0.0, s2: $1.0, index1: index1, index2: index2)}
        
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
    func filterItem(isClass: Bool, knownSelected:Bool, preparedSelected: Bool, favSelected: Bool, isText: Bool, s: Spell, cc: CasterClass, text: String) -> Bool {
        let spname = s.name.lowercased()
        var toHide = (isClass && !s.usableByClass(cc: cc))
        toHide = toHide || (knownSelected && !characterProfile.isKnown(s: s))
        toHide = toHide || (preparedSelected && !characterProfile.isPrepared(s: s))
        toHide = toHide || (favSelected && !characterProfile.isFavorite(s: s))
        toHide = toHide || (isText && !spname.starts(with: text))
        toHide = toHide || (!(settings.getFilter(sb: s.sourcebook)))
        return toHide
    }
    
    // Function to filter the table data
    func filter() {
        
        // First, we filter the data
        let classIndex = main?.pickerController?.classPicker.selectedRow(inComponent: 0)
        let isClass = (classIndex != 0)
        var cc: CasterClass = CasterClass(rawValue: 0)!
        let isText = !((main?.pickerController?.searchField.text?.isEmpty)!)
        let searchText = isText ? (main?.pickerController?.searchField.text)! : ""
        if isClass {
            cc = CasterClass(rawValue: classIndex!-1)!
        }
        for i in 0...spells.count-1 {
            let filter = filterItem(isClass: isClass, knownSelected: settings.filterByKnown, preparedSelected: settings.filterByPrepared, favSelected: settings.filterByFavorites, isText: isText, s: spells[i].0, cc: cc, text: searchText)
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
        let storyboard = self.storyboard
        let spellWindowController = storyboard?.instantiateViewController(withIdentifier: spellWindowIdentifier) as! SpellWindowController
        self.present(spellWindowController, animated:true, completion: nil)
        spellWindowController.spellIndex = indexPath.row
        spellWindowController.spell = paddedArray[indexPath.row]
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
    
    func loadSpellsForProperty(filename: String, propSetter: SpellStatusSetter) {
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        print("Loading spells from")
        print(fileLocation)
        if let fileText = try? String(contentsOf: fileLocation) {
            let fileItems = fileText.components(separatedBy: .newlines)
            for item in fileItems {
                //var inSpellbook = false
                for spell in spells {
                    if item == spell.0.name {
                        propSetter(spell.0, true)
                        print(spell.0.name)
                        //inSpellbook = true
                        break
                    }
                }
            }
        } else {
            return
        }
    }
    
    func loadFavorites() {
        let favoritesFile = documentsDirectory.appendingPathComponent("Favorites.txt")
        if let favoritesText = try? String(contentsOf: favoritesFile) {
            let favoriteNames = favoritesText.components(separatedBy: .newlines)
            for name in favoriteNames {
                var inSpellbook = false
                for spell in spells {
                    if name == spell.0.name {
                        characterProfile.setFavorite(s: spell.0, fav: true)
                        inSpellbook = true
                        break
                    }
                }
                // if !inSpellbook {
                    // throw Exception
                // }
            }
        } else {
            return
        }
    }
    
    func saveSpellsWithProperty(propGetter: SpellStatusGetter, filename: String) {
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        print("Saving spells to:")
        print(fileLocation)
        var propNames: [String] = []
        for spell in spells {
            if propGetter(spell.0) {
                propNames.append(spell.0.name)
                print(spell.0.name)
            }
        }
        let propString = propNames.joined(separator: "\n")
        do {
            try propString.write(to: fileLocation, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
        }
    }
    
    func saveFavorites() {
        let favoritesFile = documentsDirectory.appendingPathComponent("Favorites.txt")
        var favoriteNames: [String] = []
        for spell in spells {
            if characterProfile.isFavorite(s: spell.0) {
                favoriteNames.append(spell.0.name)
            }
        }
        let favoritesString =  favoriteNames.joined(separator: "\n")
        do {
            try favoritesString.write(to: favoritesFile, atomically: false, encoding: .utf8)
        } catch let e {
            print("\(e)")
        }
    }
    
    // Saving the settings
    func saveSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        settings.save(filename: settingsLocation)
    }
    
    // Loading the settings
    func loadSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        if let settingsText = try? String(contentsOf: settingsLocation) {
            do {
                let settingsJSON = SION(json: settingsText)
                settings = Settings(json: settingsJSON)
            }
        } else {
            return
        }
    }
    
    func saveCharacterProfile() {
        let charFile: String = characterProfile.name + ".json"
        let profileLocation = profilesDirectory.appendingPathComponent(charFile)
        characterProfile.save(filename: profileLocation)
    }
    
    func setSideMenuCharacterName() {
        let sideMenuController = main?.sideMenuController!
        sideMenuController!.characterLabel.text = "Character: " + characterProfile.name
    }
    
    func setCharacterProfile(cp: CharacterProfile) {
        characterProfile = cp
        settings.setCharacterName(name: cp.name)
        setSideMenuCharacterName()
        saveSettings()
        saveCharacterProfile()
        filter()
    }
    
    func characterList() -> [String] {
        var charList: [String] = []
        let fileManager = FileManager.default
        let charExt = "json"
        let charExtLen = charExt.count
        let enumerator = fileManager.enumerator(at: profilesDirectory, includingPropertiesForKeys: nil)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(charExt) {
                var charName = element
                charName.removeLast(charExtLen+1)
                charList.append(charName)
            }
        }
        return charList
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
