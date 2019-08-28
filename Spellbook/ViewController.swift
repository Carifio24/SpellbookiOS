//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Spellbook
    let spellbook = Spellbook(jsonStr: try! String(contentsOf: Bundle.main.url(forResource: "Spells", withExtension: "json")!))
    
    // Storage files
    let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let profilesDirectoryName = "Characters"
    var profilesDirectory = URL(fileURLWithPath: "")
    let settingsFile = "Settings.json"
    
    // The background image
    @IBOutlet weak var backgroundView: UIImageView!
    
    // Child controllers
    var pickerController: PickerViewController?
    var labelController: LabelViewController?
    var tableController: SpellTableViewController?
    var spellWindowController: SpellWindowController?
    
    // First appearance or not
    var firstAppearance: Bool = true
    
    // The side menu controller
    var sideMenuController: SideMenuController?
    
    // Settings, character profile, and selection window
    var settings = Settings()
    var characterProfile = CharacterProfile()
    var selectionWindow: CharacterSelectionController? {
        didSet {
            if selectionWindow != nil {
                print("Set selectionWindow to \(selectionWindow!)")
            } else {
                print("Set selectionWindow to nil")
            }
        }
    }
    
    // The UIViews that hold the child controllers
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var tableView: UIView!
    
    // Dimensions
    let sortFraction = CGFloat(0.08)
    let labelFraction = CGFloat(0.08)
    // The table will take up the rest of the space
    //let backgroundOffset = CGFloat(27)
    let backgroundOffset = CGFloat(0)
    
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
        
        // Display the build and version number (for testing)
        //print("The iOS version is \(iOSVersion)")
        //print("The app build number is \(appBuild)")
        //print("The app version number is \(appVersion)")
        //print("The native scale factor is \(UIScreen.main.nativeScale)")
        //let nativeBounds = UIScreen.main.nativeBounds
        //print("The native bounds are \(nativeBounds.size.width), \(nativeBounds.size.height)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstAppearance { return }
        
        // Do any additional setup after loading the view, typically from a nib.
        let screenRect = UIScreen.main.bounds
        setContainerDimensions(screenWidth: screenRect.size.width, screenHeight: screenRect.size.height)
        
        // Dismiss keyboard when not in the search field
        let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
        
        // Pull out the side menu
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Get the side menu controller
        sideMenuController = self.revealViewController()?.rearViewController as? SideMenuController
        
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
        
        // Load the settings
        loadSettings()
        
        // Load the character profile
        let characters = characterList()
        if settings.charName != nil {
            let name = settings.charName
            //print("case 1")
            //print("name is \(name!)")
            loadCharacterProfile(name: name!)
        } else if characters.count > 0 {
            //print("case 2")
            //print("characters[0] is \(characters[0])")
            loadCharacterProfile(name: characters[0])
        } else {
            //print("case 3")
            openCharacterCreationDialog(mustComplete: true)
        }
        
        // Do an initial filtering
        filter()
        
        firstAppearance = false
        
    }
    
    func setContainerDimensions(screenWidth: CGFloat, screenHeight: CGFloat) {
        
        //print("Screen width: \(screenWidth)")
        //print("Screen height: \(screenHeight)")
        
        // Set the dimensions for the background image
        // No padding necessary for this
        backgroundView.frame = CGRect(x: 0, y: -backgroundOffset, width: screenWidth, height: screenHeight + backgroundOffset)
        
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
        let tableY = sortHeight + labelHeight
        let tableFrame = CGRect(x: leftPadding, y: tableY, width: usableWidth, height: tableHeight)
        tableView.frame = tableFrame
        tableController!.view!.frame = tableFrame
        tableController!.mainY = tableY
        
        pickerController?.setViewDimensions()
        labelController?.setViewDimensions()
        tableController?.setTableDimensions(leftPadding: leftPadding, bottomPadding: bottomPadding, usableHeight: usableHeight, usableWidth: usableWidth, tableTopPadding: tableView.frame.height * 0.04)
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
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setContainerDimensions(screenWidth: size.width, screenHeight: size.height)
        SpellDataCell.screenWidth = size.width
    }
    
    // Until the issue with the SpellDataCell sizing is fixed, let's disable rotation
    override open var shouldAutorotate: Bool {
        return false
    }
    
    // To dismiss the keyboard
    @objc func endEditing() {
        pickerController!.searchField.resignFirstResponder()
    }
    
    // Get the list of characters that currently exist
    func characterList() -> [String] {
        var charList: [String] = []
        let fileManager = FileManager.default
        let charExt = "json"
        let charExtLen = charExt.count
        //print("profilesDirectory is \(profilesDirectory)")
        let enumerator = fileManager.enumerator(at: profilesDirectory, includingPropertiesForKeys: nil)
        //while let element = enumerator?.nextObject() as? String {
        for x in enumerator!.allObjects {
            let url = x as! URL
            let element = url.lastPathComponent
            //print(element)
            if element.hasSuffix(charExt) {
                var charName = element
                charName.removeLast(charExtLen+1)
                charList.append(charName)
            }
        }
        charList.sort(by: { $0.lowercased() < $1.lowercased() })
        return charList
    }
    
    func setSideMenuCharacterName() {
        print("Setting side menu name with \(characterProfile.name())")
        if (sideMenuController!.characterLabel != nil) {
            //print("Here")
            sideMenuController!.characterLabel.text = "Character: " + characterProfile.name()
        } else {
            //print("label is nil")
            return
        }
    }
    
    func setSortSettings() {
        let sf1 = characterProfile.getFirstSortField()
        let sf2 = characterProfile.getSecondSortField()
        let rev1 = characterProfile.getFirstSortReverse()
        let rev2 = characterProfile.getSecondSortReverse()
        pickerController!.setSortStatus(sort1: sf1, sort2: sf2, reverse1: rev1, reverse2: rev2)
    }
    
    func setFilterSettings() {
        let caster = characterProfile.getFilterClass()
        pickerController!.setFilterStatus(caster: caster)
        sideMenuController!.setFilterStatus(profile: characterProfile)
    }
    
    func setCharacterProfile(cp: CharacterProfile) {
        characterProfile = cp
        settings.setCharacterName(name: cp.name())
        setSideMenuCharacterName()
        saveSettings()
        saveCharacterProfile()
        filter()
        updateSelectionList()
        
        // Set the sort and filter settings
        setSortSettings()
        setFilterSettings()
    }
    
    // Loading the settings
    func loadSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        //print("settingsLocation is: \(settingsLocation)")
        if let settingsText = try? String(contentsOf: settingsLocation) {
            do {
                //print("settingsText is: \(settingsText)")
                let settingsJSON = SION(json: settingsText)
                settings = Settings(json: settingsJSON)
            }
        } else {
            //print("Error getting settings")
            return
        }
    }
    
    func profileLocation(name: String) -> URL {
        let charFile = name + ".json"
        return profilesDirectory.appendingPathComponent(charFile)
    }
    
    func loadCharacterProfile(name: String) {
        let location = profileLocation(name: name)
        //print("Location is: \(location)")
        if var profileText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&profileText)
                print("profileText is:\n\(profileText)")
                let profileSION = SION(json: profileText)
                let profile = CharacterProfile(sion: profileSION)
                setCharacterProfile(cp: profile)
            }
        } else {
            print("Error reading file")
            settings.setCharacterName(name: nil)
            return
        }
    }
    
    func saveCharacterProfile() {
        let location = profileLocation(name: characterProfile.name())
        //print("Saving profile for \(characterProfile.name) to \(location)")
        characterProfile.save(filename: location)
    }
    
    func deleteCharacterProfile(name: String) {
        let location = profileLocation(name: name)
        //print("Beginning deleteCharacterProfile with name: \(name)")
        let fileManager = FileManager.default
        do {
            let deletingCurrent = (name == characterProfile.name())
            try fileManager.removeItem(at: location)
            let characters = characterList()
            updateSelectionList()
            setSideMenuCharacterName()
            //print("deletingCurrent: \(deletingCurrent)")
            if deletingCurrent {
                if characters.count > 0 {
                    //print("The new character's name is: \(characters[0])")
                    loadCharacterProfile(name: characters[0])
                }
            }
        } catch let e {
            print("\(e)")
        }
    }
    
    // Saving the settings
    func saveSettings() {
        let settingsLocation = documentsDirectory.appendingPathComponent(settingsFile)
        settings.save(filename: settingsLocation)
        //print("Settings are: \(settings.toJSONString())")
        //print("Saving settings to: \(settingsLocation)")
    }
    
    func updateSelectionList() {
        //print("In updateSelectionList()")
        if selectionWindow != nil {
            //print("Updating...")
            selectionWindow!.updateCharacterTable()
        }
    }
    
    func openCharacterCreationDialog(mustComplete: Bool=false) {
        
        //print("mustComplete: \(mustComplete)")
        //print("selectionWindow condition: \(selectionWindow == nil)")
        
        if mustComplete && (selectionWindow == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "characterCreation") as! CharacterCreationController
            controller.main = self
            
            let screenRect = UIScreen.main.bounds
            let popupWidth = CGFloat(0.8 * screenRect.size.width)
            let popupHeight = CGFloat(0.25 * screenRect.size.height)
            controller.width = popupWidth
            controller.height = popupHeight
            let popupVC = PopupViewController(contentController: controller, popupWidth: popupWidth, popupHeight: popupHeight)
            if mustComplete {
                controller.cancelButton.isHidden = true
                popupVC.canTapOutsideToDismiss = false
                self.present(popupVC, animated: true)
            }
        } else {
            //selectionWindow!.displayNewCharacterWindow(mustComplete: mustComplete)
            selectionWindow!.newCharacterButton.sendActions(for: UIControl.Event.touchUpInside)
        }
        
    }
    
    func loadSpellsForProperty(filename: String, propSetter: SpellStatusSetter) {
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        //print("Loading spells from")
        //print(fileLocation)
        if let fileText = try? String(contentsOf: fileLocation) {
            let fileItems = fileText.components(separatedBy: .newlines)
            for item in fileItems {
                //var inSpellbook = false
                for spell in tableController!.spells {
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
    
    func saveSpellsWithProperty(propGetter: SpellStatusGetter, filename: String) {
        let fileLocation = documentsDirectory.appendingPathComponent(filename)
        print("Saving spells to:")
        print(fileLocation)
        var propNames: [String] = []
        for spell in tableController!.spells {
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
    
    // Wrapper around table controller functionality
    func filter() { tableController!.filter() }
    
}
