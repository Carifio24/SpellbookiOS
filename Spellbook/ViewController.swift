//
//  ViewController.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

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
    var tableController: SpellTableViewController?
    var spellWindowController: SpellWindowController?
    var sortFilterController: SortFilterTableController?
    
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
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var sortFilterView: UIView!
    @IBOutlet weak var sortFilterTableView: UIView!
    
    // Dimensions
    let sortFraction = CGFloat(0.08)
    let labelFraction = CGFloat(0.08)
    // The table will take up the rest of the space
    //let backgroundOffset = CGFloat(27)
    
    // Whether or not the filter window is visible
    var filterVisible = false
    
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
    
    // Usable height and width
    static var usableHeight = CGFloat(0)
    static var usableWidth = CGFloat(0)
    
    // The navigation bar and its items
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var leftMenuButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet var rightMenuButton: UIBarButtonItem!
    
    // Status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For updating the status bar
        setNeedsStatusBarAppearanceUpdate()
        
        // Set the status bar color
//        let statusBarBGColor = UIColor.black
//        if #available(iOS 13.0, *) {
//            let app = UIApplication.shared
//            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
//
//            let statusbarView = UIView()
//            statusbarView.backgroundColor = statusBarBGColor
//            view.addSubview(statusbarView)
//
//            statusbarView.translatesAutoresizingMaskIntoConstraints = false
//            statusbarView.heightAnchor
//                .constraint(equalToConstant: statusBarHeight).isActive = true
//            statusbarView.widthAnchor
//                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
//            statusbarView.topAnchor
//                .constraint(equalTo: view.topAnchor).isActive = true
//            statusbarView.centerXAnchor
//                .constraint(equalTo: view.centerXAnchor).isActive = true
//
//        } else {
//            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//            statusBar?.backgroundColor = statusBarBGColor
//        }
        
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
        
        // Everything in this method is setup, so we can just return after the first time
        // This stuff isn't in viewDidLoad so that it can access the necessary subviews
        // as this calls some subview methods as well as sets dimensions
        if !firstAppearance { return }
        
        // Set the sizes of the container views (there are no other top level elements)
        let screenRect = UIScreen.main.bounds
        setContainerDimensions(screenWidth: screenRect.size.width, screenHeight: screenRect.size.height)
        
        // Dismiss keyboard when not in the search field
        //let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        //tapper.cancelsTouchesInView = false
        //view.addGestureRecognizer(tapper)
        
        // This adds the gesture recognizer for pulling out the side menu
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Get the side menu controller
        sideMenuController = self.revealViewController()?.rearViewController as? SideMenuController
        
        // Set the navigation bar button callbacks
        leftMenuButton.target = self
        leftMenuButton.action = #selector(leftMenuButtonPressed)
        filterButton.target = self
        filterButton.action = #selector(filterButtonPressed)
        rightMenuButton.target = self
        rightMenuButton.action = #selector(rightMenuButtonPressed)
        
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
            loadCharacterProfile(name: name!, initialLoad: true)
        } else if characters.count > 0 {
            //print("case 2")
            //print("characters[0] is \(characters[0])")
            loadCharacterProfile(name: characters[0], initialLoad: true)
        } else {
            //print("case 3")
            openCharacterCreationDialog(mustComplete: true)
        }
        
        // The view has appeared, so we can set firstAppearance to false
        firstAppearance = false
        
        // Initial sort and filter
        //sort()
        //filter()
        
        // Testing
        //pickerView.backgroundColor = UIColor.red
        //labelView.backgroundColor = UIColor.blue
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // This function sets the sizes of the top-level container views
    func setContainerDimensions(screenWidth: CGFloat, screenHeight: CGFloat) {

        
        // Get the padding sizes
        let leftPadding = max(min(leftPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let rightPadding = max(min(rightPaddingFraction * screenWidth, maxHorizPadding), minHorizPadding)
        let topPadding = max(min(topPaddingFraction * screenHeight, maxTopPadding), minTopPadding)
        let bottomPadding = max(min(bottomPaddingFraction * screenHeight, maxBotPadding), minBotPadding)
        
        // Account for padding
        ViewController.usableHeight = screenHeight - topPadding - bottomPadding
        ViewController.usableWidth = screenWidth - leftPadding - rightPadding
        
        // Finally, the SpellTableViewController
        // Note that we don't need to adjust the tableController's view differently - the TableViewController seems to be able to handle this part itself
        tableController?.setTableDimensions(leftPadding: leftPadding, bottomPadding: bottomPadding, usableHeight: ViewController.usableHeight, usableWidth: ViewController.usableWidth, tableTopPadding: tableView.frame.height * 0.04)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // Connecting to the child controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableSegue" {
            tableController = (segue.destination as! SpellTableViewController)
        } else if segue.identifier == "sortFilterTableSegue" {
            sortFilterController = (segue.destination as! SortFilterTableController)
        }
    }
    
    // This is supposed to handle rotations, etc.
    // so we re-call setContainerDimensions and change the size associated to SpellDataCell
    // But for the moment, the SpellDataCell change doesn't work correctly, and so rotation is disabled
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setContainerDimensions(screenWidth: size.width, screenHeight: size.height)
    }
    
    // Until the issue with the SpellDataCell sizing is fixed, let's disable rotation
    override open var shouldAutorotate: Bool {
        return false
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
        //print("Setting side menu name with \(characterProfile.name())")
        if (sideMenuController!.characterLabel != nil) {
            //print("Here")
            sideMenuController!.characterLabel.text = "Character: " + characterProfile.name()
        } else {
            //print("label is nil")
            return
        }
    }
    
    func setFilterStatus() {
        sideMenuController!.setFilterStatus(profile: characterProfile)
    }
    
    func setSortFilterSettings() {
        sortFilterController?.onCharacterProfileUpdate()
    }
    
    func setCharacterProfile(cp: CharacterProfile, initialLoad: Bool) {
        
        characterProfile = cp
        settings.setCharacterName(name: cp.name())
        setSideMenuCharacterName()
        setSortFilterSettings()
        saveSettings()
        saveCharacterProfile()
        
        // Set side menu filter status
        setFilterStatus()
        
        // Filter and sort
        if !initialLoad {
            sort()
            filter()
            updateSelectionList()
        }
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
            settings = Settings()
            return
        }
    }
    
    func profileLocation(name: String) -> URL {
        let charFile = name + ".json"
        return profilesDirectory.appendingPathComponent(charFile)
    }
    
    func loadCharacterProfile(name: String, initialLoad: Bool) {
        let location = profileLocation(name: name)
        //print("Location is: \(location)")
        if var profileText = try? String(contentsOf: location) {
            do {
                fixEscapeCharacters(&profileText)
                //print("profileText is:\n\(profileText)")
                let profileSION = SION(json: profileText)
                let profile = CharacterProfile(sion: profileSION)
                setCharacterProfile(cp: profile, initialLoad: initialLoad)
            }
        } else {
            print("Error reading profile")
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
                    loadCharacterProfile(name: characters[0], initialLoad: false)
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
        
        if selectionWindow == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "characterCreation") as! CharacterCreationController
            
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
        //print("Saving spells to:")
        //print(fileLocation)
        var propNames: [String] = []
        for spell in tableController!.spells {
            if propGetter(spell.0) {
                propNames.append(spell.0.name)
                //print(spell.0.name)
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
    
    // Wrapper around table controller functionality
    func sort() { tableController!.sort() }
    
    // Toggle whether or not the side menu is open
    func toggleLeftMenu() { Controllers.revealController.revealToggle(animated: true) }
    func toggleRightMenu() { Controllers.revealController.rightRevealToggle(animated: true) }
    
    // For the left menu button on the navigation bar
    @objc func leftMenuButtonPressed() { toggleLeftMenu() }
    
    // For the right menu button on the navigation bar
    @objc func rightMenuButtonPressed() { toggleRightMenu() }
    
    // For toggling the sort/filter windows
    func toggleWindowVisibilities() {
        filterVisible = !filterVisible
        tableView.isHidden = filterVisible
        sortFilterTableView.isHidden = !filterVisible
        navigationController?.hidesBarsOnSwipe = !filterVisible
    }
    
    // For the filter button on the navigation bar
    @objc func filterButtonPressed() { toggleWindowVisibilities() }
    
    @objc func endEditing() { }
    
}
